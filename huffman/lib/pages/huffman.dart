import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

class HuffmanCompressionPage extends StatefulWidget {
  final String imagePath;
  final String imageData;

  const HuffmanCompressionPage({
    Key? key,
    required this.imagePath,
    required this.imageData,
  }) : super(key: key);

  @override
  _HuffmanCompressionPageState createState() => _HuffmanCompressionPageState();
}

class _HuffmanCompressionPageState extends State<HuffmanCompressionPage> {
  String _encodedData = '';
  String _compressionTime = '';
  String _fileSizeBefore = '';
  String _fileSizeAfter = '';
  String? _compressedImagePath;
  bool _isCompressing = false;
  String _ratioOfCompression = ''; //perbandingan ukuran byte data sebelum dilakukan kompresi dan sesudah dilakukannya kompresi
  String _compressionRatio = ''; //perbandingan presentase citra yang telah berhasil dimampakan
  String _redundancy = ''; //presentase selisih antara ukuran data sebelum dan sesudah dilakukannya kompresi

  String encodeHuffman(List<int> data) {
    if (data.isEmpty) return '';

    // Mengonversi data piksel ke string untuk encoding
    String pixelData = data.map((e) => e.toString()).join(',');
    HuffmanCoding huffman = HuffmanCoding();
    return huffman.encode(pixelData);
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
          pixels.addAll(
              [img.getRed(pixel), img.getGreen(pixel), img.getBlue(pixel)]);
        }
      }

      // Encode Huffman
      _encodedData = encodeHuffman(pixels);
      print("Data terkompresi Huffman: $_encodedData");

      // Simpan gambar terkompresi sebagai PNG
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String pngCompressedPath = '${appDocDir.path}/compressed_image.png';
      File pngCompressedImageFile = File(pngCompressedPath);
      await pngCompressedImageFile
          .writeAsBytes(img.encodePng(originalImage))
          .then((_) async {
        print("Gambar terkompresi (PNG) disimpan di: $pngCompressedPath");

        // Simpan gambar terkompresi sebagai JPEG dengan kualitas 80
        String jpgCompressedPath = '${appDocDir.path}/compressed_image.jpg';
        File jpgCompressedImageFile = File(jpgCompressedPath);
        await jpgCompressedImageFile
            .writeAsBytes(img.encodeJpg(originalImage, quality: 80));
        print("Gambar terkompresi (JPEG) disimpan di: $jpgCompressedPath");

        // Menghitung ukuran file setelah disimpan
        int pngFileSize = await pngCompressedImageFile.length();
        int jpgFileSize = await jpgCompressedImageFile.length();

        // Hitung Ratio of Compression (RC)
        double pngRC = pngFileSize / originalFileSize;
        double jpgRC = jpgFileSize / originalFileSize;

        _ratioOfCompression =
            '${pngRC.toStringAsFixed(2)} (PNG), ${jpgRC.toStringAsFixed(2)} (JPG)';

        // Hitung Compression Ratio
        double pngCompressionRatio = originalFileSize / pngFileSize;
        double jpgCompressionRatio = originalFileSize / jpgFileSize;

        _compressionRatio =
            '${pngCompressionRatio.toStringAsFixed(2)} (PNG), ${jpgCompressionRatio.toStringAsFixed(2)} (JPG)';

        // Hitung Redundansi
        double pngRedundancyValue =
            ((originalFileSize - pngFileSize) / originalFileSize) * 100;
        double jpgRedundancyValue =
            ((originalFileSize - jpgFileSize) / originalFileSize) * 100;

        _redundancy =
            '${pngRedundancyValue.toStringAsFixed(2)}% (PNG), ${jpgRedundancyValue.toStringAsFixed(2)}% (JPG)';

        _fileSizeAfter = 'PNG: $pngFileSize, JPEG: $jpgFileSize';
        print("Ukuran file setelah: $_fileSizeAfter");

        // Menghitung waktu kompresi
        stopwatch.stop();
        _compressionTime = stopwatch.elapsedMilliseconds.toString();
        print("Waktu kompresi: $_compressionTime ms");

        // Simpan path gambar terkompresi
        _compressedImagePath = pngCompressedPath;
        _compressedImagePath = jpgCompressedPath;

        // Memperbarui UI
        setState(() {
          _isCompressing = false;
        });
      }).catchError((error) {
        print("Error saat menyimpan file: $error");
        setState(() {
          _isCompressing = false;
        });
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
          'Huffman Compression',
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
                          backgroundColor:
                              const Color.fromARGB(255, 33, 137, 235),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Compressing...'),
                                ],
                              )
                            : const Text('Compress Image',
                                style: TextStyle(fontSize: 16)),
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
                                  _buildStatisticRow(
                                      'Waktu Kompresi', '$_compressionTime ms'),
                                  _buildStatisticRow(
                                      'Ukuran Sebelum', _fileSizeBefore),
                                  _buildStatisticRow(
                                      'Ukuran Setelah', _fileSizeAfter),
                                  _buildStatisticRow('Rasio Kompresi (PNG)',
                                      _ratioOfCompression.split(', ')[0]),
                                  _buildStatisticRow('Rasio Kompresi (JPG)',
                                      _ratioOfCompression.split(', ')[1]),
                                  _buildStatisticRow('Rasio Kompresi (PNG)',
                                      _compressionRatio.split(' (')[0]),
                                  _buildStatisticRow('Rasio Kompresi (JPG)',
                                      _compressionRatio.split(' (')[1]),
                                  _buildStatisticRow('Redundansi (PNG)',
                                      _redundancy.split(', ')[0]),
                                  _buildStatisticRow('Redundansi (JPG)',
                                      _redundancy.split(', ')[1]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Detail data
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
                                  'Detail Data',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Data yang diterima:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.imageData.length > 100
                                          ? '${widget.imageData.substring(0, 100)}...'
                                          : widget.imageData,
                                      style: const TextStyle(
                                          fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Encoded Huffman Data:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _encodedData.length > 100
                                          ? '${_encodedData.substring(0, 100)}...'
                                          : _encodedData,
                                      style: const TextStyle(
                                          fontFamily: 'monospace'),
                                    ),
                                  ),
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
                          backgroundColor:
                              const Color.fromARGB(255, 146, 25, 16),
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
                    const SizedBox(height: 20), // Padding tambahan di bawah
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper untuk membuat baris statistik
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

class HuffmanNode {
  String character;
  int frequency;
  HuffmanNode? left;
  HuffmanNode? right;

  HuffmanNode(this.character, this.frequency, {this.left, this.right});
}

class HuffmanCoding {
  Map<String, String> huffmanCodes = {};

  String encode(String data) {
    // Hitung frekuensi karakter
    Map<String, int> frequencyMap = {};
    for (var char in data.split(',')) {
      frequencyMap[char] = (frequencyMap[char] ?? 0) + 1;
    }

    // Buat pohon Huffman
    HuffmanNode root = _buildHuffmanTree(frequencyMap);

    // Generate kode Huffman
    _generateCodes(root, '');

    // Encode data
    String encodedData =
        data.split(',').map((char) => huffmanCodes[char]!).join('');
    return encodedData;
  }

  HuffmanNode _buildHuffmanTree(Map<String, int> frequencyMap) {
    PriorityQueue<HuffmanNode> queue = PriorityQueue<HuffmanNode>(
        (a, b) => a.frequency.compareTo(b.frequency));

    // Tambahkan semua karakter ke dalam antrian
    frequencyMap.forEach((char, freq) {
      queue.add(HuffmanNode(char, freq));
    });

    // Bangun pohon Huffman
    while (queue.length > 1) {
      HuffmanNode left = queue.removeFirst();
      HuffmanNode right = queue.removeFirst();
      HuffmanNode parent = HuffmanNode('', left.frequency + right.frequency,
          left: left, right: right);
      queue.add(parent);
    }

    return queue.removeFirst();
  }

  void _generateCodes(HuffmanNode node, String code) {
    if (node.left == null && node.right == null) {
      huffmanCodes[node.character] = code;
      return;
    }
    if (node.left != null) _generateCodes(node.left!, code + '0');
    if (node.right != null) _generateCodes(node.right!, code + '1');
  }
}
