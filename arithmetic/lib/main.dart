// import 'package:flutter/material.dart';
// import 'package:absensi/pages/dashboard.dart';
// import 'package:absensi/pages/checkout.dart';
// import 'package:absensi/pages/pendukung.dart';
// import 'package:absensi/pages/checkoutdinas.dart';
// import 'package:absensi/pages/lokasi.dart';
// import 'package:absensi/pages/kamera.dart';
// import 'package:absensi/pages/starter.dart';
// import 'package:absensi/pages/daftar.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Absensi App', // Tambahkan judul aplikasi
//       theme: ThemeData(
//         primarySwatch: Colors.teal, // Atur tema jika diinginkan
//       ),
//       home: const StarterPage(), // Setel halaman awal
//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           case '/dashboard':
//             return MaterialPageRoute(builder: (_) => const DashboardPage());
//           case '/checkout':
//             final imagePath = settings.arguments as String; // Ambil imagePath dari arguments
//             return MaterialPageRoute(
//               builder: (_) => CheckOutPage(imagePath: imagePath),
//             );
//           case '/dokumen':
//             return MaterialPageRoute(builder: (_) => const DokumenPage());
//           case '/checkoutdinas':
//             return MaterialPageRoute(builder: (_) => const CheckOutDinasPage());
//           case '/lokasi':
//             return MaterialPageRoute(builder: (_) => LokasiPage());
//           case '/kamera':
//             return MaterialPageRoute(builder: (_) => const KameraPage());
//           case '/starter':
//             return MaterialPageRoute(builder: (_) => const StarterPage());
//           case '/daftar':
//             return MaterialPageRoute(builder: (_) => DaftarPage());
//           default:
//             return MaterialPageRoute(builder: (_) => const StarterPage());
//         }
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:absensi/pages/dashboard.dart';
// import 'package:absensi/pages/checkout.dart';
import 'package:absensi/pages/pendukung.dart';
import 'package:absensi/pages/checkoutdinas.dart';
import 'package:absensi/pages/lokasi.dart';
import 'package:absensi/pages/kamera2.dart';
import 'package:absensi/pages/starter.dart';
import 'package:absensi/pages/daftar.dart';
import 'package:absensi/pages/arithmatic.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi App', 
      theme: ThemeData(
        primarySwatch: Colors.teal, 
      ),
      home: const StarterPage(), 
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardPage());
          case '/huffman':
            final args = settings.arguments as Map<String, String>; 
            final imagePath = args['imagePath']; 
            final imageData = args['imageData']; 
            return MaterialPageRoute(
              builder: (_) => ArithmeticCompressionPage(
                imagePath: imagePath!,
                imageData: imageData!,
              ),
            );
          case '/dokumen':
            return MaterialPageRoute(builder: (_) => const DokumenPage());
          case '/checkoutdinas':
            return MaterialPageRoute(builder: (_) => const CheckOutDinasPage());
          case '/lokasi':
            return MaterialPageRoute(builder: (_) => LokasiPage());
          case '/kamera':
            return MaterialPageRoute(builder: (_) => const KameraPage());
          case '/starter':
            return MaterialPageRoute(builder: (_) => const StarterPage());
          case '/daftar':
            return MaterialPageRoute(builder: (_) => DaftarPage());
          default:
            return MaterialPageRoute(builder: (_) => const StarterPage());
        }
      },
    );
  }
}