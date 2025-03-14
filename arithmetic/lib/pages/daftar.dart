import 'package:flutter/material.dart';
import 'package:absensi/pages/dashboard.dart';

class DaftarPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  DaftarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang Gambar
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/latar.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 100, // Sesuaikan posisi vertikal logo
            left: MediaQuery.of(context).size.width / 2 - 50, // Mengatur posisi horizontal logo
            child: Container(
              width: 100, // Sesuaikan lebar logo sesuai kebutuhan
              height: 100, // Sesuaikan tinggi logo sesuai kebutuhan
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pemkot_mlg.png'), // Ganti dengan path logo Pemkot Malang
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Konten Utama
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buat Akun Baru',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField('Email', emailController),
                      _buildTextField('No. Telepon', phoneController),
                      _buildTextField('Nama Pegawai', nameController),
                      _buildTextField('Password', passwordController, isPassword: true),
                      _buildTextField('Konfirmasi Password', confirmPasswordController, isPassword: true),

                      const SizedBox(height: 30),

                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_validateInputs(context)) {
                              // Lanjutkan ke halaman selanjutnya jika semua input valid
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Akun berhasil dibuat!')),
                              );
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DashboardPage()),
                                );
                              });
                            }
                          },
                          child: const Text(
                            'DAFTAR SEKARANG',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller, // Hubungkan controller dengan TextField
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  bool _validateInputs(BuildContext context) {
    // Memeriksa apakah semua kolom diisi
    if (emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom!')),
      );
      return false;
    }
    return true;
  }
}