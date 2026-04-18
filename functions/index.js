const { onRequest } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const crypto = require('node:crypto');
const { SESv2Client, SendEmailCommand } = require('@aws-sdk/client-sesv2');

admin.initializeApp();

const db = admin.firestore();
const REGION = 'asia-southeast1';
const OTP_TTL_MS = 10 * 60 * 1000;
const RESET_TOKEN_TTL_MS = 15 * 60 * 1000;
const RESEND_COOLDOWN_MS = 45 * 1000;
const MAX_ATTEMPTS = 5;
const OTP_COLLECTION = 'authOtpChallenges';
const RATE_LIMIT_COLLECTION = 'authRateLimits';
const MAX_OTP_PER_HOUR = 10;
const MAX_OTP_PER_DAY = 30;
const MAX_USERNAME_RECOVERY_PER_HOUR = 6;
const MAX_USERNAME_RECOVERY_PER_DAY = 15;

const resendApiKey = defineSecret('RESEND_API_KEY');
const resendFromEmail = defineSecret('RESEND_FROM_EMAIL');
const twilioAccountSid = defineSecret('TWILIO_ACCOUNT_SID');
const twilioAuthToken = defineSecret('TWILIO_AUTH_TOKEN');
const twilioFromNumber = defineSecret('TWILIO_FROM_NUMBER');
const awsRegionSecret = defineSecret('AWS_REGION');
const awsAccessKeyIdSecret = defineSecret('AWS_ACCESS_KEY_ID');
const awsSecretAccessKeySecret = defineSecret('AWS_SECRET_ACCESS_KEY');
const sesFromEmailSecret = defineSecret('SES_FROM_EMAIL');
const DELIVERY_SECRETS = [
  resendApiKey,
  resendFromEmail,
  twilioAccountSid,
  twilioAuthToken,
  twilioFromNumber,
  awsRegionSecret,
  awsAccessKeyIdSecret,
  awsSecretAccessKeySecret,
  sesFromEmailSecret,
];

function jsonResponse(res, payload) {
  res.status(200).json(payload);
}

function failure(code, message, extra = {}) {
  return {
    success: false,
    code,
    message,
    ...extra,
  };
}

function success(message, extra = {}) {
  return {
    success: true,
    code: 'success',
    message,
    ...extra,
  };
}

function normalizeEmail(value) {
  return String(value || '').trim().toLowerCase();
}

function normalizePhone(value) {
  return String(value || '').replace(/[^\d+]/g, '');
}

function isEmail(value) {
  return normalizeEmail(value).includes('@');
}

function slugify(value) {
  return String(value || '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '')
      .trim();
}

function buildChallengeId(flow, destination) {
  return crypto
      .createHash('sha256')
      .update(`${flow}:${destination}`)
      .digest('hex');
}

function hashSecret(value) {
  return crypto.createHash('sha256').update(String(value)).digest('hex');
}

function generateOtp() {
  return `${crypto.randomInt(100000, 1000000)}`;
}

function generateToken() {
  return crypto.randomBytes(24).toString('hex');
}

function resolveClientIp(req) {
  const forwarded = req.headers['x-forwarded-for'];
  const raw = Array.isArray(forwarded)
    ? forwarded[0]
    : (forwarded || req.ip || 'unknown');
  return String(raw).split(',')[0].trim() || 'unknown';
}

function maskEmail(email) {
  const normalized = normalizeEmail(email);
  const [name, domain] = normalized.split('@');
  if (!name || !domain) return normalized;
  const visible = name.length <= 2 ? name[0] ?? '*' : `${name[0]}${name[1]}`;
  return `${visible}${'*'.repeat(Math.max(name.length - visible.length, 2))}@${domain}`;
}

function maskPhone(phone) {
  const normalized = normalizePhone(phone);
  if (normalized.length < 5) return normalized;
  return `${normalized.slice(0, 3)}${'*'.repeat(Math.max(normalized.length - 5, 2))}${normalized.slice(-2)}`;
}

function buildOtpMessage(flow, code) {
  switch (flow) {
    case 'signup':
      return {
        subject: 'Kode OTP Muslimku untuk membuat akun',
        text: `Kode verifikasi Muslimku Anda adalah ${code}. Berlaku 10 menit.`,
        html: `<p>Kode verifikasi Muslimku Anda:</p><h2 style="letter-spacing:4px;">${code}</h2><p>Berlaku selama 10 menit.</p>`,
      };
    case 'verify_email':
      return {
        subject: 'Kode OTP Muslimku untuk verifikasi email',
        text: `Kode verifikasi email Muslimku Anda adalah ${code}. Berlaku 10 menit.`,
        html: `<p>Kode verifikasi email Muslimku Anda:</p><h2 style="letter-spacing:4px;">${code}</h2><p>Berlaku selama 10 menit.</p>`,
      };
    case 'reset_password':
      return {
        subject: 'Kode OTP Muslimku untuk reset password',
        text: `Kode reset password Muslimku Anda adalah ${code}. Berlaku 10 menit.`,
        html: `<p>Kode reset password Muslimku Anda:</p><h2 style="letter-spacing:4px;">${code}</h2><p>Berlaku selama 10 menit.</p>`,
      };
    default:
      return {
        subject: 'Kode OTP Muslimku',
        text: `Kode verifikasi Muslimku Anda adalah ${code}.`,
        html: `<p>Kode verifikasi Muslimku Anda:</p><h2 style="letter-spacing:4px;">${code}</h2>`,
      };
  }
}

async function sendEmail({ to, subject, text, html }) {
  const resendKey = resendApiKey.value();
  const resendFrom = resendFromEmail.value();
  if (resendKey && resendFrom) {
    return sendEmailWithResend({
      to,
      subject,
      text,
      html,
      apiKey: resendKey,
      from: resendFrom,
    });
  }

  const awsRegion = awsRegionSecret.value();
  const awsAccessKeyId = awsAccessKeyIdSecret.value();
  const awsSecretAccessKey = awsSecretAccessKeySecret.value();
  const sesFromEmail = sesFromEmailSecret.value();
  if (awsRegion && awsAccessKeyId && awsSecretAccessKey && sesFromEmail) {
    return sendEmailWithSes({
      to,
      subject,
      text,
      html,
      region: awsRegion,
      accessKeyId: awsAccessKeyId,
      secretAccessKey: awsSecretAccessKey,
      from: sesFromEmail,
    });
  }

  return failure(
      'email_not_configured',
      'Provider email belum dikonfigurasi di Firebase Functions.',
  );
}

async function sendEmailWithResend({ to, subject, text, html, apiKey, from }) {
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from,
      to: [to],
      subject,
      text,
      html,
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    logger.error('Resend API error', body);
    return failure('email_send_failed', 'Gagal mengirim email OTP lewat Resend.');
  }

  return success('OTP email terkirim.');
}

async function sendEmailWithSes({
  to,
  subject,
  text,
  html,
  region,
  accessKeyId,
  secretAccessKey,
  from,
}) {
  try {
    const client = new SESv2Client({
      region,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });

    const command = new SendEmailCommand({
      FromEmailAddress: from,
      Destination: {
        ToAddresses: [to],
      },
      Content: {
        Simple: {
          Subject: {
            Charset: 'UTF-8',
            Data: subject,
          },
          Body: {
            Text: {
              Charset: 'UTF-8',
              Data: text,
            },
            Html: {
              Charset: 'UTF-8',
              Data: html,
            },
          },
        },
      },
    });

    await client.send(command);
    return success('OTP email terkirim.');
  } catch (error) {
    logger.error('SES API error', error);
    return failure('email_send_failed', 'Gagal mengirim email OTP lewat Amazon SES.');
  }
}

async function sendSms({ to, body }) {
  const sid = twilioAccountSid.value();
  const token = twilioAuthToken.value();
  const from = twilioFromNumber.value();

  if (!sid || !token || !from) {
    return failure(
        'sms_not_configured',
        'Provider SMS belum dikonfigurasi di Firebase Functions.',
    );
  }

  const auth = Buffer.from(`${sid}:${token}`).toString('base64');
  const response = await fetch(
      `https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`,
      {
        method: 'POST',
        headers: {
          Authorization: `Basic ${auth}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          From: from,
          To: to,
          Body: body,
        }),
      },
  );

  if (!response.ok) {
    const raw = await response.text();
    logger.error('Twilio API error', raw);
    return failure('sms_send_failed', 'Gagal mengirim SMS OTP.');
  }

  return success('OTP SMS terkirim.');
}

async function lookupUserByEmail(email) {
  const normalized = normalizeEmail(email);
  if (!normalized) return null;

  try {
    const authUser = await admin.auth().getUserByEmail(normalized);
    const profileDoc = await db.collection('users').doc(authUser.uid).get();
    return {
      uid: authUser.uid,
      email: normalized,
      phone: authUser.phoneNumber || profileDoc.data()?.phone || '',
      displayName: authUser.displayName || profileDoc.data()?.fullName || '',
      username: profileDoc.data()?.username || '',
      profile: profileDoc.data() || null,
      authUser,
    };
  } catch (error) {
    return null;
  }
}

async function lookupUserByPhone(phone) {
  const normalized = normalizePhone(phone);
  if (!normalized) return null;

  const snapshot = await db
      .collection('users')
      .where('phone', '==', normalized)
      .limit(1)
      .get();

  if (snapshot.empty) return null;

  const doc = snapshot.docs[0];
  const data = doc.data();
  let authUser = null;
  try {
    authUser = await admin.auth().getUser(doc.id);
  } catch (error) {
    authUser = null;
  }

  return {
    uid: doc.id,
    email: data.email || '',
    phone: normalized,
    displayName: data.fullName || authUser?.displayName || '',
    username: data.username || '',
    profile: data,
    authUser,
  };
}

async function generateUniqueUsername(fullName, email) {
  const base = slugify(fullName) || slugify(email.split('@')[0]) || 'muslimku';
  let candidate = base;
  let index = 1;

  while (true) {
    const existing = await db
        .collection('users')
        .where('username', '==', candidate)
        .limit(1)
        .get();
    if (existing.empty) return candidate;
    candidate = `${base}${index}`;
    index += 1;
  }
}

function validatePassword(password) {
  return typeof password === 'string' && password.trim().length >= 8;
}

async function enforceRateLimit({
  req,
  action,
  identity,
  perHour,
  perDay,
}) {
  const ip = resolveClientIp(req);
  const now = Date.now();
  const hourBucket = Math.floor(now / (60 * 60 * 1000));
  const dayBucket = new Date(now).toISOString().slice(0, 10);
  const rateDocId = hashSecret(`${action}:${ip}:${identity}`);
  const rateRef = db.collection(RATE_LIMIT_COLLECTION).doc(rateDocId);
  const snapshot = await rateRef.get();
  const data = snapshot.data();

  const nextHourCount = data?.hourBucket === hourBucket ? (data.hourCount || 0) + 1 : 1;
  const nextDayCount = data?.dayBucket === dayBucket ? (data.dayCount || 0) + 1 : 1;

  if (nextHourCount > perHour || nextDayCount > perDay) {
    return failure(
        'rate_limited',
        'Terlalu banyak permintaan dari jaringan ini. Coba lagi nanti.',
    );
  }

  await rateRef.set(
      {
        action,
        identity,
        ipHash: hashSecret(ip),
        hourBucket,
        hourCount: nextHourCount,
        dayBucket,
        dayCount: nextDayCount,
        updatedAtEpochMs: now,
      },
      { merge: true },
  );

  return success('Rate limit passed.');
}

async function createOrUpdateProfile({ uid, fullName, email, phone, username }) {
  const createdAt = Date.now();
  await db.collection('users').doc(uid).set(
      {
        uid,
        username,
        fullName,
        email,
        phone: phone || '',
        bio: 'Mulai perjalanan ibadah bersama Muslimku.',
        memberSince: new Date().toISOString().split('T')[0],
        isGuest: false,
        emailVerified: true,
        updatedAtEpochMs: createdAt,
      },
      { merge: true },
  );
}

exports.startAuthOtp = onRequest({ region: REGION, secrets: DELIVERY_SECRETS }, async (req, res) => {
  if (req.method !== 'POST') {
    return jsonResponse(res, failure('method_not_allowed', 'Gunakan metode POST.'));
  }

  try {
    const flow = String(req.body?.flow || '').trim();
    const rawEmail = req.body?.email;
    const rawPhone = req.body?.phone;
    const email = normalizeEmail(rawEmail);
    const phone = normalizePhone(rawPhone);

    if (!['signup', 'verify_email', 'reset_password'].includes(flow)) {
      return jsonResponse(res, failure('unsupported', 'Flow OTP tidak didukung.'));
    }

    const channel = phone ? 'sms' : 'email';
    const destination = channel === 'sms' ? phone : email;
    if (!destination) {
      return jsonResponse(
          res,
          failure('invalid_input', 'Email atau nomor tujuan OTP wajib diisi.'),
      );
    }

    const rateLimitResult = await enforceRateLimit({
      req,
      action: `otp:${flow}`,
      identity: destination,
      perHour: MAX_OTP_PER_HOUR,
      perDay: MAX_OTP_PER_DAY,
    });
    if (!rateLimitResult.success) {
      return jsonResponse(res, rateLimitResult);
    }

    let user = null;
    if (flow === 'signup') {
      user = await lookupUserByEmail(email);
      if (user != null) {
        return jsonResponse(
            res,
            failure('account_exists', 'Email sudah terdaftar. Gunakan login.'),
        );
      }
    } else if (channel === 'email') {
      user = await lookupUserByEmail(email);
      if (user == null) {
        return jsonResponse(
            res,
            failure('user_not_found', 'Akun tidak ditemukan.'),
        );
      }
    } else {
      user = await lookupUserByPhone(phone);
      if (user == null) {
        return jsonResponse(
            res,
            failure('user_not_found', 'Akun tidak ditemukan.'),
        );
      }
    }

    const challengeId = buildChallengeId(flow, destination);
    const challengeRef = db.collection(OTP_COLLECTION).doc(challengeId);
    const existingDoc = await challengeRef.get();
    const existing = existingDoc.data();
    const now = Date.now();

    if (
      existing != null &&
      typeof existing.lastSentAtEpochMs === 'number' &&
      now - existing.lastSentAtEpochMs < RESEND_COOLDOWN_MS
    ) {
      const waitMs = RESEND_COOLDOWN_MS - (now - existing.lastSentAtEpochMs);
      return jsonResponse(
          res,
          failure(
              'rate_limited',
              `Tunggu ${Math.ceil(waitMs / 1000)} detik sebelum kirim ulang OTP.`,
              {
                challengeId,
                maskedDestination:
                  channel === 'sms' ? maskPhone(phone) : maskEmail(email),
                expiresAtEpochMs: existing.expiresAtEpochMs || now + OTP_TTL_MS,
              },
          ),
      );
    }

    const code = generateOtp();
    const expiresAtEpochMs = now + OTP_TTL_MS;
    const maskedDestination =
      channel === 'sms' ? maskPhone(phone) : maskEmail(email);

    await challengeRef.set(
        {
          flow,
          channel,
          destination,
          email,
          phone,
          uid: user?.uid || null,
          codeHash: hashSecret(code),
          expiresAtEpochMs,
          attempts: 0,
          maxAttempts: MAX_ATTEMPTS,
          lastSentAtEpochMs: now,
          createdAtEpochMs: now,
          updatedAtEpochMs: now,
          verifiedAtEpochMs: null,
          resetTokenHash: null,
          resetTokenExpiresAtEpochMs: null,
          maskedDestination,
        },
        { merge: true },
    );

    let deliveryResult;
    if (channel === 'sms') {
      deliveryResult = await sendSms({
        to: phone,
        body: `Kode OTP Muslimku Anda: ${code}. Berlaku 10 menit.`,
      });
    } else {
      const message = buildOtpMessage(flow, code);
      deliveryResult = await sendEmail({
        to: email,
        subject: message.subject,
        text: message.text,
        html: message.html,
      });
    }

    if (!deliveryResult.success) {
      return jsonResponse(res, deliveryResult);
    }

    return jsonResponse(
        res,
        success('Kode OTP berhasil dikirim.', {
          challengeId,
          flow,
          channel,
          destination,
          maskedDestination,
          expiresAtEpochMs,
        }),
    );
  } catch (error) {
    logger.error('startAuthOtp failed', error);
    return jsonResponse(
        res,
        failure('server_error', 'Gagal memulai OTP. Coba lagi sebentar.'),
    );
  }
});

exports.verifyAuthOtp = onRequest({ region: REGION }, async (req, res) => {
  if (req.method !== 'POST') {
    return jsonResponse(res, failure('method_not_allowed', 'Gunakan metode POST.'));
  }

  try {
    const challengeId = String(req.body?.challengeId || '').trim();
    const code = String(req.body?.code || '').trim();
    const fullName = String(req.body?.fullName || '').trim();
    const password = String(req.body?.password || '');

    if (!challengeId || code.length !== 6) {
      return jsonResponse(
          res,
          failure('invalid_input', 'Challenge ID dan kode OTP wajib valid.'),
      );
    }

    const challengeRef = db.collection(OTP_COLLECTION).doc(challengeId);
    const challengeDoc = await challengeRef.get();
    const challenge = challengeDoc.data();

    if (!challengeDoc.exists || !challenge) {
      return jsonResponse(
          res,
          failure('challenge_not_found', 'Sesi OTP tidak ditemukan. Kirim ulang OTP.'),
      );
    }

    const now = Date.now();
    if (challenge.expiresAtEpochMs <= now) {
      return jsonResponse(
          res,
          failure('otp_expired', 'Kode OTP sudah kedaluwarsa. Kirim ulang OTP.', {
            challengeId,
            maskedDestination: challenge.maskedDestination,
          }),
      );
    }

    if ((challenge.attempts || 0) >= (challenge.maxAttempts || MAX_ATTEMPTS)) {
      return jsonResponse(
          res,
          failure('too_many_attempts', 'Terlalu banyak percobaan. Kirim ulang OTP.'),
      );
    }

    if (hashSecret(code) !== challenge.codeHash) {
      await challengeRef.set(
          {
            attempts: admin.firestore.FieldValue.increment(1),
            updatedAtEpochMs: now,
          },
          { merge: true },
      );
      return jsonResponse(res, failure('invalid_otp', 'Kode OTP salah. Coba lagi.'));
    }

    if (challenge.flow === 'signup') {
      if (!fullName) {
        return jsonResponse(
            res,
            failure('invalid_input', 'Nama lengkap diperlukan untuk membuat akun.'),
        );
      }
      if (!validatePassword(password)) {
        return jsonResponse(
            res,
            failure('invalid_input', 'Password minimal 8 karakter.'),
        );
      }

      const existingUser = await lookupUserByEmail(challenge.email);
      if (existingUser != null) {
        return jsonResponse(
            res,
            failure('account_exists', 'Email sudah terdaftar. Gunakan login.'),
        );
      }

      const createdUser = await admin.auth().createUser({
        email: challenge.email,
        password,
        displayName: fullName,
        emailVerified: true,
      });
      const username = await generateUniqueUsername(fullName, challenge.email);
      await createOrUpdateProfile({
        uid: createdUser.uid,
        fullName,
        email: challenge.email,
        phone: challenge.phone || '',
        username,
      });

      await challengeRef.set(
          {
            verifiedAtEpochMs: now,
            completedAtEpochMs: now,
            updatedAtEpochMs: now,
            uid: createdUser.uid,
          },
          { merge: true },
      );

      return jsonResponse(
          res,
          success('OTP valid. Akun berhasil dibuat.', {
            flow: challenge.flow,
            email: challenge.email,
            username,
          }),
      );
    }

    if (challenge.flow === 'verify_email') {
      const user = challenge.uid
        ? await admin.auth().getUser(challenge.uid)
        : await admin.auth().getUserByEmail(challenge.email);
      await admin.auth().updateUser(user.uid, { emailVerified: true });
      await db.collection('users').doc(user.uid).set(
          {
            emailVerified: true,
            updatedAtEpochMs: now,
          },
          { merge: true },
      );
      await challengeRef.set(
          {
            verifiedAtEpochMs: now,
            completedAtEpochMs: now,
            updatedAtEpochMs: now,
          },
          { merge: true },
      );

      return jsonResponse(
          res,
          success('Email berhasil diverifikasi.', {
            flow: challenge.flow,
            email: challenge.email,
          }),
      );
    }

    if (challenge.flow === 'reset_password') {
      const resetToken = generateToken();
      await challengeRef.set(
          {
            verifiedAtEpochMs: now,
            updatedAtEpochMs: now,
            resetTokenHash: hashSecret(resetToken),
            resetTokenExpiresAtEpochMs: now + RESET_TOKEN_TTL_MS,
          },
          { merge: true },
      );

      return jsonResponse(
          res,
          success('OTP valid. Lanjutkan atur password baru.', {
            flow: challenge.flow,
            email: challenge.email,
            resetToken,
          }),
      );
    }

    return jsonResponse(res, failure('unsupported', 'Flow OTP tidak didukung.'));
  } catch (error) {
    logger.error('verifyAuthOtp failed', error);
    return jsonResponse(
        res,
        failure('server_error', 'Gagal memverifikasi OTP. Coba lagi sebentar.'),
    );
  }
});

exports.completePasswordReset = onRequest({ region: REGION }, async (req, res) => {
  if (req.method !== 'POST') {
    return jsonResponse(res, failure('method_not_allowed', 'Gunakan metode POST.'));
  }

  try {
    const resetToken = String(req.body?.resetToken || '').trim();
    const newPassword = String(req.body?.newPassword || '');

    if (!resetToken || !validatePassword(newPassword)) {
      return jsonResponse(
          res,
          failure('invalid_input', 'Reset token valid dan password baru wajib diisi.'),
      );
    }

    const snapshot = await db
        .collection(OTP_COLLECTION)
        .where('resetTokenHash', '==', hashSecret(resetToken))
        .limit(1)
        .get();

    if (snapshot.empty) {
      return jsonResponse(
          res,
          failure('reset_session_not_found', 'Sesi reset password tidak ditemukan.'),
      );
    }

    const doc = snapshot.docs[0];
    const challenge = doc.data();
    const now = Date.now();

    if (
      !challenge.resetTokenExpiresAtEpochMs ||
      challenge.resetTokenExpiresAtEpochMs <= now
    ) {
      return jsonResponse(
          res,
          failure('reset_session_expired', 'Sesi reset password sudah kedaluwarsa.'),
      );
    }

    const user = challenge.uid
      ? await admin.auth().getUser(challenge.uid)
      : await admin.auth().getUserByEmail(challenge.email);
    await admin.auth().updateUser(user.uid, { password: newPassword });
    await admin.auth().revokeRefreshTokens(user.uid);

    await doc.ref.set(
        {
          completedAtEpochMs: now,
          updatedAtEpochMs: now,
          resetTokenHash: null,
          resetTokenExpiresAtEpochMs: null,
        },
        { merge: true },
    );

    return jsonResponse(res, success('Password berhasil diperbarui.'));
  } catch (error) {
    logger.error('completePasswordReset failed', error);
    return jsonResponse(
        res,
        failure('server_error', 'Gagal memperbarui password. Coba lagi sebentar.'),
    );
  }
});

exports.sendUsernameReminder = onRequest({ region: REGION, secrets: DELIVERY_SECRETS }, async (req, res) => {
  if (req.method !== 'POST') {
    return jsonResponse(res, failure('method_not_allowed', 'Gunakan metode POST.'));
  }

  try {
    const recovery = String(req.body?.recovery || '').trim();
    if (!recovery) {
      return jsonResponse(
          res,
          failure('invalid_input', 'Email atau nomor telepon wajib diisi.'),
      );
    }

    const rateLimitResult = await enforceRateLimit({
      req,
      action: 'username_recovery',
      identity: recovery.toLowerCase(),
      perHour: MAX_USERNAME_RECOVERY_PER_HOUR,
      perDay: MAX_USERNAME_RECOVERY_PER_DAY,
    });
    if (!rateLimitResult.success) {
      return jsonResponse(res, rateLimitResult);
    }

    const byEmail = isEmail(recovery);
    const user = byEmail
      ? await lookupUserByEmail(recovery)
      : await lookupUserByPhone(recovery);

    if (user == null || !user.username) {
      return jsonResponse(
          res,
          failure('user_not_found', 'Akun tidak ditemukan dengan data tersebut.'),
      );
    }

    let deliveryResult;
    let maskedDestination;
    if (byEmail) {
      maskedDestination = maskEmail(user.email);
      deliveryResult = await sendEmail({
        to: user.email,
        subject: 'Username akun Muslimku Anda',
        text: `Username akun Muslimku Anda adalah ${user.username}.`,
        html: `<p>Username akun Muslimku Anda:</p><h2>${user.username}</h2>`,
      });
    } else {
      maskedDestination = maskPhone(user.phone);
      deliveryResult = await sendSms({
        to: user.phone,
        body: `Username akun Muslimku Anda: ${user.username}`,
      });
    }

    if (!deliveryResult.success) {
      return jsonResponse(res, deliveryResult);
    }

    return jsonResponse(
        res,
        success('Username berhasil dikirim.', {
          maskedDestination,
          username: user.username,
        }),
    );
  } catch (error) {
    logger.error('sendUsernameReminder failed', error);
    return jsonResponse(
        res,
        failure(
            'server_error',
            'Gagal mengirim username sekarang. Coba lagi sebentar.',
        ),
    );
  }
});
