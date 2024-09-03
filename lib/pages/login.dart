import 'package:flutter/material.dart';
import 'package:pengelolaan_keuangan_masjid/db/database_instance.dart';
import 'package:pengelolaan_keuangan_masjid/db/users_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainmenu.dart';
import 'register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus { notSignIn, SignIn }

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  bool _secureText = true;
  bool _apiCall = false;
  final _key = GlobalKey<FormState>();

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    if (_key.currentState != null) {
      final form = _key.currentState!;
      if (form.validate()) {
        form.save();
        setState(() {
          _apiCall = true;
        });
        login();
      } else {
        _snackbar('Username atau Password Salah');
      }
    } else {
      _snackbar('Form is null');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  void _snackbar(String str) {
    if (str.isEmpty || _scaffoldState.currentContext == null) return;
    ScaffoldMessenger.of(_scaffoldState.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          str,
          style: TextStyle(fontSize: 15.0, color: Colors.white),
        ),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Future<void> login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _snackbar('Username dan Password Tidak Boleh Kosong');
      setState(() {
        _apiCall = false;
      });
      return;
    }

    try {
      bool success = await DatabaseInstance().loginUser(username, password);
      if (success) {
        User? user = await DatabaseInstance().getUserByUsername(username);
        if (user != null) {
          savePref(1, username, user.nama, user.id.toString(), user.noHp, user.alamat, "", 0.0);
          _snackbar('Login Berhasil');
          getPref();
        } else {
          _snackbar('Login gagal: User Tidak Ditemukan');
        }
      } else {
        _snackbar('Login gagal: Username atau Password salah');
      }
    } catch (e) {
      _snackbar('Error during login: $e');
    } finally {
      setState(() {
        _apiCall = false;
      });
    }
  }

  savePref(int value, String username, String nama, String id, String nohp,
      String alamat, String foto, double saldoakhir) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("nama", nama);
      preferences.setString("username", username);
      preferences.setString("id", id);
      preferences.setString("nohp", nohp);
      preferences.setString("alamat", alamat);
      preferences.commit();
    });
  }

  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      _loginStatus = (value == 1) ? LoginStatus.SignIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    setState(() {
      _apiCall = false;
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          key: _scaffoldState,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Form(
                key: _key,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/masjid.png',
                      width: 200,
                      height: 200,
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
                        filled: true,
                        fillColor: Colors.white,
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
                        filled: true,
                        fillColor: Colors.white,
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
                    ElevatedButton(
                      onPressed: check,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: _apiCall
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              "Masuk",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        "Daftar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case LoginStatus.SignIn:
        return Mainmenu(signOut);
    }
  }
}
