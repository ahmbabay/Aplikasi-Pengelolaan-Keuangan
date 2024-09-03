import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pengelolaan_keuangan_masjid/pages/laporan.dart';
import 'package:pengelolaan_keuangan_masjid/pages/pemasukan.dart';
import 'package:pengelolaan_keuangan_masjid/pages/pengeluaran.dart';
import 'package:pengelolaan_keuangan_masjid/pages/tabungan.dart';

class Home extends StatelessWidget {
  static final List<String> imgSlider = ['1.jpg', '2.jpg', '3.jpg', '4.jpg', '5.jpg', '6.jpg'];

  @override
  Widget build(BuildContext context) {
    final CarouselSlider autoPlayImage = CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
      ),
      items: imgSlider.map((fileImage) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/slider/$fileImage'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            margin: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: AssetImage('assets/slider/$fileImage'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }).toList(),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Masjid Al-Muhajirin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 8 / 15,
              child: autoPlayImage,
            ),
            SizedBox(height: 10),
            Text(
              'Menu Utama',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      _buildMenuItem(Icons.call_received, 'Pemasukan', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PemasukanScreen()),
                        );
                      }),
                      SizedBox(height: 10), 
                      _buildMenuItem(Icons.attach_money, 'Tabungan', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TabunganPage()),
                        );
                      }),
                    ],
                  ),
                  SizedBox(width: 35), 
                  Column(
                    children: [
                      _buildMenuItem(Icons.call_made, 'Pengeluaran', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PengeluaranScreen()),
                        );
                      }),
                      SizedBox(height: 10), 
                      _buildMenuItem(Icons.note, 'Laporan', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Laporan()),
                        );
                      }),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
