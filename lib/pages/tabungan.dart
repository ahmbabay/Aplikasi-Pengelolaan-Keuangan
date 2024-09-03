import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pengelolaan_keuangan_masjid/db/database_instance.dart';
import 'package:pengelolaan_keuangan_masjid/db/tabungan_model.dart';
import 'package:printing/printing.dart';

class TabunganPage extends StatefulWidget {
  @override
  _TabunganPageState createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage> {
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  List<Tabungan> _tabunganList = [];
  List<Tabungan> _filteredTabunganList = [];
  List<String> _months = List.generate(12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1)));
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  List<int> _years = List.generate(20, (index) => DateTime.now().year - index);
  int _selectedYear = DateTime.now().year;
  List<int> _days = List.generate(DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day,(index) => index + 1,);
  int _selectedDay = DateTime.now().day;
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();
    _fetchTabungan();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _fetchTabungan() async {
    List<Tabungan> tabunganList = await DatabaseInstance().getTabungan();
    setState(() {
      _tabunganList = tabunganList;
      _filterTabunganByMonth(_selectedMonth);
    });
  }

  void _filterTabunganByMonth(String selectedMonth) {
    List<Tabungan> filteredList = _tabunganList.where((tabungan) {
      DateTime date;
      try {
        date = DateTime.parse(tabungan.tanggalTabungan);
      } catch (e) {
        return false;
      }
      return DateFormat('MMMM').format(date) == selectedMonth;
    }).toList();

    setState(() {
      _filteredTabunganList = filteredList;
    });
  }

  void _filterTabunganByYear(int selectedYear) {
    List<Tabungan> filteredList = _tabunganList.where((tabungan) {
      DateTime date;
      try {
        date = DateTime.parse(tabungan.tanggalTabungan);
      } catch (e) {
        return false;
      }
      return date.year == selectedYear;
    }).toList();

    setState(() {
      _filteredTabunganList = filteredList;
    });
  }

  void _filterTabungan() {
  List<Tabungan> filteredList = _tabunganList.where((tabungan) {
    DateTime date;
    try {
      date = DateTime.parse(tabungan.tanggalTabungan);
    } catch (e) {
      return false;
    }
    return (DateFormat('MMMM').format(date) == _selectedMonth) &&
           (date.year == _selectedYear) &&
           (date.day == _selectedDay);
  }).toList();

  setState(() {
    _filteredTabunganList = filteredList;
  });
}


  Future<void> _saveTabungan() async {
    if (_validateInputs(context)) {
      setState(() {
        _isLoading = true;
      });

      String jumlah = _jumlahController.text;
      String nama = _namaController.text;
      String tanggal = _selectedDate?.toIso8601String().split('T')[0] ?? '';

      Tabungan tabungan = Tabungan(
        userId: 1,
        namaJamaah: nama,
        jumlahTabungan: double.parse(jumlah),
        tanggalTabungan: tanggal,
      );

      try {
        await DatabaseInstance().insertTabungan(tabungan);

        setState(() {
          _isLoading = false;
        });
        showErrorSnackbar(context, 'Data Tabungan berhasil disimpan');
        _jumlahController.clear();
        _namaController.clear();
        setState(() {
          _selectedDate = null;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        showErrorSnackbar(context, 'Terjadi kesalahan: $e');
      }

      await _fetchTabungan();
    }
  }

  bool _validateInputs(BuildContext context) {
    if (_jumlahController.text.isEmpty || _namaController.text.isEmpty || _selectedDate == null) {
      showErrorSnackbar(context, 'Mohon lengkapi semua bidang');
      return false;
    }
    return true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _deleteTabungan(int id) async {
    try {
      await DatabaseInstance().deleteTabungan(id);
      showErrorSnackbar(context, 'Data Tabungan berhasil dihapus');
      await _fetchTabungan();
    } catch (e) {
      showErrorSnackbar(context, 'Terjadi kesalahan saat menghapus: $e');
    }
  }

  Future<void> _generateAndPrintDailyPDF() async {
  final pdf = pw.Document();

  final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Regular.ttf'));
  final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Bold.ttf'));

  double totalTabungan = _filteredTabunganList.fold(0, (prev, item) => prev + item.jumlahTabungan);

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Laporan Tabungan Harian Yatim & Maulid Masjid Al-Muhajirin ($_selectedDay ${_selectedMonth} ${_selectedYear})',
              style: pw.TextStyle(font: fontBold, fontSize: 24),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Laporan Tabungan Harian ($_selectedDay ${_selectedMonth} ${_selectedYear})',
              style: pw.TextStyle(font: fontBold, fontSize: 20),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Jumlah', 'Nama', 'Tanggal'],
              data: _filteredTabunganList
                .map((item) => [
                  currencyFormat.format(item.jumlahTabungan),
                  item.namaJamaah,
                  item.tanggalTabungan,
                ])
                .toList(),
              headerStyle: pw.TextStyle(font: fontBold),
              cellStyle: pw.TextStyle(font: fontRegular),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Keseluruhan: ${currencyFormat.format(totalTabungan)}',
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

  Future<void> _generateAndPrintPDF() async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Regular.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Bold.ttf'));

    List<Tabungan> filteredList = _tabunganList.where((tabungan) {
      DateTime date;
      try {
        date = DateTime.parse(tabungan.tanggalTabungan);
      } catch (e) {
        return false;
      }
      return DateFormat('MMMM').format(date) == _selectedMonth;
    }).toList();

    setState(() {
      _filteredTabunganList = filteredList;
    });

    double totalTabungan = _filteredTabunganList.fold(0, (prev, item) => prev + item.jumlahTabungan);

    pdf.addPage(
        pw.Page(
        build: (pw.Context context) {
            return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
                pw.Text(
                'Laporan Tabungan Yatim & Maulid Masjid Al-Muhajirin ($_selectedMonth, $_selectedYear)',
                style: pw.TextStyle(font: fontBold, fontSize: 24),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                'Laporan Tabungan ($_selectedMonth $_selectedYear)',
                style: pw.TextStyle(font: fontBold, fontSize: 20),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                headers: ['Jumlah', 'Nama', 'Tanggal'],
                data: _filteredTabunganList
                    .map((item) => [
                        currencyFormat.format(item.jumlahTabungan),
                        item.namaJamaah,
                        item.tanggalTabungan,
                    ])
                    .toList(),
                headerStyle: pw.TextStyle(font: fontBold),
                cellStyle: pw.TextStyle(font: fontRegular),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                'Total Keseluruhan: ${currencyFormat.format(totalTabungan)}',
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

    List<Tabungan> filteredByYearList = _tabunganList.where((tabungan) {
        DateTime date;
        try {
            date = DateTime.parse(tabungan.tanggalTabungan);
        } catch (e) {
            return false;
        }
        return date.year == _selectedYear;
    }).toList();

    double totalTabungan = filteredByYearList.fold(0, (prev, item) => prev + item.jumlahTabungan);

    pdf.addPage(
        pw.Page(
        build: (pw.Context context) {
            return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
                pw.Text(
                'Laporan Tabungan Yatim & Maulid Masjid Al-Muhajirin ($_selectedYear)',
                style: pw.TextStyle(font: fontBold, fontSize: 24),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                'Laporan Tabungan Tahun $_selectedYear',
                style: pw.TextStyle(font: fontBold, fontSize: 20),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                headers: ['Jumlah', 'Nama', 'Tanggal'],
                data: filteredByYearList
                    .map((item) => [
                        currencyFormat.format(item.jumlahTabungan),
                        item.namaJamaah,
                        item.tanggalTabungan,
                    ])
                    .toList(),
                headerStyle: pw.TextStyle(font: fontBold),
                cellStyle: pw.TextStyle(font: fontRegular),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                'Total Keseluruhan: ${currencyFormat.format(totalTabungan)}',
                style: pw.TextStyle(font: fontBold),
                ),
            ],
            );
        },
        ),
    );

    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
    );
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Tabungan Yatim & Maulid'),
      backgroundColor: Colors.teal,
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Uang (Rp)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Tanggal'
                            : 'Tanggal: ${_selectedDate?.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Tanggal'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveTabungan,
                    icon: Icon(Icons.save),
                    label: Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                      textStyle: TextStyle(fontSize: 16),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pilih Hari:'),
                          DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedDay,
                            items: _days.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedDay = newValue!;
                                _filterTabungan();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pilih Bulan:'),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedMonth,
                            items: _months.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedMonth = newValue!;
                                _filterTabungan();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pilih Tahun:'),
                          DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedYear,
                            items: _years.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedYear = newValue!;
                                _filterTabungan();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'List Tabungan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: _buildTabunganList(),
                ),
              ],
            ),
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        final action = await _showPrintDialog(context);
        if (action == 'month') {
          await _generateAndPrintPDF();
        } else if (action == 'year') {
          await _generateAndPrintYearlyPDF();
        } else if (action == 'day') {
          await _generateAndPrintDailyPDF();
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
            child: Text('Hari'),
            onPressed: () {
              Navigator.of(context).pop('day');
            },
          ),
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

  Widget _buildTabunganList() {
    return ListView.builder(
      itemCount: _filteredTabunganList.length,
      itemBuilder: (context, index) {
        final tabungan = _filteredTabunganList[index];
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ListTile(
            title: Text(
              'Nama: ${tabungan.namaJamaah}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Jumlah: ${currencyFormat.format(tabungan.jumlahTabungan)}\n'
              'Tanggal: ${tabungan.tanggalTabungan}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                if (tabungan.id != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Konfirmasi'),
                        content: Text('Apakah Anda yakin ingin menghapus ${tabungan.namaJamaah.toLowerCase()} ini?'),
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
                              _deleteTabungan(tabungan.id!);
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showErrorSnackbar(context, 'ID tabungan tidak valid.');
                }
              },
            ),
          ),
        );
      },
    );
  }
}