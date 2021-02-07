import 'dart:convert';
import 'dart:io';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:share_extend/share_extend.dart';
import 'package:vector_math/vector_math_64.dart';

class LoadAndViewCsvPage extends StatefulWidget {
  final String path;
  const LoadAndViewCsvPage({Key key, this.path}) : super(key: key);

  @override
  _LoadAndViewCsvPageState createState() => _LoadAndViewCsvPageState();
}

class _LoadAndViewCsvPageState extends State<LoadAndViewCsvPage> {
  Matrix4 matrix = Matrix4.identity();
  Matrix4 zerada = Matrix4.identity();
  @override
  Widget build(BuildContext context) {
    double _scale = 1.0;
    double _previousScale;
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("Stock Q", style: Variables.appBarTextStyle),
        actions: [
          IconButton(
              icon: Icon(
                Icons.share,
                // color: Colors.yellow[100],
              ),
              onPressed: () {
                ShareExtend.share(widget.path, "file");
              })
        ],
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
        bgColor: Variables.lightGreyColor,
      ),
      body: GestureDetector(
        onDoubleTap: () {
          setState(() {
            matrix = zerada;
          });
        },
        child: MatrixGestureDetector(
          shouldRotate: false,
          onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
            setState(() {
              matrix = m;
            });
          },
          child: Transform(
            transform: Matrix4.diagonal3(Vector3(_scale.clamp(1.0, 5.0),
                _scale.clamp(1.0, 5.0), _scale.clamp(1.0, 5.0))),
            alignment: FractionalOffset.center,
            child: FutureBuilder(
              future: _loadCsvData(),
              builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: snapshot.data
                          .map(
                            (row) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      width: 50,
                                      child: Text(row[0].toString())),
                                  Container(
                                      width: 100,
                                      child: Text(row[1].toString())),
                                  Container(
                                      width: 100,
                                      child: Text(row[2].toString())),
                                  Container(
                                      width: 100,
                                      child: Text(row[3].toString())),
                                  Container(
                                      width: 100,
                                      child: Text(row[4].toString())),
                                  Container(
                                      width: 100,
                                      child: Text(row[5].toString())),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                }

                return Center(
                  child: Text('no data found !!!'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<List<List<dynamic>>> _loadCsvData() async {
    try {
      final file = new File(widget.path).openRead();
      return await file
          .transform(utf8.decoder)
          .transform(new CsvToListConverter())
          .toList();
    } catch (e) {
      return null;
    }
  }
}
