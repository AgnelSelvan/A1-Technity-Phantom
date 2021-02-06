import 'dart:io';

import 'package:stock_q/models/bill.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/admin/tax/view_csv.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

AdminMethods _adminMethods = AdminMethods();

class TaxReport extends StatefulWidget {
  TaxReport({Key key}) : super(key: key);

  @override
  _TaxReportState createState() => _TaxReportState();
}

class _TaxReportState extends State<TaxReport> {
  Timestamp _fromDate;
  Timestamp _endDate;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _selectFromDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());
    if (picked != null)
      setState(() {
        _fromDate =
            Timestamp.fromMillisecondsSinceEpoch(picked.millisecondsSinceEpoch);
      });
  }

  Future<Null> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2019, 8),
        lastDate: DateTime.now());
    if (picked != null)
      setState(() {
        _endDate =
            Timestamp.fromMillisecondsSinceEpoch(picked.millisecondsSinceEpoch);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: Text("Annai Store", style: Variables.appBarTextStyle),
            actions: null,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Variables.primaryColor,
                  size: 16,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            centerTitle: true,
            bgColor: Colors.white),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () async {
                    _selectFromDate(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.date_range,
                                    size: 18.0,
                                    color: Colors.teal,
                                  ),
                                  Text(
                                    _fromDate == null
                                        ? 'From Date'
                                        : "${DateFormat('dd/MM/yyyy').format(_fromDate.toDate())}",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Text(
                          "  Change",
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "To",
                    style: TextStyle(color: Variables.blackColor, fontSize: 22),
                  ),
                ),
                SizedBox(height: 10),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () async {
                    _selectEndDate(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.date_range,
                                    size: 18.0,
                                    color: Colors.teal,
                                  ),
                                  Text(
                                    _endDate == null
                                        ? 'End Date'
                                        : "${DateFormat('dd/MM/yyyy').format(_endDate.toDate())}",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Text(
                          "  Change",
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: buildRaisedButton(
                      'Search', Variables.primaryColor, Colors.white, () {
                    generateCSVAndView(context, _fromDate, _endDate);
                  }),
                )
              ],
            ),
          ),
        ));
  }

  generateCSVAndView(context, Timestamp startDate, Timestamp endDate) async {
    List<Bill> billsList = await _adminMethods.getTaxReport(startDate, endDate);
    List<List<dynamic>> datas = List();
    for (var bill in billsList) {
      for (var i = 0; i < bill.taxList.length; i++) {
        List<dynamic> data = List();
        //print(i);
        //print(bill.taxList[i]);
        data.add(bill.billNo);
        data.add(bill.customerName);
        data.add(DateFormat('dd-MM-yyyy')
            .format(bill.timestamp.toDate())
            .toString());
        data.add(
            (bill.sellingRateList[i] * bill.qtyList[i]).toStringAsFixed(2));
        //print(bill.sellingRateList[i]);
        data.add(bill.taxList[i]);
        data.add(((bill.sellingRateList[i] * bill.qtyList[i]) +
                ((bill.sellingRateList[i] * bill.qtyList[i]) *
                    (bill.taxList[i] / 100)))
            .toStringAsFixed(2));
        datas.add(data);
      }
      // datas.add(data);
    }
    //print(datas);

    String fromDate =
        DateFormat('dd-MM-yyyy').format(startDate.toDate()).toString();
    String finishDate =
        DateFormat('dd-MM-yyyy').format(endDate.toDate()).toString();

    List<List<String>> csvData = [
      <String>[
        'Bill No',
        'Customer Name',
        'Date',
        'Rate',
        "GST",
        "Total Price"
      ],
      ...datas.map((e) {
        return [
          e[0],
          e[1],
          e[2],
          e[3].toString(),
          e[4].toString(),
          e[5].toString()
        ];
      }),
    ];
    String csv = const ListToCsvConverter().convert(csvData);
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = "$dir/$fromDate'to'$finishDate.csv";

    // create file
    final File file = File(path);
    // Save csv string using default configuration
    // , as field separator
    // " as text delimiter and
    // \r\n as eol.
    await file.writeAsString(csv);
    // ShareExtend.share(path, 'file');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoadAndViewCsvPage(path: path),
      ),
    );
  }
}
