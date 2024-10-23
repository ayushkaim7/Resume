import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class Resume extends StatefulWidget {
  const Resume({super.key});

  @override
  State<Resume> createState() => _ResumeState();
}

class _ResumeState extends State<Resume> {
  double _zoomLevel = 1.0;
  final double _minZoom = 0.5;
  final double _maxZoom = 2.0;
  bool _isLoading = false;

  Future<Uint8List> pdfCreation() async {
    final pdf = pw.Document();
    final resumeImage = await imageFromAssetBundle('assets/resume.jpg');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(resumeImage),
          );
        },
      ),
    );

    return pdf.save();
  }

  void _handleZoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.1).clamp(_minZoom, _maxZoom);
    });
  }

  void _handleZoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.1).clamp(_minZoom, _maxZoom);
    });
  }

  Future<void> _openInExternalApp() async {
    try {
      setState(() {
        _isLoading = true;
      });


      final pdfData = await pdfCreation();

      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      final fileName = 'resume_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '$tempPath/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(pdfData);

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        throw Exception('Could not open file');
      }
    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade800,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
          
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                margin: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      icon: Icons.zoom_out,
                      onPressed: _handleZoomOut,
                      tooltip: 'Zoom Out',
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(_zoomLevel * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildControlButton(
                      icon: Icons.zoom_in,
                      onPressed: _handleZoomIn,
                      tooltip: 'Zoom In',
                    ),
                    const SizedBox(width: 24),
                    _buildControlButton(
                      icon: Icons.open_in_new,
                      onPressed: _isLoading ? null : _openInExternalApp,
                      tooltip: 'Open in PDF Viewer',
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
       
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Transform.scale(
                      scale: _zoomLevel,
                      child: PdfPreview(
                        build: (format) => pdfCreation(),
                        useActions: false,
                        previewPageMargin: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isLoading = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(onPressed == null ? 0.1 : 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }

  Future<pw.ImageProvider> imageFromAssetBundle(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }
}