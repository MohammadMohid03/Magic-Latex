// TODO: Replace with real API — POST /api/generate-pdf
class PdfService {
  /// Generates a PDF from text/LaTeX code.
  /// Currently mocked with Future.delayed returning a fake file path.
  Future<String> generatePDF(String text) async {
    await Future.delayed(const Duration(seconds: 2));
    return '/mock/path/output.pdf'; // simulate a file path
  }
}
