class Tabungan {
  final int? id;
  final int userId;
  final String namaJamaah;
  final double jumlahTabungan;
  final String tanggalTabungan;

  Tabungan({
    this.id,
    required this.userId,
    required this.namaJamaah,
    required this.jumlahTabungan,
    required this.tanggalTabungan,
  });

  Map<String, dynamic> toMap() {
    return {
      'idtabungan': id,
      'user_id': userId,
      'namajamaah': namaJamaah,
      'jumlahtabungan': jumlahTabungan,
      'tanggaltabungan': tanggalTabungan,
    };
  }

  factory Tabungan.fromMap(Map<String, dynamic> map) {
    return Tabungan(
      id: map['idtabungan'],
      userId: map['user_id'] ?? 0, 
      namaJamaah: map['namajamaah'] ?? '', 
      jumlahTabungan: map['jumlahtabungan']?.toDouble() ?? 0.0,
      tanggalTabungan: map['tanggaltabungan'] ?? '',
    );
  }
}
