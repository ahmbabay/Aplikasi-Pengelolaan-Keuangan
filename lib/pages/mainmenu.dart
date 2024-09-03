import 'package:flutter/material.dart';
import 'package:pengelolaan_keuangan_masjid/pages/about.dart';
import 'package:pengelolaan_keuangan_masjid/pages/home.dart';
import 'package:pengelolaan_keuangan_masjid/pages/profile.dart';

class Mainmenu extends StatelessWidget {
  final VoidCallback signOut;

  Mainmenu(this.signOut);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
            "Buku Keuangan Digital",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: signOut,
              tooltip: 'Sign Out',
            )
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            tabs: [
              Tab(
                icon: Icon(Icons.home),
                text: "Home",
              ),
              Tab(
                icon: Icon(Icons.person),
                text: "Profile",
              ),
              Tab(
                icon: Icon(Icons.info),
                text: "About",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Home(),
            Profile(),
            About(),
          ],
        ),
      ),
    );
  }
}
