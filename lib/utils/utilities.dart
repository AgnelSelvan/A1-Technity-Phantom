import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:stock_q/models/bill.dart';

import 'size_utils.dart';

class Utils {
  static String getUsername(String email) {
    return "${email.split('@')[0]}";
  }

  static Widget noInternet() {
    return Center(
        child: Text(
      'No Internet',
      style: Get.textTheme.headline5,
    ));
  }

  static Widget waitingScreen() {
    return Scaffold(
      body: Stack(
        children: [
          Center(
              child: Text(
            'STOCK Q',
            style: Get.textTheme.headline5,
          )),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: EdgeInsets.only(
                      bottom: (SizeUtils.screenHeight / 100) * 4.92),
                  child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  static String getUniqueId() {
    Random random = new Random();
    int randomNumber = random.nextInt(900000) + 100000;
    return randomNumber.toString();
  }

  static String getDocId() {
    return FirebaseFirestore.instance.collection('customers').doc().id;
  }

  static String getPhoneDisplayName() {
    String uniqueNumber = getUniqueId();
    return 'User$uniqueNumber';
  }

  static Future<File> generateKachaBill(Bill borrowModel) async {
    if (await Permission.storage.request().isGranted) {
      final pdf = pw.Document();
      List<List<dynamic>> datas = List();
      double amount = 0;

      for (dynamic i = 0; i < borrowModel.productList.length; i++) {
        List<dynamic> data = List();
        data.add(borrowModel.productList[i]);
        data.add(borrowModel.qtyList[i]);
        data.add(borrowModel.sellingRateList[i]);
        amount =
            amount + (borrowModel.qtyList[i] * borrowModel.sellingRateList[i]);
        datas.add(data);
      }

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                      child: pw.Container(
                          alignment: pw.Alignment.center,
                          child: pw.Text("Stock Q",
                              style: pw.TextStyle(
                                  fontSize: 30,
                                  fontWeight: pw.FontWeight.bold,
                                  fontStyle: pw.FontStyle.italic)))),
                  pw.SizedBox(height: 20),
                  pw.Paragraph(
                      text:
                          "No.1 Yadhavar Middle Street\n Valliioor-627117\nCell:9488327699\nGSTIN:33AHIPC1946Q1Z4",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal, letterSpacing: 1)),
                  pw.SizedBox(height: 20),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Bill No:  ${borrowModel.billNo}'),
                        pw.Text(
                            'Date:${DateFormat("dd/MM/yyyy").format(borrowModel.timestamp.toDate())}'),
                      ]),
                  pw.Text(
                    '',
                    style: pw.TextStyle(
                      decoration: pw.TextDecoration.underline,
                      decorationStyle: pw.TextDecorationStyle.double,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Table.fromTextArray(
                      context: context,
                      data: <List<dynamic>>[
                        <dynamic>['Product', 'Qty', 'Rate', 'Amount'],
                        ...datas.map(
                            (e) => [e[0], e[1], '${e[2]}', '${e[1] * e[2]}'])
                      ]),
                  pw.SizedBox(height: 5),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                            'Total Items: ${borrowModel.productList.length}',
                            style: pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.left),
                        pw.Text('Total Amount: $amount',
                            style: pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.left),
                      ])
                ])
          ];
        },
      ));

      Directory documentDirectory = await getApplicationDocumentsDirectory();

      String documentPath = documentDirectory.path;

      File file = File("$documentPath/example.pdf");

      file.writeAsBytesSync(await pdf.save());
      return file;
    } else {
      return null;
    }
  }

  static Future<String> generatePakkaBill(
      Bill borrowModel,
      String buyerInfo,
      List<List<dynamic>> datas,
      double grossAmount,
      double totalSGST,
      double totalCGST,
      String amoutEn,
      double amount) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Container(
              height: PdfPageFormat.a4.height / 1.1,
              width: PdfPageFormat.a4.width,
              child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(children: [
                      pw.Container(
                          child: pw.Container(
                              alignment: pw.Alignment.center,
                              child: pw.Text("Tax Invoice",
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                  )))),
                      pw.SizedBox(height: 10),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('GSTIN:33AHIPC1946Q1Z4'),
                            pw.Column(children: [
                              pw.Text('Mobile :9488327699'),
                              pw.Text('Email :annai.charlinf@gmail.com'),
                            ])
                          ]),
                      pw.SizedBox(height: 5),
                      pw.Container(
                          child: pw.Container(
                              alignment: pw.Alignment.center,
                              child: pw.Text("Stock Q",
                                  style: pw.TextStyle(
                                      fontSize: 28,
                                      fontWeight: pw.FontWeight.bold,
                                      fontStyle: pw.FontStyle.italic)))),
                      pw.SizedBox(height: 5),
                      pw.Paragraph(
                          text:
                              "No.1 Yadhavar Middle Street\n Valliioor-627117",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              letterSpacing: 1)),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        height: 70,
                        child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Column(children: [
                                      pw.Text('Buyer:'),
                                      pw.Text("$buyerInfo"),
                                    ]),
                                    pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text('GSTIN:33AHIPC1946Q1Z4'),
                                          pw.Text(
                                              "Mobile No:${borrowModel.mobileNo}"),
                                        ])
                                  ]),
                              pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('Bill No:  ${borrowModel.billNo}'),
                                    pw.Text(
                                        'Date:${DateFormat("dd/MM/yyyy").format(borrowModel.timestamp.toDate())}'),
                                  ]),
                            ]),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Table.fromTextArray(
                          border: pw.TableBorder(
                            // width: 1,
                          ),
                          context: context,
                          data: <List<dynamic>>[
                            <dynamic>[
                              'Product',
                              'HSN',
                              'GST',
                              'Qty',
                              'Rate',
                              'Amount',
                              'SGST',
                              'CGST',
                              'Total'
                            ],
                            ...datas.map((e) => [
                                  e[0],
                                  e[1],
                                  '${e[2]}',
                                  e[3],
                                  e[4],
                                  '${e[3] * e[4]}',
                                  '${(((e[3] * e[4]) * (e[2] / 100)) / 2).toStringAsFixed(2)}',
                                  '${(((e[3] * e[4]) * (e[2] / 100)) / 2).toStringAsFixed(2)}',
                                  '${(e[3] * e[4]) + ((e[3] * e[4]) * (e[2] / 100))}'
                                ])
                          ]),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                                'Total Items: ${borrowModel.productList.length}',
                                textAlign: pw.TextAlign.left),
                          ]),
                      pw.SizedBox(height: 40),
                    ]),
                    pw.Container(
                        child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                            children: [
                          pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        "Rupees:",
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.Text(
                                        amoutEn.toString(),
                                      )
                                    ]),
                                pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text(
                                              "Gross Amount:",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold),
                                            ),
                                            pw.Text(
                                              grossAmount.toString(),
                                            )
                                          ]),
                                      pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text(
                                              "Add SGST:",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold),
                                            ),
                                            pw.Text(
                                              totalSGST.toString(),
                                            )
                                          ]),
                                      pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text(
                                              "Add CGST:",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold),
                                            ),
                                            pw.Text(
                                              totalCGST.toString(),
                                            )
                                          ]),
                                    ])
                              ]),
                          pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Note',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold),
                                    textAlign: pw.TextAlign.left),
                                pw.Column(children: [
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          "Total Amount:",
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold),
                                        ),
                                        pw.Text(
                                          amount.toInt().round().toString(),
                                        )
                                      ]),
                                ])
                              ]),
                          pw.SizedBox(height: 20),
                          pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'CITY UNION BANK',
                                      ),
                                      pw.Text(
                                        'A/C No: 510909010138545',
                                      ),
                                      pw.Text(
                                        'IFSC No: CIUB0000656',
                                      ),
                                      pw.Text('Branch: Vallioor',
                                          textAlign: pw.TextAlign.left),
                                    ]),
                                pw.Column(children: [
                                  pw.Text('Stock Q',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.left),
                                  pw.SizedBox(height: 50),
                                  pw.Text('Authorised Signature',
                                      textAlign: pw.TextAlign.left),
                                ])
                              ]),
                        ]))
                  ]))
        ];
      },
    ));

    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    File file = File("$documentPath/example.pdf");
    try {
      file.writeAsBytesSync(await pdf.save());
      return file.path;
    } catch (e) {
      return 'textfieldError';
    }
  }
}
