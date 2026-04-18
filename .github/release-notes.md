# Muslimku Android Release

Build ini berisi beberapa varian APK agar pengguna bisa memilih file yang paling cocok untuk device mereka.

## Pilih APK yang mana?

- **arm64-v8a**
  - rekomendasi untuk sebagian besar HP Android modern
  - ukuran lebih kecil daripada universal
- **armeabi-v7a**
  - opsi yang biasanya paling kecil untuk HP tertentu
  - cocok jika storage perangkat terbatas
- **universal**
  - paling kompatibel
  - ukuran paling besar
- **x86_64**
  - hanya untuk emulator Android
  - bukan untuk pemakaian HP biasa

## Rekomendasi cepat

- Kalau bingung, pilih **arm64-v8a**
- Kalau HP butuh file lebih kecil, coba **armeabi-v7a**
- Kalau ingin paling aman dari sisi kompatibilitas, pilih **universal**

## Catatan

- Source code utama ada di branch `main`
- Build Android dirilis lewat GitHub Actions
- iPhone tidak menggunakan file APK; distribusinya nanti lewat TestFlight atau App Store
