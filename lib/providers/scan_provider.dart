import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/scan_result.dart';
import '../models/recent_scan.dart';
import '../services/ocr_service.dart';
import '../services/pdf_service.dart';

class ScanProvider extends ChangeNotifier {
  final OcrService _ocrService = OcrService();
  final PdfService _pdfService = PdfService();
  final ImagePicker _picker = ImagePicker();

  // State
  File? _selectedImage;
  ScanResult? _scanResult;
  int _processingStep = 0; // 0=none, 1=captured, 2=extracting, 3=latex, 4=pdf
  bool _isProcessing = false;
  bool _isDarkMode = true;
  String _paperSize = 'A4';
  String _authorName = '';
  bool _saveToGallery = false;

  // Dummy recent scans
  final List<RecentScan> _recentScans = [
    RecentScan(
      fileName: 'lecture_notes.pdf',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    RecentScan(
      fileName: 'assignment_01.pdf',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecentScan(
      fileName: 'handwritten_essay.pdf',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    RecentScan(
      fileName: 'math_formula.pdf',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RecentScan(
      fileName: 'research_paper.pdf',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // Getters
  File? get selectedImage => _selectedImage;
  ScanResult? get scanResult => _scanResult;
  int get processingStep => _processingStep;
  bool get isProcessing => _isProcessing;
  bool get isDarkMode => _isDarkMode;
  String get paperSize => _paperSize;
  String get authorName => _authorName;
  bool get saveToGallery => _saveToGallery;
  List<RecentScan> get recentScans => _recentScans;

  // Pick image from camera
  Future<bool> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (image != null) {
        // Validate file size (max 10MB)
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          return false; // File too large
        }
        _selectedImage = file;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Pick image from gallery
  Future<bool> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          return false;
        }
        _selectedImage = file;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Run the full processing pipeline
  Future<void> runPipeline() async {
    if (_selectedImage == null) return;

    _isProcessing = true;
    _processingStep = 1; // Image captured
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    // Step 2: Extract text
    _processingStep = 2;
    notifyListeners();
    final extractedText = await _ocrService.extractText(_selectedImage!);

    // Step 3: Generate LaTeX
    _processingStep = 3;
    notifyListeners();
    final latexCode = await _ocrService.generateLatex(extractedText);

    // Step 4: Build PDF
    _processingStep = 4;
    notifyListeners();
    final pdfPath = await _pdfService.generatePDF(latexCode);

    _scanResult = ScanResult(
      extractedText: extractedText,
      latexCode: latexCode,
      pdfPath: pdfPath,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    _isProcessing = false;
    notifyListeners();
  }

  // Reset state for new scan
  void reset() {
    _selectedImage = null;
    _scanResult = null;
    _processingStep = 0;
    _isProcessing = false;
    notifyListeners();
  }

  // Settings
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPaperSize(String size) {
    _paperSize = size;
    notifyListeners();
  }

  void setAuthorName(String name) {
    _authorName = name;
    notifyListeners();
  }

  void toggleSaveToGallery() {
    _saveToGallery = !_saveToGallery;
    notifyListeners();
  }
}
