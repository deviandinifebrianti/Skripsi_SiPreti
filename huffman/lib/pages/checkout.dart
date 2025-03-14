// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:absensi/pages/kamera.dart';

// class CheckOutPage extends StatelessWidget {
//   final String imagePath;
//   final String imageData;

//   const CheckOutPage({Key? key, required this.imagePath, required this.imageData}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final DateTime now = DateTime.now();
//     final String formattedDate = "${now.day} ${_getMonthName(now.month)} ${now.year}";
//     final String formattedTime = "${now.hour}:${now.minute.toString().padLeft(2, '0')} WIB";

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Check Out',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color.fromARGB(255, 33, 137, 235),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Image.asset(
//               'assets/pemkot_mlg.png',
//               height: 40,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Image.asset(
//               'assets/profil.png',
//               height: 40,
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: double.infinity,
//                 height: 250,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     image: FileImage(File(imagePath)), // Menampilkan gambar
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             const Text(
//               'Absensi Reguler',
//               style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   formattedDate, // Menggunakan formattedDate
//                   style: const TextStyle(fontSize: 20),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 const Icon(Icons.access_time, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   formattedTime, // Menggunakan formattedTime
//                   style: const TextStyle(fontSize: 20),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Icon(Icons.location_on, size: 20), // Ikon alamat
//                 SizedBox(width: 8), // Jarak antara ikon dan teks
//                 Expanded(
//                   // Agar teks bisa membungkus dengan baik
//                   child: Text(
//                     'KANTOR WALIKOTA MALANG, \nJalan Majapahit, RW. 08, KEL. KIDUL DALEM, \nKOTA MALANG, Bareng, Malang, \nJawa Timur, 65119, Indonesia',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             Row(
//               children: const [
//                 Icon(Icons.emoji_emotions,
//                     size: 20, color: Colors.green), // Ikon tersenyum
//                 SizedBox(width: 8), // Jarak antara ikon dan teks
//                 Text(
//                   'Data Valid',
//                   style: TextStyle(fontSize: 20, color: Colors.green),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Tombol Aksi
//             Center(
//               child: Column(
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => const KameraPage()),
//   );
//                     },
//                     child: const Text(
//                       'FOTO ULANG',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       foregroundColor: const Color.fromARGB(255, 79, 152, 236),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                         side: const BorderSide(color: Colors.blue, width: 2),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   OutlinedButton(
//                     onPressed: () {
//                       Navigator.pushReplacementNamed(context, '/dashboard');
//                     },
//                     child: const Text(
//                       'SELESAI CHECK OUT',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   OutlinedButton(
//                     onPressed: () {
//                       Navigator.pushReplacementNamed(context, '/dashboard');
//                     },
//                     child: const Text(
//                       'BATAL CHECK OUT',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       backgroundColor: const Color.fromARGB(255, 146, 25, 16),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getMonthName(int month) {
//     const List<String> monthNames = [
//       'Januari', 'Februari', 'Maret', 'April',
//       'Mei', 'Juni', 'Juli', 'Agustus',
//       'September', 'Oktober', 'November', 'Desember'
//     ];
//     return monthNames[month - 1];
//   }
// }

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:absensi/pages/kamera2.dart';

class CheckOutPage extends StatelessWidget {
  final String imagePath;
  final String imageData;

  const CheckOutPage(
      {Key? key, required this.imagePath, required this.imageData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('Image Path: $imagePath');
    debugPrint('Image Data: $imageData');
    final DateTime now = DateTime.now();
    final String formattedDate =
        "${now.day} ${_getMonthName(now.month)} ${now.year}";
    final String formattedTime =
        "${now.hour}:${now.minute.toString().padLeft(2, '0')} WIB";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Check Out',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 137, 235),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset(
              'assets/pemkot_mlg.png',
              height: 40,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/profil.png',
              height: 40,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image:
                        FileImage(File(imagePath)), // untuk menampilkan gambar
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Data yang diterima: $imageData'),
            const Text(
              'Absensi Reguler',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  formattedDate, // pakai formattedDate
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(
                  formattedTime, // pakai formattedTime
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.location_on, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'KANTOR WALIKOTA MALANG, \nJalan Majapahit, RW. 08, KEL. KIDUL DALEM, \nKOTA MALANG, Bareng, Malang, \nJawa Timur, 65119, Indonesia',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.emoji_emotions, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Data Valid',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const KameraPage()),
                      );
                    },
                    child: const Text(
                      'FOTO ULANG',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      foregroundColor: const Color.fromARGB(255, 79, 152, 236),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: const Text(
                      'SELESAI CHECK OUT',
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
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: const Text(
                      'BATAL CHECK OUT',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color.fromARGB(255, 146, 25, 16),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return monthNames[month - 1];
  }
}
