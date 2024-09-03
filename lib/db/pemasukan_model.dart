class Pemasukan {
  int? idpemasukan;
  int userId;
  String jenisPemasukan;
  String deskripsiPemasukan;
  double jumlahPemasukan;
  String tanggalPemasukan;

  Pemasukan({
    this.idpemasukan,
    required this.userId,
    required this.jenisPemasukan,
    required this.deskripsiPemasukan,
    required this.jumlahPemasukan,
    required this.tanggalPemasukan,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'user_id': userId,
      'jenispemasukan': jenisPemasukan,
      'deskripsipemasukan': deskripsiPemasukan,
      'jumlahpemasukan': jumlahPemasukan,
      'tanggalpemasukan': tanggalPemasukan,
    };
    if (idpemasukan != null) {
      map['idpemasukan'] = idpemasukan;
    }
    return map;
  }

  factory Pemasukan.fromMap(Map<String, dynamic> map) {
    return Pemasukan(
      idpemasukan: map['idpemasukan'],
      userId: map['user_id'],
      jenisPemasukan: map['jenispemasukan'],
      deskripsiPemasukan: map['deskripsipemasukan'],
      jumlahPemasukan: map['jumlahpemasukan'],
      tanggalPemasukan: map['tanggalpemasukan'],
    );
  }
}
