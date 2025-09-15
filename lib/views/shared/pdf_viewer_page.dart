import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:http/http.dart' as http;

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfViewerPage(this.title, this.pdfUrl, {Key? key}) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfControllerPinch _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final document = PdfDocument.openData(bytes);
        _pdfController = PdfControllerPinch(document: document);
        setState(() => _isLoading = false);
      } else {
        setState(() => _error = 'Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Error loading PDF: $e');
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(centerTitle: widget.title),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : PdfViewPinch(controller: _pdfController),
    );
  }
}

/*

import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qpay/main.dart';
import 'package:qpay/widgets/app_bar.dart';

class PdfViewerPage extends StatefulWidget{
  final String title;
  final PDFDocument pdfDocument;

  const PdfViewerPage(this.title, this.pdfDocument);
  @override
  State<StatefulWidget> createState() => _PdfViewerPageState(title,pdfDocument);
  
}
class _PdfViewerPageState extends State<PdfViewerPage>{
  bool _isLoading = true;
  final String _title;
  final PDFDocument _pdfDocument;

  _PdfViewerPageState(this._title, this._pdfDocument);
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: MyAppBar(
       centerTitle: _title,
     ),
     body: Center(
       child: _isLoading?CircularProgressIndicator():PDFViewer(document: _pdfDocument,zoomSteps: 1,),
     ) ,
   );
  }
  
}*/
