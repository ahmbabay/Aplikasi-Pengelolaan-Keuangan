import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Database _database;
  String username = "";
  String nama = "";
  String nohp = "";
  String alamat = "";
  double saldoakhir = 0.0;
  double saldoTabungan = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'kas.db');

    _database = await openDatabase(path);

    await _getDataAndUseIt();
  }

  Future<void> _getDataAndUseIt() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? currentUsername = preferences.getString("username");

    if (currentUsername == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }


    List<Map> userData = await _database.query('users', where: 'username = ?', whereArgs: [currentUsername]);
    if (userData.isNotEmpty) {
      setState(() {
        username = userData[0]['username'];
        nama = userData[0]['nama'];
        nohp = userData[0]['no_hp'];
        alamat = userData[0]['alamat'];
      });
    }

    List<Map> pemasukanData = await _database.query('pemasukan');
    double totalPemasukan = pemasukanData.isNotEmpty
        ? pemasukanData.map((e) => e['jumlahpemasukan'] as double).reduce((a, b) => a + b)
        : 0.0;

    List<Map> pengeluaranData = await _database.query('pengeluaran');
    double totalPengeluaran = pengeluaranData.isNotEmpty
        ? pengeluaranData.map((e) => e['jumlahpengeluaran'] as double).reduce((a, b) => a + b)
        : 0.0;

    List<Map> tabunganData = await _database.query('tabungan');
    saldoTabungan = tabunganData.isNotEmpty
        ? tabunganData.map((e) => e['jumlahtabungan'] as double).reduce((a, b) => a + b)
        : 0.0;


    saldoakhir = totalPemasukan - totalPengeluaran;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/user.png'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        nama,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "No HP",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                nohp,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Alamat",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                alamat,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                Divider(color: Colors.grey[300], thickness: 2),
                buildBalanceSection(
                  "Saldo Masjid",
                  saldoakhir,
                  Colors.black,
                ),
                SizedBox(height: 20),
                Divider(color: Colors.grey[300], thickness: 2),
                buildBalanceSection(
                  "Saldo Tabungan Yatim & Maulid",
                  saldoTabungan,
                  Colors.black,
                ),
              ],
            ),
          ),
  );
}

  Widget buildBalanceSection(String title, double balance, Color color) {
    NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 5),
        Text(
          currencyFormat.format(balance),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
