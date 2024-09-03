import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:pengelolaan_keuangan_masjid/db/database_instance.dart';
import 'package:pengelolaan_keuangan_masjid/db/pemasukan_model.dart';
import 'package:pengelolaan_keuangan_masjid/db/pengeluaran_model.dart';
import 'package:printing/printing.dart';

class Laporan extends StatefulWidget {
  @override
  _LaporanState createState() => _LaporanState();
}

class _LaporanState extends State<Laporan> {
  List<Pemasukan> _pemasukan = [];
  List<Pengeluaran> _pengeluaran = [];
  bool _isLoading = false;
  final DatabaseInstance _databaseInstance = DatabaseInstance();
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  int _selectedYear = DateTime.now().year;
  List<String> _months = List.generate(12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1)));
  List<int> _years = List.generate(10, (index) => DateTime.now().year - index);
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _fetchLaporan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pemasukanData = await _databaseInstance.getAllPemasukan();
      final pengeluaranData = await _databaseInstance.getAllPengeluaran();

      setState(() {
        _pemasukan = pemasukanData;
        _pengeluaran = pengeluaranData;
      });
    } catch (error) {
      _showErrorDialog(context, 'Terjadi kesalahan: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<Pemasukan> _filterPemasukanByMonth(List<Pemasukan> data) {
    return data.where((item) {
      final date = DateFormat('yyyy-MM-dd').parse(item.tanggalPemasukan);
      final month = DateFormat('MMMM').format(date);
      final year = DateFormat('yyyy').format(date);
      return month == _selectedMonth && year == _selectedYear.toString();
    }).toList();
  }

  List<Pengeluaran> _filterPengeluaranByMonth(List<Pengeluaran> data) {
    return data.where((item) {
      final date = DateFormat('yyyy-MM-dd').parse(item.tanggalPengeluaran);
      final month = DateFormat('MMMM').format(date);
      final year = DateFormat('yyyy').format(date);
      return month == _selectedMonth && year == _selectedYear.toString();
    }).toList();
  }

  Future<void> _generateAndPrintPDF() async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Regular.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Bold.ttf'));

    final filteredPemasukan = _filterPemasukanByMonth(_pemasukan);
    final filteredPengeluaran = _filterPengeluaranByMonth(_pengeluaran);

    double totalPemasukan = filteredPemasukan.fold(0, (prev, item) => prev + item.jumlahPemasukan);
    double totalPengeluaran = filteredPengeluaran.fold(0, (prev, item) => prev + item.jumlahPengeluaran);

    double totalKeseluruhan = totalPemasukan + totalPengeluaran;
    double totalSaldoAkhir = totalPemasukan - totalPengeluaran;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Keuangan Masjid Al-Muhajirin ($_selectedMonth $_selectedYear)',
                style: pw.TextStyle(font: fontBold, fontSize: 24),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Laporan Pemasukan',
                style: pw.TextStyle(font: fontBold, fontSize: 20),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Jenis Pemasukan', 'Jumlah', 'Deskripsi', 'Tanggal'],
                data: filteredPemasukan
                    .map((item) => [
                          item.jenisPemasukan,
                          currencyFormat.format(item.jumlahPemasukan),
                          item.deskripsiPemasukan,
                          item.tanggalPemasukan,
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(font: fontBold),
                cellStyle: pw.TextStyle(font: fontRegular),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Pemasukan: ${currencyFormat.format(totalPemasukan)}',
                style: pw.TextStyle(font: fontBold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Laporan Pengeluaran',
                style: pw.TextStyle(font: fontBold, fontSize: 20),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Jenis Pengeluaran', 'Jumlah', 'Deskripsi', 'Tanggal'],
                data: filteredPengeluaran
                    .map((item) => [
                          item.jenisPengeluaran,
                          currencyFormat.format(item.jumlahPengeluaran),
                          item.deskripsiPengeluaran,
                          item.tanggalPengeluaran,
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(font: fontBold),
                cellStyle: pw.TextStyle(font: fontRegular),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Pengeluaran: ${currencyFormat.format(totalPengeluaran)}',
                style: pw.TextStyle(font: fontBold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Keseluruhan: ${currencyFormat.format(totalKeseluruhan)}',
                style: pw.TextStyle(font: fontBold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Sisa Saldo: ${currencyFormat.format(totalSaldoAkhir)}',
                style: pw.TextStyle(font: fontBold),
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  Future<void> _generateAndPrintYearlyPDF() async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Regular.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Bold.ttf'));

    double totalPemasukan = _pemasukan.fold(0, (prev, item) => prev + item.jumlahPemasukan);
    double totalPengeluaran = _pengeluaran.fold(0, (prev, item) => prev + item.jumlahPengeluaran);

    double totalKeseluruhan = totalPemasukan + totalPengeluaran;
    double totalSaldoAkhir = totalPemasukan - totalPengeluaran;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Keuangan Masjid Al-Muhajirin ($_selectedYear)',
                style: pw.TextStyle(font: fontBold, fontSize: 24),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Laporan Pemasukan',
                style: pw.TextStyle(font: fontBold, fontSize: 20),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Jenis Pemasukan', 'Jumlah', 'Deskripsi', 'Tanggal'],
                data: _pemasukan
                    .map((item) => [
                          item.jenisPemasukan,
                          currencyFormat.format(item.jumlahPemasukan),
                          item.deskripsiPemasukan,
                          item.tanggalPemasukan,
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(font: fontBold),
                cellStyle: pw.TextStyle(font: fontRegular),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Pemasukan: ${currencyFormat.format(totalPemasukan)}',
                style: pw.TextStyle(font: fontBold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Laporan Pengeluaran',
                style: pw.TextStyle(font: fontBold, fontSize: 20),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Jenis Pengeluaran', 'Jumlah', 'Deskripsi', 'Tanggal'],
                data: _pengeluaran
                    .map((item) => [
                          item.jenisPengeluaran,
                          currencyFormat.format(item.jumlahPengeluaran),
                          item.deskripsiPengeluaran,
                          item.tanggalPengeluaran,
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(font: fontBold),
                cellStyle: pw.TextStyle(font: fontRegular),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Pengeluaran: ${currencyFormat.format(totalPengeluaran)}',
                style: pw.TextStyle(font: fontBold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Keseluruhan: ${currencyFormat.format(totalKeseluruhan)}',
                style: pw.TextStyle(font: fontBold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Sisa Saldo: ${currencyFormat.format(totalSaldoAkhir)}',
                style: pw.TextStyle(font: fontBold),
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  Future<void> _deletePemasukan(int id) async {
    try {
      await _databaseInstance.deletePemasukan(id);
      showErrorSnackbar(context, 'Data Pemasukan berhasil dihapus');
      _fetchLaporan();
    } catch (error) {
      _showErrorDialog(context, 'Terjadi kesalahan saat menghapus pemasukan: $error');
    }
  }

  Future<void> _deletePengeluaran(int id) async {
    try {
      await _databaseInstance.deletePengeluaran(id);
      showErrorSnackbar(context, 'Data Pengeluaran berhasil dihapus');
      _fetchLaporan();
    } catch (error) {
      _showErrorDialog(context, 'Terjadi kesalahan saat menghapus pengeluaran: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Keuangan'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: _selectedMonth,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMonth = newValue!;
                            });
                          },
                          items: _months.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: 20),
                        DropdownButton<int>(
                          value: _selectedYear,
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedYear = newValue!;
                            });
                          },
                          items: _years.map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    _buildLaporan('Pemasukan', _filterPemasukanByMonth(_pemasukan), Colors.green),
                    SizedBox(height: 20),
                    _buildLaporan('Pengeluaran', _filterPengeluaranByMonth(_pengeluaran), Colors.red),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final action = await _showPrintDialog(context);
          if (action == 'month') {
            await _generateAndPrintPDF();
          } else if (action == 'year') {
            await _generateAndPrintYearlyPDF();
          }
        },
        child: Icon(Icons.print),
        backgroundColor: Colors.teal,
        tooltip: 'Cetak Laporan',
      ),
    );
  }

  Future<String?> _showPrintDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Cetak Laporan'),
        content: Text('Pilih jenis laporan yang ingin dicetak:'),
        actions: <Widget>[
          TextButton(
            child: Text('Bulan'),
            onPressed: () {
              Navigator.of(context).pop('month');
            },
          ),
          TextButton(
            child: Text('Tahun'),
            onPressed: () {
              Navigator.of(context).pop('year');
            },
          ),
        ],
      );
    },
  );
}

  Widget _buildLaporan(String title, List<dynamic> data, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${title == 'Pemasukan' ? 'Jenis Pemasukan: ${data[index].jenisPemasukan}' : 'Jenis Pengeluaran: ${data[index].jenisPengeluaran}'}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Jumlah: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(
                          title == 'Pemasukan' ? data[index].jumlahPemasukan : data[index].jumlahPengeluaran)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${title == 'Pemasukan' ? 'Deskripsi: ${data[index].deskripsiPemasukan}' : 'Deskripsi: ${data[index].deskripsiPengeluaran}'}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tanggal: ${title == 'Pemasukan' ? data[index].tanggalPemasukan : data[index].tanggalPengeluaran}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Konfirmasi'),
                                content: Text('Apakah Anda yakin ingin menghapus ${title.toLowerCase()} ini?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Batal'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Hapus'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      if (title == 'Pemasukan' && data[index].idpemasukan != null) {
                                        _deletePemasukan(data[index].idpemasukan!);
                                      } else if (title == 'Pengeluaran' && data[index].idpengeluaran != null) {
                                        _deletePengeluaran(data[index].idpengeluaran!);
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}