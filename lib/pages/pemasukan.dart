import 'package:flutter/material.dart';
import 'package:pengelolaan_keuangan_masjid/db/database_instance.dart';
import 'package:pengelolaan_keuangan_masjid/db/pemasukan_model.dart';

class PemasukanScreen extends StatefulWidget {
  @override
  _PemasukanScreenState createState() => _PemasukanScreenState();
}

class _PemasukanScreenState extends State<PemasukanScreen> {
  final DatabaseInstance _databaseInstance = DatabaseInstance();
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _jenisController.dispose();
    _jumlahController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _savePemasukan(BuildContext context) async {
    if (_validateInputs()) {
      if (_isLoading) {
        return;
      }
      setState(() {
        _isLoading = true;
      });
      
      String jenis = _jenisController.text;
      String jumlah = _jumlahController.text;
      String deskripsi = _deskripsiController.text;
      String tanggal = _selectedDate?.toIso8601String().split('T')[0] ?? '';

      Pemasukan pemasukan = Pemasukan(
        tanggalPemasukan: tanggal,
        jumlahPemasukan: double.parse(jumlah),
        deskripsiPemasukan: deskripsi,
        userId: 0,
        jenisPemasukan: jenis,
      );

      try {
        await _databaseInstance.insertPemasukan(pemasukan);

        setState(() {
          _isLoading = false;
        });
        showErrorSnackbar(context, 'Data pemasukan berhasil disimpan');
        _jenisController.clear();
        _jumlahController.clear();
        _deskripsiController.clear();
        setState(() {
          _selectedDate = null;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        showErrorSnackbar(context, 'Terjadi kesalahan: $e');
      }
    }
  }

  bool _validateInputs() {
    if (_jenisController.text.isEmpty || 
        _jumlahController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _selectedDate == null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Pemasukan'),
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
                    controller: _jenisController,
                    decoration: InputDecoration(
                      labelText: 'Jenis Pemasukan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.call_received)
                    ),
                  ),
                  SizedBox(height: 10),
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
                    controller: _deskripsiController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
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
                        child: Text('Pilih Tanggal'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _savePemasukan(context),
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
                ],
              ),
            ),
    );
  }
}
