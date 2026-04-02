import 'dart:io';

// TODO: Replace with real API — POST /api/ocr
class OcrService {
  /// Extracts text from an image using OCR.
  /// Currently mocked with Future.delayed.
  Future<String> extractText(File image) async {
    await Future.delayed(const Duration(seconds: 2));
    return '''The quick brown fox jumps over the lazy dog. This is a sample of extracted handwritten text from your document.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.''';
  }

  /// Generates LaTeX code from extracted text.
  /// Currently mocked.
  Future<String> generateLatex(String text) async {
    await Future.delayed(const Duration(seconds: 1));
    return r'''\\documentclass[a4paper,12pt]{article}
\\usepackage[utf8]{inputenc}
\\usepackage[margin=1in]{geometry}
\\usepackage{setspace}
\\onehalfspacing

\\title{Scanned Document}
\\author{DocScan AI}
\\date{\\today}

\\begin{document}
\\maketitle

''' +
        text +
        r'''

\\end{document}''';
  }
}
