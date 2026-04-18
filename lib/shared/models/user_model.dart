class UserModel {
  const UserModel({
    required this.uid,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.bio,
    required this.memberSince,
    required this.isGuest,
  });

  final String uid;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String bio;
  final String memberSince;
  final bool isGuest;

  String get initials {
    final parts = fullName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'MK';
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  String get firstName {
    final parts = fullName.split(' ').where((part) => part.isNotEmpty);
    return parts.isEmpty ? 'Sahabat' : parts.first;
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? fullName,
    String? email,
    String? phone,
    String? bio,
    String? memberSince,
    bool? isGuest,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      memberSince: memberSince ?? this.memberSince,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'bio': bio,
      'memberSince': memberSince,
      'isGuest': isGuest,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: (json['uid'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      fullName: (json['fullName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      bio: (json['bio'] ?? '') as String,
      memberSince: (json['memberSince'] ?? '') as String,
      isGuest: (json['isGuest'] ?? false) as bool,
    );
  }

  static const guest = UserModel(
    uid: 'guest',
    username: 'guest',
    fullName: 'Tamu Muslimku',
    email: '',
    phone: '',
    bio: 'Masuk untuk menyimpan preferensi ibadah dan profil Anda.',
    memberSince: 'Hari ini',
    isGuest: true,
  );

  static const demo = UserModel(
    uid: 'demo-user',
    username: 'ahmadabdullah',
    fullName: 'Ahmad Abdullah',
    email: 'ahmad.abd@email.com',
    phone: '+62 812 3456 7890',
    bio:
        'Mencari ketenangan melalui zikir dan pengabdian. Terus belajar, selalu bersyukur.',
    memberSince: 'Ramadan 1445',
    isGuest: false,
  );
}
