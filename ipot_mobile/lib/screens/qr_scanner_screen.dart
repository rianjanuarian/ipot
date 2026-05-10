import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipot_mobile/utils/qr_parser.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;
  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    final tableId = QrParser.parseTableId(raw);
    if (tableId != null) {
      setState(() => _hasScanned = true);
      _controller.stop();
      context.go('/menu/$tableId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR code. Please scan a valid table QR.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mWidth = MediaQuery.of(context).size.width;
    final mHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          //cam preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          //header
          SafeArea(
              child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Text(
                  "IPOT",
                  style: TextStyle(color: Colors.white, letterSpacing: 5),
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                  onPressed: () => _controller.toggleTorch(),
                ),
              ],
            ),
          )),
          //center frame
          Center(
            child: SizedBox(
              width: mWidth * 0.65,
              height: mWidth * 0.65,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        //  color: Colors.redAccent.withAlpha(100),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //bottom instruction
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, 32 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: mWidth * 0.12,
                    height: mWidth * 0.12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.qr_code_scanner_rounded,
                        color: Colors.white, size: mWidth * 0.075),
                  ),
                  SizedBox(height: mHeight * 0.0075),
                  Text(
                    'Point your camera at the\ntable QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: mWidth * 0.04,
                    ),
                  ),
                  SizedBox(height: mHeight * 0.0125),
                  Text(
                    'Format: ipot://table/{tableId}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: mWidth * 0.0275,
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
