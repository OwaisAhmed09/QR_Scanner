import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(home: ScannerScreen()));
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanCompleted = false; // Prevents double scanning

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secret QR Sender')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture capture) {
              if (!_isScanCompleted) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    final String code = barcode.rawValue!;
                    // Basic validation to ensure it looks like a URL
                    if (code.startsWith('http')) {
                      _foundUrl(code);
                    } else {
                      // Optional: Handle non-URL QR codes
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not a valid URL QR Code'))
                      );
                    }
                    break;
                  }
                }
              }
            },
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Instruction Text
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              "Scan a QR Code containing a URL",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  void _foundUrl(String hiddenUrl) {
    setState(() {
      _isScanCompleted = true; // Lock scanning
    });

    // Show confirmation dialog without revealing the URL
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to choose
      builder: (ctx) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("QR Code Detected"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("A hidden URL has been captured."),
                  const SizedBox(height: 10),
                  const Text("Do you want to send the request internally?"),
                  if (isLoading) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ]
                ],
              ),
              actions: isLoading
                  ? [] // Hide buttons while loading
                  : [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Reset scanner to scan again
                    setState(() {}); // refresh local state
                    this.setState(() {
                      _isScanCompleted = false;
                    });
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    await _sendRequestAndNavigate(hiddenUrl);
                  },
                  child: const Text("Send Request"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendRequestAndNavigate(String url) async {
    try {
      // 1. Make the internal call
      // We use GET here because the QR code usually IS the address.
      // If you need POST, change to http.post(Uri.parse(url), body: ...);
      final response = await http.get(Uri.parse(url));

      // 2. Close the dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      // 3. Navigate to result screen with the data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            statusCode: response.statusCode,
            responseBody: response.body,
          ),
        ),
      ).then((_) {
        // When coming back from result screen, reset scanner
        setState(() {
          _isScanCompleted = false;
        });
      });

    } catch (e) {
      // Handle Error
      if (!mounted) return;
      Navigator.of(context).pop(); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection Failed: $e"), backgroundColor: Colors.red),
      );

      setState(() {
        _isScanCompleted = false;
      });
    }
  }
}

// ---------------------------------------------------------
// SCREEN 2: The Result Display
// ---------------------------------------------------------

class ResultScreen extends StatelessWidget {
  final int statusCode;
  final String responseBody;

  const ResultScreen({
    super.key,
    required this.statusCode,
    required this.responseBody
  });

  @override
  Widget build(BuildContext context) {
    bool isSuccess = statusCode >= 200 && statusCode < 300;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Response'),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Text(
                  "Status: $statusCode",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 30),
            const Text(
              "Response Data:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    responseBody,
                    style: const TextStyle(fontFamily: 'Courier'), // Monospace for code/json
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Scan Another"),
              ),
            )
          ],
        ),
      ),
    );
  }
}