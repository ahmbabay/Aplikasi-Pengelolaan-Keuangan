import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class About extends StatefulWidget {

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/masjid.png',
                    width: 150,
                    height: 150,
                  ),
                  Text(
                    'Masjid Al-Muhajirin',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Masjid Al-Muhajirin, yang didirikan pada tahun 1977 di atas tanah wakaf pemberian H. Muhajir, merupakan simbol kebersamaan dan dedikasi masyarakat Kesehatan Bintaro, Kecamatan Pesanggrahan, Kabupaten Jakarta Selatan. Proses pembangunan masjid ini mencerminkan semangat gotong royong warga setempat, yang menjadikannya pusat kegiatan keagamaan dan sosial. Selain shalat berjamaah lima waktu, masjid ini juga menjadi tempat pelaksanaan shalat sunnah Idul Fitri dan Idul Adha, serta berbagai pengajian rutin mingguan yang memperdalam ilmu agama dan mempererat tali silaturahmi antarwarga.',
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}