import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/header.dart';
import 'package:stock_q/widgets/widgets.dart';

AdminMethods _adminMethods = AdminMethods();

class RegularCustomer extends StatefulWidget {
  RegularCustomer({Key key}) : super(key: key);

  @override
  _RegularCustomerState createState() => _RegularCustomerState();
}

class _RegularCustomerState extends State<RegularCustomer> {
  TextEditingController _emailFieldController = TextEditingController();
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _pincodeController = TextEditingController();
  TextEditingController _mobileNoController = TextEditingController();
  TextEditingController _gstinController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool viewVisible = false;
  String currentState;
  String currentUnit;

  List<String> state = [
    'Maharashtra',
    'Tamil Nadu',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
            title: Text("Stock Q", style: Variables.appBarTextStyle),
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 5),
                color: Colors.white,
                child: buildCustomerCard(),
              ),
            ],
          ),
        ));
  }

  handleDeleteUnit(String unitId) {
    _adminMethods.deleteUnit(unitId);
    final snackBar =
        customSnackBar('Delete Successfull!', Variables.blackColor);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void showWidget() {
    //print(viewVisible);
    setState(() {
      viewVisible = !viewVisible;
    });
    //print(viewVisible);
  }

  addCustomerToDb() {
    if (_formKey.currentState.validate()) {
      _adminMethods.isCustomerExists(_nameFieldController.text).then((value) {
        if (!value) {
          _adminMethods.addCustomerToDb(
              _nameFieldController.text,
              _emailFieldController.text,
              _addressController.text,
              currentState,
              int.parse(_pincodeController.text),
              int.parse(_mobileNoController.text),
              _gstinController.text);
          SnackBar snackbar =
              customSnackBar('Added Successfully!', Variables.blackColor);
          _scaffoldKey.currentState.showSnackBar(snackbar);
          setState(() {
            _nameFieldController.clear();
            _emailFieldController.clear();
            _addressController.clear();
            currentState = null;
            _pincodeController.clear();
            _mobileNoController.clear();
            _gstinController.clear();
          });
        } else {
          SnackBar snackbar =
              customSnackBar('Data Already Exists!', Colors.red[200]);
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
      });
    }
  }

  Card buildCustomerCard() {
    return Card(
      elevation: 3,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BuildHeader(
                text: "Customer",
              ),
              SizedBox(
                height: 15,
              ),
              viewVisible ? buildVisibility() : Container(),
              Row(
                mainAxisAlignment: viewVisible
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: <Widget>[
                  buildCustomModelButton(),
                  if (viewVisible) buildSubmissionButton() else Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector buildSubmissionButton() {
    return GestureDetector(
      onTap: addCustomerToDb,
      child: Icon(
        Icons.check_circle,
        size: 30,
        color: Colors.green[200],
      ),
    );
  }

  GestureDetector buildCustomModelButton() {
    return GestureDetector(
      onTap: () {
        showWidget();
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(100)),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.yellow[100]),
              child: Icon(
                Icons.add,
                color: Variables.blackColor,
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              "Add Customer",
              style: TextStyle(
                  letterSpacing: 1, fontSize: 16, color: Variables.blackColor),
            )
          ],
        ),
      ),
    );
  }

  Visibility buildVisibility() {
    return Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: viewVisible,
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildNameField(),
            SizedBox(
              height: 20,
            ),
            buildEmailField(),
            SizedBox(
              height: 20,
            ),
            buildAddressField(),
            SizedBox(
              height: 20,
            ),
            buildStateDropDown(),
            SizedBox(
              height: 20,
            ),
            buildPincodeField(),
            SizedBox(
              height: 20,
            ),
            buildMobileNoField(),
            SizedBox(
              height: 20,
            ),
            buildGSTINField(),
            SizedBox(
              height: 20,
            ),
          ],
        )));
  }

  Column buildUnitDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "Unit",
            style: Variables.inputLabelTextStyle,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.yellow[100]),
          child: buildUnitDropdownButton(),
        ),
      ],
    );
  }

  StreamBuilder buildUnitDropdownButton() {
    return StreamBuilder<QuerySnapshot>(
        stream: _adminMethods.fetchAllUnit(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            //print(snapshot.error);
          } else {
            if (!snapshot.hasData) {
              return CustomCircularLoading();
            }

            return new DropdownButton<DocumentSnapshot>(
              dropdownColor: Colors.yellow[100],
              underline: SizedBox(),
              onChanged: (DocumentSnapshot newValue) {
                setState(() {
                  currentUnit = newValue['unit'];
                });
              },
              hint:
                  currentUnit == null ? Text('Select Unit') : Text(currentUnit),
              items: snapshot.data.docs.map((DocumentSnapshot document) {
                return new DropdownMenuItem<DocumentSnapshot>(
                    value: document,
                    child: new Text(
                      document['unit'],
                    ));
              }).toList(),
            );
          }
          return CustomCircularLoading();
        });
  }

  Column buildStateDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "State",
            style: Variables.inputLabelTextStyle,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.yellow[100]),
          child: buildStateDropdownButton(),
        ),
      ],
    );
  }

  Widget buildStateDropdownButton() {
    return DropdownButton<String>(
      dropdownColor: Colors.yellow[100],
      underline: SizedBox(),
      onChanged: (String newValue) {
        setState(() {
          currentState = newValue;
        });
      },
      hint: currentState == null ? Text('Select State') : Text(currentState),
      items: state.map((String document) {
        return new DropdownMenuItem<String>(
            value: document,
            child: new Text(
              document,
            ));
      }).toList(),
    );
  }

  Widget buildMobileNoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Mobile No.",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              // if (value.isEmpty)
              //   return "You cannot have an empty Selling Price!";
              if (value.length != 10) return "Enter a valid mobile number!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: '1234567890'),
            controller: _mobileNoController,
          ),
        ),
      ],
    );
  }

  Widget buildPincodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Pincode",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty)
                return "You cannot have an empty Purchase Price!";
              if (value.length != 6) return "Enter valid pincode!";
            },
            maxLines: 1,
            keyboardType: TextInputType.number,
            style: Variables.inputTextStyle,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '123456'),
            controller: _pincodeController,
          ),
        ),
      ],
    );
  }

  Widget buildGSTINField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "GSTIN",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'ABCD1234'),
            controller: _gstinController,
          ),
        ),
      ],
    );
  }

  Widget buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Address",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty) return "You cannot have an empty address!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: '53/2, example'),
            controller: _addressController,
          ),
        ),
      ],
    );
  }

  Widget buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Name",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty) return "You cannot have an empty name!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'Customer'),
            controller: _nameFieldController,
          ),
        ),
      ],
    );
  }

  Widget buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Email",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value.isEmpty) return "You cannot have an empty Email!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'customer@gmail.com'),
            controller: _emailFieldController,
          ),
        ),
      ],
    );
  }
}
