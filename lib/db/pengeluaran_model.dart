class Pengeluaran {
  int? idpengeluaran;
  int userId;
  String jenisPengeluaran;
  String deskripsiPengeluaran;
  double jumlahPengeluaran;
  String tanggalPengeluaran;

  Pengeluaran({
    this.idpengeluaran,
    required this.userId,
    required this.jenisPengeluaran,
    required this.deskripsiPengeluaran,
    required this.jumlahPengeluaran,
    required this.tanggalPengeluaran,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'user_id': userId,
      'jenispengeluaran': jenisPengeluaran,
      'deskripsipengeluaran': deskripsiPengeluaran,
      'jumlahpengeluaran': jumlahPengeluaran,
      'tanggalpengeluaran': tanggalPengeluaran,
    };
    if (idpengeluaran != null) {
      map['idpengeluaran'] = idpengeluaran;
    }
    return map;
  }

  factory Pengeluaran.fromMap(Map<String, dynamic> map) {
    return Pengeluaran(
      idpengeluaran: map['idpengeluaran'],
      userId: map['user_id'],
      jenisPengeluaran: map['jenispengeluaran'],
      deskripsiPengeluaran: map['deskripsipengeluaran'],
      jumlahPengeluaran: map['jumlahpengeluaran'],
      tanggalPengeluaran: map['tanggalpengeluaran'],
    );
  }
}
