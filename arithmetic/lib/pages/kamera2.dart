import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// import 'package:absensi/pages/checkout.dart';
import 'package:absensi/pages/arithmatic.dart';

class KameraPage extends StatefulWidget {
  const KameraPage({super.key});

  @override
  KameraPageState createState() => KameraPageState();
}

class KameraPageState extends State<KameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![1],
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final image = await _cameraController!.takePicture();
        
        // Arahkan ke halaman CheckOutPage dengan path gambar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArithmeticCompressionPage(
              imagePath: image.path,
            imageData: '',
            ),
          ),
        );
      } catch (e) {
        debugPrint("Error capturing image: $e");
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Out', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 33, 137, 235),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFF2A363B),
      body: Stack(
        children: [
          if (_cameraController != null &&
              _cameraController!.value.isInitialized)
            Positioned.fill(
              child: RotatedBox(
                quarterTurns: 1,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14),
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 55.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 78, 230),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 8,
                      ),
                      onPressed: _captureImage,
                      child: const Text('Check in', style: TextStyle(color: Colors.white, fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _captureImage,
                      child: const Text('Check out',
                          style: TextStyle(
                              color: Color(0xFF067E82), fontSize: 24)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
