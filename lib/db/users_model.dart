class User {
  int? id;
  String username;
  String password;
  String nama;
  String noHp;
  String alamat;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.noHp,
    required this.alamat,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'username': username,
      'password': password,
      'nama': nama,
      'no_hp': noHp,
      'alamat': alamat,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      nama: map['nama'],
      noHp: map['no_hp'],
      alamat: map['alamat'],
    );
  }
}
