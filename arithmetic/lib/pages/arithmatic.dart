
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class ArithmeticCoder {
  final Map<String, double> probabilities;
  late Map<String, double> cumulativeProbabilities;

  ArithmeticCoder(this.probabilities) {
    cumulativeProbabilities = _getCumulativeProbabilities();
  }

  Map<String, double> _getCumulativeProbabilities() {
    double total = 0.0;
    Map<String, double> cumulative = {};
    probabilities.forEach((symbol, prob) {
      total += prob;
      cumulative[symbol] = total;
    });
    return cumulative;
  }

  double encode(String data) {
    double low = 0.0;
    double high = 1.0;

    for (int i = 0; i < data.length; i++) {
      String symbol = data[i];
      double range = high - low;
      high = low + range * cumulativeProbabilities[symbol]!;
      low = low + range * (cumulativeProbabilities[symbol]! - probabilities[symbol]!);
    }

    return (low + high) / 2;
  }
}

class ArithmeticCompressionPage extends StatefulWidget {
  final String imagePath;
  final String imageData;

  const ArithmeticCompressionPage({
    Key? key,
    required this.imagePath,
    required this.imageData,
  }) : super(key: key);

  @override
  _ArithmeticCompressionPageState createState() => _ArithmeticCompressionPageState();
}

class _ArithmeticCompressionPageState extends State<ArithmeticCompressionPage> {
  String _encodedData = '';
  String _compressionTime = '';
  String _fileSizeBefore = '';
  String _fileSizeAfter = '';
  String? _compressedImagePath;
  bool _isCompressing = false;
  String _ratioOfCompression = ''; //perbandingan ukuran byte data sebelum dilakukan kompresi dan sesudah dilakukannya kompresi
  String _compressionRatio = ''; //perbandingan presentase citra yang telah berhasil dimampakan
  String _redundancy = '';

  Map<String, double> _calculateProbabilities(List<int> data) {
    Map<String, int> frequencyMap = {};
    for (var pixelValue in data) {
      String pixelString = pixelValue.toString();
      frequencyMap[pixelString] = (frequencyMap[pixelString] ?? 0) + 1;
    }

    int totalPixels = data.length;
    return frequencyMap.map((key, value) => MapEntry(key, value / totalPixels));
  }

  String encodeArithmetic(List<int> data) {
    if (data.isEmpty) return '';

    Map<String, double> probabilities = _calculateProbabilities(data);
    ArithmeticCoder coder = ArithmeticCoder(probabilities);
    
    String pixelData = data.map((e) => e.toString()).join('');
    return coder.encode(pixelData).toString();
  }

  Future<void> _compressData() async {
    setState(() {
      _isCompressing = true;
    });

    print("Memulai kompresi data...");
    final stopwatch = Stopwatch()..start();

    // Membaca gambar asli
    File imageFile = File(widget.imagePath);

    if (!await imageFile.exists()) {
      print("File tidak ditemukan: ${widget.imagePath}");
      setState(() {
        _isCompressing = false;
      });
      return;
    }

    int originalFileSize = imageFile.lengthSync();
    _fileSizeBefore = '$originalFileSize bytes';
    print("Ukuran file sebelum: $_fileSizeBefore");

    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage != null) {
      // Data piksel
      List<int> pixels = [];
      for (int y = 0; y < originalImage.height; y++) {
        for (int x = 0; x < originalImage.width; x++) {
          int pixel = originalImage.getPixel(x, y);
          pixels.addAll([img.getRed(pixel), img.getGreen(pixel), img.getBlue(pixel)]);
        }
      }

      // Encode Arithmetic
      _encodedData = encodeArithmetic(pixels);
      print("Data terkompresi Arithmetic: $_encodedData");

      // Simpan gambar terkompresi sebagai PNG
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String pngCompressedPath = '${appDocDir.path}/compressed_image.png';
      File pngCompressedImageFile = File(pngCompressedPath);
      await pngCompressedImageFile.writeAsBytes(img.encodePng(originalImage));
      print("Gambar terkompresi (PNG) disimpan di: $pngCompressedPath");

      // Menghitung ukuran file setelah disimpan
      int pngFileSize = await pngCompressedImageFile.length();

      // Hitung Ratio of Compression (RC)
      double pngRC = pngFileSize / originalFileSize;
      _ratioOfCompression = '${pngRC.toStringAsFixed(2)} (PNG)';

      // Hitung Compression Ratio
      double pngCompressionRatio = originalFileSize / pngFileSize;
      _compressionRatio = '${pngCompressionRatio.toStringAsFixed(2)} (PNG)';

      // Hitung Redundansi
      double pngRedundancyValue = ((originalFileSize - pngFileSize) / originalFileSize) * 100;
      _redundancy = '${pngRedundancyValue.toStringAsFixed(2)}% (PNG)';

      _fileSizeAfter = 'PNG: $pngFileSize';
      print("Ukuran file setelah: $_fileSizeAfter");

      // Menghitung waktu kompresi
      stopwatch.stop();
      _compressionTime = stopwatch.elapsedMilliseconds.toString();
      print("Waktu kompresi: $_compressionTime ms");

      // Simpan path gambar terkompresi
      _compressedImagePath = pngCompressedPath;

      // Memperbarui UI
      setState(() {
        _isCompressing = false;
      });
    } else {
      print("Gambar tidak dapat didekode.");
      setState(() {
        _isCompressing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arithmetic Compression',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 137, 235),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar asli
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                          image: DecorationImage(
                            image: FileImage(File(widget.imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Kompresi dengan indikator loading
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCompressing ? null : _compressData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 33, 137, 235),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isCompressing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Compressing...'),
                                ],
                              )
                            : const Text('Compress Image', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_compressedImagePath != null) ...[
                      const Text(
                        'Hasil Kompresi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                            image: DecorationImage(
                              image: FileImage(File(_compressedImagePath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Statistik kompresi
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 33, 137, 235),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Statistik Kompresi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildStatisticRow('Waktu Kompresi', '$_compressionTime ms'),
                                  _buildStatisticRow('Ukuran Sebelum', _fileSizeBefore),
                                  _buildStatisticRow('Ukuran Setelah', _fileSizeAfter),
                                  _buildStatisticRow('Rasio Kompresi', _ratioOfCompression),
                                  _buildStatisticRow('Redundansi', _redundancy),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    // Tombol Kembali
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color.fromARGB(255, 146, 25, 16),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}