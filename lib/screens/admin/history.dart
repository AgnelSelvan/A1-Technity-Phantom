import 'package:stock_q/models/bill.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/admin/bill_detail_screen.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/custom_divider.dart';
import 'package:stock_q/widgets/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

AdminMethods _adminMethods = AdminMethods();

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Bill> billsList = List();
  bool isLoading = false;

  getAllHistory() async {
    setState(() {
      isLoading = true;
    });
    List<DocumentSnapshot> docsList = await _adminMethods.getAllBills();
    for (var doc in docsList) {
      // Bill bill = await _adminMethods.getBillById(doc.data['bill_id']);
      Bill bill = Bill.fromMap(doc.data);
      billsList.add(bill);
    }
    setState(() {
      isLoading = false;
    });
    if (billsList.length == 0) {
      Dialogs.okDialog(context, 'Error', "No Paid Bill Yet!", Colors.red[200]);
    }
    //print(billsList.length);
  }

  @override
  void initState() {
    super.initState();
    getAllHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          bgColor: Colors.white,
          title: Text("Annai Store", style: Variables.appBarTextStyle),
          actions: null,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Ionicons.ios_arrow_back,
              color: Variables.primaryColor,
            ),
          ),
          centerTitle: true),
      body: isLoading
          ? CustomCircularLoading()
          : ListView.separated(
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(billsList[index].customerName == ""
                      ? "CASH"
                      : billsList[index].customerName),
                  subtitle: Text("Bill No: ${billsList[index].billNo}"),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.forward,
                        color: Variables.primaryColor,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            BouncyPageRoute(
                                widget: BillDetails(
                              billId: billsList[index].billId,
                            )));
                      }),
                  leading: CircleAvatar(
                    backgroundColor: Variables.primaryColor,
                    child: Text(
                      billsList[index].customerName == ""
                          ? "C"
                          : billsList[index].customerName[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) =>
                  CustomDivider(leftSpacing: 10, rightSpacing: 10),
              itemCount: billsList.length),
    );
  }
}
