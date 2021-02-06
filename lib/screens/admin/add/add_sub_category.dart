import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:stock_q/models/sub-category.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/custom_divider.dart';
import 'package:stock_q/widgets/header.dart';
import 'package:stock_q/widgets/widgets.dart';

AdminMethods _adminMethods = AdminMethods();

class AddSubCategory extends StatefulWidget {
  AddSubCategory({Key key}) : super(key: key);

  @override
  _AddSubCategoryState createState() => _AddSubCategoryState();
}

class _AddSubCategoryState extends State<AddSubCategory> {
  TextEditingController _nameFieldController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool viewVisible = false;
  String currenthsnCode;
  DocumentSnapshot currentCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 5),
              color: Colors.white,
              child: buildSubCategoryCard(),
            ),
          ],
        ),
      ),
    );
  }

  void showWidget() {
    //print(viewVisible);
    setState(() {
      viewVisible = !viewVisible;
    });
    //print(viewVisible);
  }

  void addCategoryToDb() {
    _adminMethods
        .isSubCategoryExists(_nameFieldController.text, currenthsnCode)
        .then((value) {
      if (!value) {
        _adminMethods.addSubCategoryToDb(
            _nameFieldController.text, currenthsnCode);
        SnackBar snackbar =
            customSnackBar('Added Successfully!', Variables.blackColor);
        _scaffoldKey.currentState.showSnackBar(snackbar);
        setState(() {
          currenthsnCode = null;
          _nameFieldController.clear();
        });
      } else {
        SnackBar snackbar = customSnackBar('Data Already Exists!', Colors.red);
        _scaffoldKey.currentState.showSnackBar(snackbar);
      }
    });
  }

  void handleDeleteSubCategory(String id) {
    _adminMethods.deleteSubCategory(id);
    final snackbar =
        customSnackBar("Deleted Successfullt!", Variables.blackColor);
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Card buildSubCategoryCard() {
    return Card(
      elevation: 3,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              BuildHeader(
                text: "Sub-Category",
              ),
              SizedBox(
                height: 15,
              ),
              buildSubCategoryTable(),
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

  StreamBuilder buildSubCategoryTable() {
    return StreamBuilder(
        stream: _adminMethods.fetchAllSubCategory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.documents.length != 0) {
              return Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      buildTableHeader(),
                      buildTableBody(),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              );
            } else {
              return Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      "Click Add Sub-Category for adding units!",
                      style: TextStyle(
                          color: Variables.blackColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5),
                    ),
                  ),
                  SizedBox(height: 20)
                ],
              );
            }
          }
          return CustomCircularLoading();
        });
  }

  Container buildTableBody() {
    return Container(
      width: double.infinity,
      height: 100,
      child: StreamBuilder(
        stream: _adminMethods.fetchAllSubCategory(),
        builder: (context, snapshot) {
          var docs = snapshot.data.documents;
          if (snapshot.hasData) {
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                SubCategory subCategory = SubCategory.fromMap(docs[index].data);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                        width: 80,
                        child: Text(subCategory.hsnCode,
                            style: TextStyle(
                                fontSize: 16, color: Variables.blackColor))),
                    Container(
                        width: 80,
                        child: Text(subCategory.productName,
                            style: TextStyle(
                                fontSize: 16, color: Variables.blackColor))),
                    GestureDetector(
                      onTap: () {
                        handleDeleteSubCategory(subCategory.id);
                      },
                      child: Container(
                          width: 5,
                          child: Icon(
                            FontAwesome.times_circle,
                            size: 20,
                            color: Colors.red,
                          )),
                    )
                  ],
                );
              },
            );
          }
          return CustomCircularLoading();
        },
      ),
    );
  }

  Row buildTableHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
            width: 80,
            child: Column(
              children: <Widget>[
                Text(
                  'HSN Code',
                  style: TextStyle(fontSize: 16, color: Variables.blackColor),
                ),
                CustomDivider(leftSpacing: 2, rightSpacing: 2)
              ],
            )),
        Container(
            width: 80,
            child: Column(
              children: <Widget>[
                Text(
                  "Name",
                  style: TextStyle(fontSize: 16, color: Variables.blackColor),
                ),
                CustomDivider(leftSpacing: 2, rightSpacing: 2)
              ],
            )),
        Container(
          width: 5,
        )
      ],
    );
  }

  GestureDetector buildSubmissionButton() {
    return GestureDetector(
      onTap: addCategoryToDb,
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
              "Add Unit",
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
            buildUnderDropDown(),
            SizedBox(
              height: 20,
            ),
          ],
        )));
  }

  Column buildUnderDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "Under",
            style: Variables.inputLabelTextStyle,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.yellow[100]),
          child: buildDropdownButton(),
        ),
      ],
    );
  }

  StreamBuilder buildDropdownButton() {
    return StreamBuilder<QuerySnapshot>(
        stream: _adminMethods.fetchAllCategory(),
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
                  currenthsnCode = newValue.data['hsn_code'];
                });
              },
              hint: currenthsnCode == null
                  ? Text('Select Category')
                  : Text(currenthsnCode),
              items: snapshot.data.documents.map((DocumentSnapshot document) {
                return new DropdownMenuItem<DocumentSnapshot>(
                    value: document,
                    child: new Text(
                      document.data['hsn_code'],
                    ));
              }).toList(),
            );
          }
          return CustomCircularLoading();
        });
  }

  Widget buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "Product Name",
            style: Variables.inputLabelTextStyle,
          ),
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
                return "You cannot have an empty product name!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: '150Mtr Ameto'),
            controller: _nameFieldController,
          ),
        ),
      ],
    );
  }
}
