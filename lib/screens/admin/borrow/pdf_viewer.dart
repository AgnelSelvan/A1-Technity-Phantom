import 'package:stock_q/screens/admin/borrow/borrow_list.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:printing/printing.dart';
import 'package:share_extend/share_extend.dart';

class PdfPreviewwScreen extends StatelessWidget {
  final String path;
  PdfPreviewwScreen({this.path});

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: CustomAppBar(
            title: Text(
              'Annai Store',
              style: TextStyle(color: Variables.primaryColor),
            ),
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.share,
                    size: 18,
                    color: Colors.blue[200],
                  ),
                  onPressed: () {
                    ShareExtend.share(path, "file");
                  }),
              IconButton(
                  icon: Icon(
                    Icons.print,
                    size: 18,
                    color: Colors.green[200],
                  ),
                  onPressed: () async {
                    final pdf = await rootBundle.load(path);
                    await Printing.layoutPdf(
                        onLayout: (_) => pdf.buffer.asUint8List());
                  })
            ],
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Variables.primaryColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            centerTitle: true,
            bgColor: Variables.lightGreyColor),
        path: path);
  }
}
