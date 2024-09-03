import 'package:flutter/material.dart';
import 'package:pengelolaan_keuangan_masjid/constans/constans.dart';
import 'package:pengelolaan_keuangan_masjid/db/database_instance.dart';
import 'package:pengelolaan_keuangan_masjid/db/users_model.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nohpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  late BuildContext _scaffoldContext;
  bool _secureText = true;

  final DatabaseInstance _databaseInstance = DatabaseInstance();

  @override
  void initState() {
    super.initState();
    _databaseInstance.database;
  }

  void showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  Future<bool> register() async {
    User newUser = User(
      username: _usernameController.text,
      password: _passwordController.text,
      nama: _namaController.text,
      noHp: _nohpController.text,
      alamat: _alamatController.text,
    );

    try {
      await _databaseInstance.insertUser(newUser);
      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(SnackBar(
        content: Text('Berhasil Daftar Akun'),
        backgroundColor: Colors.green,
      ));
      _usernameController.clear();
      _passwordController.clear();
      _namaController.clear();
      _nohpController.clear();
      _alamatController.clear();
      return true;
    } catch (error) {
      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(SnackBar(
        content: Text('Failed to register user: $error'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Daftar Akun',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_secureText ? Icons.visibility_off : Icons.visibility),
                      onPressed: showHide,
                    ),
                  ),
                  obscureText: _secureText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Nama';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _nohpController,
                  decoration: InputDecoration(
                    labelText: 'No HP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan No Hp';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _alamatController,
                  decoration: InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.home),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Alamat';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = await register();
                      if (success) {
                        Navigator.pushReplacementNamed(context, HOME_SCREEN);
                      }
                    }
                  },
                  child: Text('Register'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}