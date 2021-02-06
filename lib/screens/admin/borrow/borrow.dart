import 'dart:io';

import 'package:stock_q/models/bill.dart';
import 'package:stock_q/models/borrow.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/admin/bill_screen.dart';
import 'package:stock_q/screens/admin/borrow/borrow_list.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/screens/root_screen.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/utils/utilities.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/dialogs.dart';
import 'package:stock_q/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

AdminMethods _adminMethods = AdminMethods();

class BorrowScreen extends StatefulWidget {
  final List<String> productList;
  final List<String> productListId;
  final List<int> qtyList;
  final List<int> taxList;
  final List<double> sellingRateList;
  final double totalPrice;
  final String billNo;
  final bool isTax;

  BorrowScreen(
      {@required this.billNo,
      @required this.productListId,
      @required this.productList,
      @required this.qtyList,
      @required this.sellingRateList,
      @required this.taxList,
      @required this.totalPrice,
      @required this.isTax});

  @override
  _BorrowScreenState createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  List<Contact> contacts = [];
  List<Contact> contactFiltered = [];
  TextEditingController customerGivenMoney = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController totalPriceController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  Contact selectedContact;
  bool isLoading = false;
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    getAllContacts();
    searchController.addListener(() {
      filterContacts();
    });
    customerGivenMoney.addListener(() {
      updateTotalAmount();
    });
    priceController = TextEditingController(text: widget.totalPrice.toString());
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  void updateTotalAmount() {
    //print(customerGivenMoney.text);
    setState(() {
      double totalPrice =
          widget.totalPrice - int.parse(customerGivenMoney.text);
      totalPriceController = TextEditingController(text: totalPrice.toString());
    });
  }

  String flattenPhoneNumbers(String phoneStr) {
    return phoneStr.replaceAll(RegExp(r'^(\+)|\D'), '');
  }

  void filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumbers(searchTerm);
        String contactName = contact.displayName == null
            ? 'Unknown'
            : contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumbers(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });

      setState(() {
        contactFiltered = _contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return Scaffold(
        appBar: CustomAppBar(
            bgColor: Colors.white,
            title: Text("Stock Q", style: Variables.appBarTextStyle),
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
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      StickyHeader(
                        header: buildStickHeader(),
                        content: selectedContact == null
                            ? buildContactListView(isSearching)
                            : buildProductDetailsListView(context),
                      ),
                    ],
                  ),
                ),
              ));
  }

  ListView buildProductDetailsListView(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      children: [
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bill No",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Container(
              child: Text(
                "${widget.billNo}",
                style: Variables.inputLabelTextStyle,
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mobile Number",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Container(
              child: Text(
                "${selectedContact.phones.elementAt(0).value}",
                style: Variables.inputLabelTextStyle,
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer Name",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Container(
              height: 55,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8)),
              child: TextFormField(
                cursorColor: Variables.primaryColor,
                maxLines: 1,
                style: Variables.inputTextStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ram',
                  prefixIcon: Icon(
                    FontAwesome.user,
                    size: 12,
                    color: Colors.yellow[900],
                  ),
                ),
                controller: customerNameController,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Product",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.productList.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Text(
                    "${widget.productList[index]} (${widget.qtyList[index]})",
                    style: Variables.inputLabelTextStyle,
                  ),
                );
              },
            )
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Price",
                    style: Variables.inputLabelTextStyle,
                  ),
                  Container(
                    height: 55,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: TextFormField(
                      enabled: false,
                      cursorColor: Variables.primaryColor,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      style: Variables.inputTextStyle,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '123',
                        prefixIcon: Icon(
                          FontAwesome.rupee,
                          size: 12,
                          color: Colors.yellow[900],
                        ),
                      ),
                      controller: priceController,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Text('-'),
            Spacer(),
            Container(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "given amount",
                    style: Variables.inputLabelTextStyle,
                  ),
                  Container(
                    height: 55,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: TextFormField(
                      enabled: true,
                      focusNode: myFocusNode,
                      cursorColor: Variables.primaryColor,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      style: Variables.inputTextStyle,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '123',
                        prefixIcon: Icon(
                          FontAwesome.rupee,
                          size: 12,
                          color: Colors.yellow[900],
                        ),
                      ),
                      controller: customerGivenMoney,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Total Price",
              style: Variables.inputLabelTextStyle,
            ),
            Container(
              height: 55,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8)),
              child: TextFormField(
                enabled: false,
                cursorColor: Variables.primaryColor,
                maxLines: 1,
                style: Variables.inputTextStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '123',
                  prefixIcon: Icon(
                    Icons.dialpad,
                    size: 12,
                    color: Colors.yellow[900],
                  ),
                ),
                controller: totalPriceController,
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Container(
            width: MediaQuery.of(context).size.width / 2,
            child: buildRaisedButton('Save', Colors.green[300], Colors.white,
                () async {
              try {
                String borrowId = Utils.getDocId();
                String billId = Utils.getDocId();
                Bill bill = Bill(
                  billId: billId,
                  productListId: widget.productListId,
                  productList: widget.productList,
                  qtyList: widget.qtyList,
                  taxList: widget.taxList,
                  sellingRateList: widget.sellingRateList,
                  price: double.parse(priceController.text),
                  givenAmount: double.parse(customerGivenMoney.text),
                  billNo: widget.billNo,
                  mobileNo: selectedContact.phones
                      .elementAt(0)
                      .value
                      .replaceAll(' ', ''),
                  timestamp: Timestamp.now(),
                  customerName: customerNameController.text,
                  isTax: widget.isTax,
                  isPaid: false,
                  borrowId: borrowId,
                );
                bool isBillAdded = await _adminMethods.addBillToDb(bill);
                Borrow borrow = Borrow(billId: billId, borrowId: borrowId);
                if (isBillAdded) {
                  _adminMethods.addBorrowToDb(borrow);
                  Navigator.pushAndRemoveUntil(context,
                      BouncyPageRoute(widget: RootScreen()), (route) => false);
                  Dialogs.okDialog(context, 'Successfull', 'Added Successfully',
                      Colors.green[200]);
                } else {
                  Dialogs.okDialog(
                      context, 'Error', 'Somthing went wrong', Colors.red[200]);
                }
              } catch (e) {
                Dialogs.okDialog(context, 'Error', 'Given amount cant be empty',
                    Colors.red[200]);
              }
            }))
      ],
    );
  }

  ListView buildContactListView(bool isSearching) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: isSearching == true ? contactFiltered.length : contacts.length,
      itemBuilder: (context, index) {
        Contact contact =
            isSearching == true ? contactFiltered[index] : contacts[index];
        return GestureDetector(
          onTap: () {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            setState(() {
              mobileNumberController = TextEditingController(
                  text: contact.phones.elementAt(0).value);
              selectedContact = contact;
              customerNameController =
                  TextEditingController(text: selectedContact.displayName);
            });
          },
          child: ListTile(
            title: Text(
                contact.displayName == null ? 'Unknown' : contact.displayName),
            subtitle: Text(contact.phones.length == 0
                ? "No Number"
                : contact.phones.elementAt(0).value),
            leading: (contact.avatar != null && contact.avatar.length > 0)
                ? CircleAvatar(
                    backgroundImage: MemoryImage(contact.avatar),
                  )
                : CircleAvatar(
                    backgroundColor: Variables.lightPrimaryColor,
                    child: Text(
                      contact.initials(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Container buildStickHeader() {
    return Container(
      decoration: BoxDecoration(color: Variables.lightGreyColor),
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Search Contact",
            style: Variables.inputLabelTextStyle,
          ),
          Container(
            height: 55,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              autofocus: true,
              cursorColor: Variables.primaryColor,
              maxLines: 1,
              style: Variables.inputTextStyle,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '123456789',
                prefixIcon: Icon(
                  Icons.search,
                  size: 12,
                  color: Colors.yellow[900],
                ),
              ),
              controller: searchController,
            ),
          ),
        ],
      ),
    );
  }

  getAllContacts() async {
    setState(() {
      isLoading = true;
    });
    if (await Permission.contacts.request().isGranted) {
      List<Contact> _contacts = (await ContactsService.getContacts()).toList();
      setState(() {
        contacts = _contacts;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}

// import 'package:stock_q/models/borrow.dart';
// import 'package:stock_q/models/category.dart';
// import 'package:stock_q/models/product.dart';
// import 'package:stock_q/models/user.dart';
// import 'package:stock_q/resources/admin_methods.dart';
// import 'package:stock_q/screens/admin/add_product.dart';
// import 'package:stock_q/utils/universal_variables.dart';
// import 'package:stock_q/utils/utilities.dart';
// import 'package:stock_q/widgets/bouncy_page_route.dart';
// import 'package:stock_q/widgets/custom_appbar.dart';
// import 'package:stock_q/widgets/dialogs.dart';
// import 'package:stock_q/widgets/header.dart';
// import 'package:stock_q/widgets/widgets.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../custom_loading.dart';

// AdminMethods _adminMethods = AdminMethods();

// class BorrowScreen extends StatefulWidget {
//   BorrowScreen({Key key}) : super(key: key);

//   @override
//   _BorrowScreenState createState() => _BorrowScreenState();
// }

// class _BorrowScreenState extends State<BorrowScreen> {
//   TextEditingController _emailFieldController = TextEditingController();
//   TextEditingController _nameFieldController = TextEditingController();
//   TextEditingController _addressController = TextEditingController();
//   TextEditingController _pincodeController = TextEditingController();
//   TextEditingController _mobileNoController = TextEditingController();
//   TextEditingController _gstinController = TextEditingController();
//   TextEditingController _priceController = TextEditingController();
//   TextEditingController _taxController = TextEditingController();
//   TextEditingController _totalPriceController = TextEditingController();

//   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//   final _formKey = GlobalKey<FormState>();

//   bool viewVisible = false;
//   bool _checkBoxValue = false;

//   String currentState;
//   String currentUnit;
//   String currentName;
//   String currentProduct;

//   var productList = new List();
//   var qtyList = new List();
//   var taxList = new List<dynamic>();
//   var sellingRateList = new List<dynamic>();
//   int totalPrice;
//   int tax;

//   List<String> state = [
//     'Maharashtra',
//     'Tamil Nadu',
//   ];

//   User _selectedUser;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<Null> sendSms(var mobileNumber, var body) async {
//     var uri = 'sms:$mobileNumber?body=$body';
//     await launch(uri);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         key: _scaffoldKey,
//         appBar: CustomAppBar(
//             title: Text("Stock Q", style: Variables.appBarTextStyle),
//             actions: null,
//             leading: IconButton(
//                 icon: Icon(
//                   Icons.arrow_back_ios,
//                   color: Variables.primaryColor,
//                   size: 16,
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 }),
//             centerTitle: true,
//             bgColor: Colors.white),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListView(
//             physics: const BouncingScrollPhysics(),
//             children: <Widget>[
//               Container(
//                 padding: EdgeInsets.only(left: 5),
//                 color: Colors.white,
//                 child: buildCustomerCard(),
//               ),
//             ],
//           ),
//         ));
//   }

//   createAlertDialog(BuildContext context, String currentProduct) {
//     TextEditingController qtyController = TextEditingController();

//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             title: Text("Enter Quantity"),
//             content: Container(
//               padding: EdgeInsets.symmetric(horizontal: 15),
//               decoration: BoxDecoration(
//                   color: Colors.yellow[100],
//                   borderRadius: BorderRadius.circular(8)),
//               child: TextFormField(
//                 cursorColor: Variables.primaryColor,
//                 validator: (value) {
//                   if (value.isEmpty)
//                     return "You cannot have an empty Purchase Price!";
//                   if (value.length != 6) return "Enter valid pincode!";
//                 },
//                 maxLines: 1,
//                 keyboardType: TextInputType.number,
//                 style: Variables.inputTextStyle,
//                 decoration: InputDecoration(
//                     border: InputBorder.none, hintText: 'Quantity'),
//                 controller: qtyController,
//               ),
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(DialogAction.Abort);
//                 },
//                 child: Text(
//                   "No",
//                   style: TextStyle(color: Variables.primaryColor),
//                 ),
//               ),
//               RaisedButton(
//                 elevation: 0,
//                 color: Variables.primaryColor,
//                 onPressed: () {
//                   if (!productList.contains(currentProduct)) {
//                     productList.add(currentProduct);
//                     qtyList.add(int.parse(qtyController.text));
//                   }
//                   Navigator.of(context).pop(DialogAction.Abort);
//                   //print(productList);
//                   //print(qtyList);
//                   //print(taxList);
//                   //print(sellingRateList);
//                   var sum = 0;
//                   tax = 0;
//                   totalPrice = 0;
//                   for (var i = 0; i < sellingRateList.length; i++) {
//                     sum += sellingRateList[i] * qtyList[i];
//                     tax += taxList[i];
//                   }
//                   totalPrice = (sum * (tax / 100)).round();
//                   setState(() {
//                     _priceController =
//                         TextEditingController(text: sum.toString());
//                     _taxController =
//                         TextEditingController(text: tax.toString());
//                     _totalPriceController =
//                         TextEditingController(text: totalPrice.toString());
//                   });
//                 },
//                 child: Text(
//                   "Yes",
//                   style: TextStyle(color: Variables.lightGreyColor),
//                 ),
//               )
//             ],
//           );
//         });
//   }

//   scanQr() async {
//     String barcodeScanRes;

//     try {
//       barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//           '#ff6666', 'Cancel', true, ScanMode.QR);
//       //print(barcodeScanRes);
//     } on PlatformException {
//       barcodeScanRes = 'Failed to get platform version.';
//     }

//     if (!mounted) return;

//     final bool isExists = await _adminMethods.isQrExists(barcodeScanRes);
//     if (isExists) {
//       Product product =
//           await _adminMethods.getProductDetailsByQrCode(barcodeScanRes);

//       createAlertDialog(context, product.name);

//       Category category = await _adminMethods.getTaxFromHsn(product.hsnCode);
//       if (!productList.contains(currentProduct)) {
//         taxList.add(category.tax);
//         sellingRateList.add(product.sellingRate);
//       }
//     } else {
//       Navigator.push(
//           context,
//           BouncyPageRoute(
//               widget: AddProduct(
//             qrCode: barcodeScanRes,
//           )));
//     }
//   }

//   createAllreadyExistsDialog(BuildContext context) {
//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             title: Text(
//               "Error",
//               style: TextStyle(color: Colors.red[200]),
//             ),
//             content: Container(
//               padding: EdgeInsets.symmetric(horizontal: 15),
//               decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
//               child: Text("Product Already Exists!"),
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(DialogAction.Abort);
//                 },
//                 child: Text(
//                   "Ok",
//                   style: TextStyle(color: Colors.red[200]),
//                 ),
//               ),
//             ],
//           );
//         });
//   }

//   handleDeleteUnit(String unitId) {
//     _adminMethods.deleteUnit(unitId);
//     final snackBar =
//         customSnackBar('Delete Successfull!', Variables.blackColor);
//     _scaffoldKey.currentState.showSnackBar(snackBar);
//   }

//   void showWidget() {
//     //print(viewVisible);
//     setState(() {
//       viewVisible = !viewVisible;
//     });
//     //print(viewVisible);
//   }

//   addCustomerToDb() {
//     //print(productList);
//   }

//   Card buildCustomerCard() {
//     return Card(
//       elevation: 3,
//       child: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   BuildHeader(
//                     text: "Customer",
//                   ),
//                   Row(
//                     children: <Widget>[
//                       Checkbox(
//                           activeColor: Variables.primaryColor,
//                           focusColor: Variables.primaryColor,
//                           value: _checkBoxValue,
//                           onChanged: (bool value) {
//                             //print(value);
//                             setState(() {
//                               _checkBoxValue = value;
//                             });
//                           }),
//                       Text(
//                         "Regular Customer",
//                         style: TextStyle(fontSize: 16),
//                       )
//                     ],
//                   )
//                 ],
//               ),
//               SizedBox(
//                 height: 15,
//               ),
//               viewVisible ? buildCustomer() : Container(),
//               Row(
//                 mainAxisAlignment: viewVisible
//                     ? MainAxisAlignment.spaceAround
//                     : MainAxisAlignment.center,
//                 children: <Widget>[
//                   buildCustomModelButton(),
//                   if (viewVisible) buildSubmissionButton() else Container(),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildCustomer() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         buildVisibility(),
//         buildProductDropdown(),
//         SizedBox(
//           height: 20,
//         ),
//         buildPriceField(),
//         SizedBox(
//           height: 20,
//         ),
//         buildTaxField(),
//         SizedBox(
//           height: 20,
//         ),
//         buildTotalPriceField(),
//         SizedBox(
//           height: 20,
//         ),
//       ],
//     );
//   }

//   Widget buildQrCodeButton() {
//     return FlatButton(
//       color: Variables.lightGreyColor,
//       onPressed: () => scanQr(),
//       child: Text('Qr Code',
//           style: TextStyle(
//             color: Variables.primaryColor,
//             letterSpacing: 0.5,
//           )),
//     );
//   }

//   GestureDetector buildSubmissionButton() {
//     return GestureDetector(
//       onTap: () async {
//         User user;
//         if (_checkBoxValue) {
//           user = _selectedUser;
//         } else {
//           user = User(
//             uid: Utils.getDocId(),
//             name: _nameFieldController.text,
//             email: _emailFieldController.text,
//             address: _addressController.text,
//             state: currentState,
//             pincode: int.parse(_pincodeController.text),
//             mobileNo: int.parse(_mobileNoController.text),
//           );
//         }
//         Borrow borrow = Borrow(
//             borrowId: Utils.getDocId(),
//             user: user,
//             taxList: taxList,
//             productList: productList,
//             isRegularCustomer: _checkBoxValue,
//             priceList: sellingRateList,
//             totalPrice: totalPrice,
//             qtyList: qtyList);
//         _adminMethods.addBorrowToDb(borrow);

//         SnackBar snackbar = customSnackBar(
//             'Borrowed Details Added Successfullt!', Variables.blackColor);
//         _scaffoldKey.currentState.showSnackBar(snackbar);

//         var stringProduct = productList.join(", ");
//         var stringQty = qtyList.join(", ");
//         var stringPrice = sellingRateList.join(", ");
//         String stringBody =
//             'Product: $stringProduct \nQuantity: $stringQty \nPrice: $stringPrice \nTax: $tax \nTotal Price: $totalPrice \nPlease Give soon as possible!';

//         final Email email = Email(
//           body: stringBody,
//           subject: 'Give this ammount',
//           recipients: [_selectedUser.email],
//           // cc: ['cc@example.com'],
//           // bcc: ['bcc@example.com'],
//           // attachmentPaths: ['/path/to/attachment.zip'],
//           isHTML: false,
//         );

//         try {
//           await FlutterEmailSender.send(email);
//           //print("SUCESS");
//         } catch (error) {
//           //print(error);
//         }

//         if (!mounted) return;

//         SnackBar snackBar =
//             customSnackBar('Email sent Successfull', Variables.blackColor);
//         _scaffoldKey.currentState.showSnackBar(snackBar);

//         setState(() {
//           _selectedUser = null;
//           productList = [];
//           _priceController.clear();
//           _taxController.clear();
//           _totalPriceController.clear();
//         });

//         await sendSms(_mobileNoController.text, stringBody);
//       },
//       child: Icon(
//         Icons.check_circle,
//         size: 30,
//         color: Colors.green[200],
//       ),
//     );
//   }

//   GestureDetector buildCustomModelButton() {
//     return GestureDetector(
//       onTap: () {
//         showWidget();
//       },
//       child: Container(
//         width: 170,
//         decoration: BoxDecoration(
//             color: Colors.grey[100], borderRadius: BorderRadius.circular(100)),
//         padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Container(
//               width: 35,
//               height: 35,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(100),
//                   color: Colors.yellow[100]),
//               child: Icon(
//                 Icons.add,
//                 color: Variables.blackColor,
//               ),
//             ),
//             SizedBox(
//               width: 15,
//             ),
//             Text(
//               "Add Borrow",
//               style: TextStyle(
//                   letterSpacing: 1, fontSize: 16, color: Variables.blackColor),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Visibility buildVisibility() {
//     return _checkBoxValue
//         ? Visibility(
//             maintainSize: true,
//             maintainAnimation: true,
//             maintainState: true,
//             visible: viewVisible,
//             child: Container(
//                 child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[buildRegularCustomerDetails()],
//             )))
//         : Visibility(
//             maintainSize: true,
//             maintainAnimation: true,
//             maintainState: true,
//             visible: viewVisible,
//             child: Container(
//                 child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 buildNameField(),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 buildEmailField(),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 buildAddressField(),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 buildStateDropDown(),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 buildPincodeField(),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 buildMobileNoField(),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 buildGSTINField(),
//                 SizedBox(
//                   height: 20,
//                 ),
//               ],
//             )));
//   }

//   Widget buildRegularCustomerDetails() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         buildNameDropdown(),
//         SizedBox(
//           height: 20,
//         ),
//         buildEmailField(),
//         SizedBox(
//           height: 20,
//         ),
//         buildAddressField(),
//         SizedBox(
//           height: 20,
//         ),
//         buildStateDropDown(),
//         SizedBox(
//           height: 20,
//         ),
//         buildPincodeField(),
//         SizedBox(
//           height: 20,
//         ),
//         buildMobileNoField(),
//         SizedBox(
//           height: 20,
//         ),
//         buildGSTINField(),
//         SizedBox(
//           height: 20,
//         ),
//       ],
//     );
//   }

//   Widget buildProductList() {
//     return Container(
//       height: 200,
//       padding: EdgeInsets.all(10),
//       child: ListView.builder(
//           physics: BouncingScrollPhysics(),
//           itemBuilder: (context, index) {
//             return Container(
//               margin: EdgeInsets.symmetric(vertical: 8),
//               decoration: BoxDecoration(
//                   color: Variables.greyColor,
//                   borderRadius: BorderRadius.circular(10)),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: <Widget>[
//                     Text(productList[index]),
//                     Spacer(),
//                     Text('(${qtyList[index]})'),
//                     IconButton(
//                         icon: Icon(
//                           FontAwesome.times_circle,
//                           color: Colors.red[200],
//                         ),
//                         onPressed: null)
//                   ],
//                 ),
//               ),
//             );
//           },
//           itemCount: productList.length),
//     );
//   }

//   Widget buildProductDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         productList.isEmpty ? Container() : buildProductList(),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10.0),
//                   child: Text(
//                     "Product",
//                     style: Variables.inputLabelTextStyle,
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 15),
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: Colors.yellow[100]),
//                   child: StreamBuilder<QuerySnapshot>(
//                       stream: _adminMethods.fetchAllProduct(),
//                       builder: (BuildContext context,
//                           AsyncSnapshot<QuerySnapshot> snapshot) {
//                         if (snapshot.hasError) {
//                           //print(snapshot.error);
//                         } else {
//                           if (!snapshot.hasData) {
//                             return CustomCircularLoading();
//                           }

//                           return new DropdownButton<DocumentSnapshot>(
//                             dropdownColor: Colors.yellow[100],
//                             underline: SizedBox(),
//                             onChanged: (DocumentSnapshot newValue) async {
//                               setState(() async {
//                                 currentProduct = newValue.data['name'];
//                                 if (productList.contains(currentProduct)) {
//                                   createAllreadyExistsDialog(context);
//                                 } else {
//                                   createAlertDialog(context, currentProduct);
//                                   Category category = await _adminMethods
//                                       .getTaxFromHsn(newValue.data['hsn_code']);
//                                   if (!productList.contains(currentProduct)) {
//                                     taxList.add(category.tax);
//                                     sellingRateList
//                                         .add(newValue.data['selling_rate']);
//                                   }
//                                 }
//                               });
//                               // //print(currentProduct);
//                             },
//                             hint: currentProduct == null
//                                 ? Text('Select Product')
//                                 : Text(currentProduct),
//                             items: snapshot.data.documents
//                                 .map((DocumentSnapshot document) {
//                               return new DropdownMenuItem<DocumentSnapshot>(
//                                   value: document,
//                                   child: new Text(
//                                     document.data['name'],
//                                   ));
//                             }).toList(),
//                           );
//                         }
//                         return CustomCircularLoading();
//                       }),
//                 ),
//               ],
//             ),
//             buildQrCodeButton()
//           ],
//         ),
//       ],
//     );
//   }

//   Widget buildPriceField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "Price",
//           style: Variables.inputLabelTextStyle,
//         ),
//         Container(
//           height: 48,
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               color: Colors.yellow[100],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             cursorColor: Variables.primaryColor,
//             maxLines: 1,
//             style: Variables.inputTextStyle,
//             decoration:
//                 InputDecoration(border: InputBorder.none, hintText: '1234'),
//             controller: _priceController,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildTaxField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "Tax",
//           style: Variables.inputLabelTextStyle,
//         ),
//         Container(
//           height: 48,
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               color: Colors.yellow[100],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             cursorColor: Variables.primaryColor,
//             maxLines: 1,
//             style: Variables.inputTextStyle,
//             decoration:
//                 InputDecoration(border: InputBorder.none, hintText: '1234'),
//             controller: _taxController,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildTotalPriceField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "Total Price",
//           style: Variables.inputLabelTextStyle,
//         ),
//         Container(
//           height: 48,
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               color: Colors.yellow[100],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             cursorColor: Variables.primaryColor,
//             maxLines: 1,
//             style: Variables.inputTextStyle,
//             decoration:
//                 InputDecoration(border: InputBorder.none, hintText: '1234'),
//             controller: _totalPriceController,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildNameDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.only(left: 10.0),
//           child: Text(
//             "Name",
//             style: Variables.inputLabelTextStyle,
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               color: Colors.yellow[100]),
//           child: StreamBuilder<QuerySnapshot>(
//               stream: _adminMethods.fetchAllCustomer(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 //print(snapshot.data.documents.length);
//                 if (snapshot.hasError) {
//                   //print(snapshot.error);
//                 } else {
//                   if (!snapshot.hasData) {
//                     return CustomCircularLoading();
//                   }
//                   if (snapshot.hasData) {
//                     return new DropdownButton<DocumentSnapshot>(
//                       dropdownColor: Colors.yellow[100],
//                       underline: SizedBox(),
//                       onChanged: (DocumentSnapshot newValue) {
//                         setState(() {
//                           currentName = newValue.data['name'];
//                           _emailFieldController = TextEditingController(
//                               text: newValue.data['email']);
//                           _addressController = TextEditingController(
//                               text: newValue.data['address']);
//                           currentState = newValue.data['state'];
//                           _pincodeController = TextEditingController(
//                               text: newValue.data['pincode'].toString());
//                           _gstinController = TextEditingController(
//                               text: newValue.data['gstin']);
//                           _mobileNoController = TextEditingController(
//                               text: newValue.data['mobile_no'].toString());
//                           _selectedUser = User.fromMap(newValue.data);
//                           //print(currentName);
//                         });
//                       },
//                       hint: currentName == null
//                           ? Text('Select Name')
//                           : Text(currentName),
//                       items: snapshot.data.documents
//                           .map((DocumentSnapshot document) {
//                         //print(document);
//                         return new DropdownMenuItem<DocumentSnapshot>(
//                             value: document,
//                             child: new Text(
//                               document.data['name'],
//                             ));
//                       }).toList(),
//                     );
//                   }
//                 }
//                 return CustomCircularLoading();
//               }),
//         ),
//       ],
//     );
//   }

//   Column buildStateDropDown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.only(left: 10.0),
//           child: Text(
//             "State",
//             style: Variables.inputLabelTextStyle,
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               color: Colors.yellow[100]),
//           child: buildStateDropdownButton(),
//         ),
//       ],
//     );
//   }

//   Widget buildStateDropdownButton() {
//     return DropdownButton<String>(
//       dropdownColor: Colors.yellow[100],
//       underline: SizedBox(),
//       onChanged: (String newValue) {
//         setState(() {
//           currentState = newValue;
//         });
//       },
//       hint: currentState == null ? Text('Select State') : Text(currentState),
//       items: state.map((String document) {
//         return new DropdownMenuItem<String>(
//             value: document,
//             child: new Text(
//               document,
//             ));
//       }).toList(),
//     );
//   }

//   Widget buildMobileNoField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "Mobile No.",
//           style: Variables.inputLabelTextStyle,
//         ),
//         Container(
//           height: 48,
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               color: Colors.yellow[100],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             cursorColor: Variables.primaryColor,
//             validator: (value) {
//               // if (value.isEmpty)
//               //   return "You cannot have an empty Selling Price!";
//               if (value.length != 10) return "Enter a valid mobile number!";
//             },
//             maxLines: 1,
//             style: Variables.inputTextStyle,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//                 border: InputBorder.none, hintText: '1234567890'),
//             controller: _mobileNoController,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildPincodeField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "Pincode",
//           style: Variables.inputLabelTextStyle,
//         ),
//         Container(
//           height: 48,
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               color: Colors.yellow[100],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             cursorColor: Variables.primaryColor,
//             validator: (value) {
//               if (value.isEmpty)
//                 return "You cannot have an empty Purchase Price!";
//               if (value.length != 6) return "Enter valid pincode!";
//             },
//             maxLines: 1,
//             keyboardType: TextInputType.number,
//             style: Variables.inputTextStyle,
//             decoration:
//                 InputDecoration(border: InputBorder.none, hintText: '123456'),
//             controller: _pincodeController,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildGSTINField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "GSTIN",
//           style: Variables.inputLabelTextStyle,
//         ),
//         Container(
//           height: 48,
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               color: Colors.yellow[100],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             cursorColor: Variables.primaryColor,
//             maxLines: 1,
//             style: Variables.inputTextStyle,
//             decoration:
//                 InputDecoration(border: InputBorder.none, hintText: 'ABCD1234'),
//             controller: _gstinController,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildAddressField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "Address",
//           style: Variables.inputLabelTextStyle,
//         ),
//         Container(
//           height: 48,
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               color: Colors.yellow[100],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             cursorColor: Variables.primaryColor,
//             validator: (value) {
//               if (value.isEmpty) return "You cannot have an empty address!";
//             },
//             maxLines: 1,
//             style: Variables.inputTextStyle,
//             decoration: InputDecoration(
//                 border: InputBorder.none, hintText: '53/2, example'),
//             controller: _addressController,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildNameField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "Name",
//           style: Variables.inputLabelTextStyle,
//         ),
//         Container(
//           height: 48,
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               color: Colors.yellow[100],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             cursorColor: Variables.primaryColor,
//             validator: (value) {
//               if (value.isEmpty) return "You cannot have an empty name!";
//             },
//             maxLines: 1,
//             style: Variables.inputTextStyle,
//             decoration:
//                 InputDecoration(border: InputBorder.none, hintText: 'Customer'),
//             controller: _nameFieldController,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildEmailField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "Email",
//           style: Variables.inputLabelTextStyle,
//         ),
//         Container(
//           height: 48,
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//               color: Colors.yellow[100],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             cursorColor: Variables.primaryColor,
//             keyboardType: TextInputType.emailAddress,
//             validator: (value) {
//               if (value.isEmpty) return "You cannot have an empty Email!";
//             },
//             maxLines: 1,
//             style: Variables.inputTextStyle,
//             decoration: InputDecoration(
//                 border: InputBorder.none, hintText: 'customer@gmail.com'),
//             controller: _emailFieldController,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
