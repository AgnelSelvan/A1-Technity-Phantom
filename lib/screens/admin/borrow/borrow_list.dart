import 'package:stock_q/models/bill.dart';
import 'package:stock_q/models/user.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/resources/auth_methods.dart';
import 'package:stock_q/screens/admin/borrow/single_borrow.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/custom_divider.dart';
import 'package:stock_q/widgets/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

AdminMethods _adminMethods = AdminMethods();
AuthMethods _authMethods = AuthMethods();

class BorrowList extends StatefulWidget {
  BorrowList({Key key}) : super(key: key);

  @override
  _BorrowListState createState() => _BorrowListState();
}

class _BorrowListState extends State<BorrowList> {
  User currentUser;
  bool isLoading = false;
  List<Bill> myBorrowList;
  double myAmount;

  getCurrentUser() async {
    setState(() {
      isLoading = true;
    });

    FirebaseUser firebaseUser = await _authMethods.getCurrentUser();
    User user = await _authMethods.getUserDetailsById(firebaseUser.uid);
    try {
      setState(() {
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      Dialogs.okDialog(
          context, 'Error', 'Somthing went wrong!', Colors.red[200]);
    }
    if (user.role == 'user') {
      getBorrowListOfMe();
    }
  }

  getBorrowListOfMe() async {
    //print("CurrentUser: ${currentUser.mobileNo}");
    List<Bill> billsList = await _adminMethods.getBorrowListOfMe(currentUser);
    setState(() {
      myBorrowList = billsList;
    });
    for (var borrow in myBorrowList) {
      myAmount = borrow.price - borrow.givenAmount;
    }
    //print('myAmount:$myAmount');
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.all(0),
                child: Column(
                  children: [
                    currentUser.role == 'admin'
                        ? StickyHeader(
                            header: buildStickyHeaderListView(context),
                            content: buildAdminStickyBodyListView())
                        : StickyHeader(
                            header: buildUserStickyHeaderListView(context),
                            content: buildUserStickyBodyListView()),
                  ],
                ),
              ),
            ),
    );
  }

  buildUserStickyHeaderListView(context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height / 4,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Container(
        height: double.infinity,
        width: MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Variables.lightPrimaryColor,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
                future: _adminMethods
                    .getTotalAmountByBorrowId(myBorrowList[0].borrowId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CustomCircularLoading();
                  }
                  return Text(
                    "₹ ${snapshot.data.toString()}",
                    style: TextStyle(
                        color: Variables.lightGreyColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        letterSpacing: 1),
                  );
                }),
            SizedBox(height: 10),
            Text(
              "You have to give",
              style: TextStyle(
                  color: Variables.lightGreyColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  buildUserStickyBodyListView() {
    return ListView.separated(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: myBorrowList.length,
        separatorBuilder: (_, __) =>
            CustomDivider(leftSpacing: 20, rightSpacing: 20),
        itemBuilder: (context, index) {
          Bill borrow = myBorrowList[index];
          if (myBorrowList.length == 0) {
            return ListTile(
              title: Text("No borrows yet!"),
            );
          }
          return ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  BouncyPageRoute(
                      widget: SingleBorrow(mobileNo: borrow.mobileNo)));
            },
            title: Text("Annai Store"),
            subtitle: Text(borrow.mobileNo),
            leading: CircleAvatar(
              backgroundColor: Variables.primaryColor,
              child: Text(
                'AS',
                style: TextStyle(color: Colors.white),
              ),
            ),
            trailing: FutureBuilder<Object>(
                future: _adminMethods
                    .getTotalAmountByBorrowId(myBorrowList[index].borrowId),
                builder: (context, snapshot) {
                  return Text(
                    "₹ ${(snapshot.data).toString()}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  );
                }),
          );
        });
  }

  StreamBuilder buildAdminStickyBodyListView() {
    return StreamBuilder(
        stream: _adminMethods.getAllBorrowList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> docsList = snapshot.data.documents;
            return ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: _adminMethods
                          .getBillById(docsList[index]['bill_id']),
                      builder: (context, AsyncSnapshot<Bill> snapshot) {
                        return ListTile(
                          onTap: () {
                            //print(snapshot.data.mobileNo);
                            Navigator.push(
                                context,
                                BouncyPageRoute(
                                    widget: SingleBorrow(
                                        mobileNo: snapshot.data.mobileNo)));
                          },
                          title: Text(snapshot.data.customerName),
                          subtitle: Text(snapshot.data.mobileNo),
                          leading: CircleAvatar(
                            backgroundColor: Variables.primaryColor,
                            child: Text(
                              snapshot.data.customerName[0],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          trailing: FutureBuilder<double>(
                              future: _adminMethods.getTotalAmountByBorrowId(
                                  snapshot.data.borrowId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CustomCircularLoading();
                                }
                                return Text(
                                  "₹ ${snapshot.data.toString()}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Variables.blackColor,
                                      fontSize: 16),
                                );
                              }),
                        );
                      });
                },
                separatorBuilder: (_, __) =>
                    CustomDivider(leftSpacing: 20, rightSpacing: 20),
                itemCount: docsList.length);
            // return ListView.separated(
            //     physics: BouncingScrollPhysics(),
            //     shrinkWrap: true,
            //     itemCount: docs.length,
            //     separatorBuilder: (_, __) =>
            //         CustomDivider(leftSpacing: 20, rightSpacing: 20),
            //     itemBuilder: (context, index) {
            //       BorrowModel borrow = BorrowModel.fromMap(docs[index].data);
            //       if (docs.length == 0) {
            //         return ListTile(
            //           title: Text("No borrows yet!"),
            //         );
            //       }
            //       return ListTile(
            //         onTap: () {
            //           Navigator.push(
            //               context,
            //               BouncyPageRoute(
            //                   widget: SingleBorrow(borrowId: borrow.borrowId)));
            //         },
            //         title: Text(borrow.customerName),
            //         subtitle: Text(borrow.mobileNo),
            //         leading: CircleAvatar(
            //           backgroundColor: Variables.primaryColor,
            //           child: Text(
            //             borrow.customerName[0],
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //         trailing: FutureBuilder<int>(
            //             future: _adminMethods
            //                 .getTotalAmountByBorrowId(borrow.borrowId),
            //             builder: (context, snapshot) {
            //               if (!snapshot.hasData) {
            //                 return CustomCircularLoading();
            //               }
            //               return Text(
            //                 "₹ ${snapshot.data.toString()}",
            //                 style: TextStyle(
            //                     fontWeight: FontWeight.bold, fontSize: 16),
            //               );
            //             }),
            //       );
            //     });
          }
          return CustomCircularLoading();
        });
  }

  Container buildStickyHeaderListView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height / 4,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: FutureBuilder(
          future: _adminMethods.totalAmountYouWillGet(),
          builder: (context, snapshot) {
            return Container(
              height: double.infinity,
              width: MediaQuery.of(context).size.width / 2,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Variables.lightPrimaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "₹ ${snapshot.data.toStringAsFixed(2).toString()}",
                    style: TextStyle(
                        color: Variables.lightGreyColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        letterSpacing: 1),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "You will get",
                    style: TextStyle(
                        color: Variables.lightGreyColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        letterSpacing: 1),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
