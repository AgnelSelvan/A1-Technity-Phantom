import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/dialogs.dart';
import 'package:stock_q/widgets/widgets.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class TaxCalculator extends StatefulWidget {
  TaxCalculator({Key key}) : super(key: key);

  @override
  _TaxCalculatorState createState() => _TaxCalculatorState();
}

class _TaxCalculatorState extends State<TaxCalculator> {
  TextEditingController _grossAmountController = TextEditingController();
  TextEditingController _taxController = TextEditingController();
  TextEditingController _calculatedAmountController = TextEditingController();
  String selectedTax;
  List<String> taxList = ['Tax Inclusive', 'Tax Exclusive'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gross Amount"),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                            color: Colors.yellow[100],
                            borderRadius: BorderRadius.circular(8)),
                        child: TextFormField(
                          cursorColor: Variables.primaryColor,
                          validator: (value) {
                            if (value.isEmpty)
                              return "You cannot have an empty Purchase Price!";
                          },
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          style: Variables.inputTextStyle,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: 'Amount'),
                          controller: _grossAmountController,
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownButton<String>(
                  hint: Text("Select item"),
                  value: selectedTax,
                  onChanged: (String value) {
                    setState(() {
                      selectedTax = value;
                    });
                    //print(selectedTax);
                  },
                  items: taxList.map((String tax) {
                    return DropdownMenuItem<String>(
                      value: tax,
                      child: Row(
                        children: <Widget>[
                          Text(
                            tax,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tax in %"),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: TextFormField(
                      cursorColor: Variables.primaryColor,
                      validator: (value) {
                        if (value.isEmpty)
                          return "You cannot have an empty Purchase Price!";
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      style: Variables.inputTextStyle,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Tax'),
                      controller: _taxController,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildRaisedButton(
                    'Calculate', Variables.lightPrimaryColor, Colors.white, () {
                  calcuateAmount();
                }),
                buildRaisedButton(
                    'Clear', Colors.red[200], Variables.lightGreyColor, () {
                  setState(() {
                    _grossAmountController.clear();
                    _taxController.clear();
                    _calculatedAmountController.clear();
                    selectedTax = null;
                  });
                }),
              ],
            ),
            Container(
              margin: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Calculated amount"),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: TextFormField(
                      cursorColor: Variables.primaryColor,
                      validator: (value) {
                        if (value.isEmpty)
                          return "You cannot have an empty Purchase Price!";
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      style: Variables.inputTextStyle,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: ''),
                      controller: _calculatedAmountController,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  calcuateAmount() {
    if (selectedTax == 'Tax Exclusive') {
      double amount = double.parse(_grossAmountController.text) +
          (double.parse(_grossAmountController.text) *
              (double.parse(_taxController.text) / 100));
      setState(() {
        _calculatedAmountController =
            TextEditingController(text: amount.toString());
      });
    } else if (selectedTax == 'Tax Inclusive') {
      double amount = double.parse(_grossAmountController.text) /
          (1 + (double.parse(_taxController.text) / 100));
      //print(amount);
      setState(() {
        _calculatedAmountController =
            TextEditingController(text: amount.toString());
      });
    } else {
      Dialogs.okDialog(context, 'Error', 'Select Tax Inclusive/ Tax Exclusive!',
          Colors.red[200]);
    }
  }
}
