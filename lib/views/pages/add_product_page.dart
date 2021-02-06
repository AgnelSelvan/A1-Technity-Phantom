import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/services/datastore.dart';
import 'package:stock_q/styles/custom.dart';
import 'package:stock_q/widgets/in_section_spacing.dart';
import 'package:stock_q/widgets/primary_button.dart';
import 'package:stock_q/widgets/section_spacing.dart';

class AddProductPage extends StatefulWidget {
  final Datastore datastore;
  final Product product;
  AddProductPage({this.datastore, this.product});
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  TextEditingController _productTitleController = TextEditingController();
  TextEditingController _productDescriptionController = TextEditingController();
  TextEditingController _productPriceController = TextEditingController();
  TextEditingController _productDiscountController = TextEditingController();
  TextEditingController _productStockController = TextEditingController();
  List<Map<String, dynamic>> inputFields;
  File _thumbnailImage;
  List<File> _previewImages = [];
  List<Map<String, dynamic>> _previewImagesDownloadUrl = [];
  Map<String, dynamic> _thumbnailImageDownloadUrl;
  bool _saving = false;
  bool _thumnailImageLoading = false;
  bool _previewImageLoading = false;
  @override
  void initState() {
    super.initState();
    inputFields = [
      {
        "textEditingController": _productTitleController,
        "label": "Title",
        "hintText": "Awesome car"
      },
      {
        "textEditingController": _productDescriptionController,
        "label": "Descripton",
        "hintText": "Car can travel very fast ..."
      },
      {
        "textEditingController": _productPriceController,
        "label": "Price",
        "hintText": "₹ 1200"
      },
      {
        "textEditingController": _productDiscountController,
        "label": "Discount",
        "hintText": "20 %"
      },
      {
        "textEditingController": _productStockController,
        "label": "Stocks Available",
        "hintText": "10"
      },
    ];
    if (widget.product != null) {
      log(widget.product.productId);
      _productTitleController.text = widget.product.title;
      _productDescriptionController.text = widget.product.description;
      _productPriceController.text = widget.product.price.toString();
      _productDiscountController.text = widget.product.discount.toString();
      _productStockController.text = widget.product.stock.toString();
      _thumbnailImageDownloadUrl = widget.product.thumbnailImage;
      _previewImagesDownloadUrl = widget.product.previewImages;
    }
    setState(() {});
  }

  setsavingTrue() {
    setState(() {
      _saving = true;
    });
  }

  setThumbnailImageLoadingTrue() {
    setState(() {
      _thumnailImageLoading = true;
    });
  }

  setPreviewImageLoadingTrue() {
    setState(() {
      _previewImageLoading = true;
    });
  }

  saveProduct() async {
    setsavingTrue();
    log('saving');
    var title = _productTitleController.text;
    var description = _productDescriptionController.text;
    var price = int.parse(_productPriceController.text);
    var discount = int.parse(_productDiscountController.text);
    var stock = int.parse(_productStockController.text);

    if (_thumbnailImageDownloadUrl != null &&
        _previewImagesDownloadUrl.length > 0 &&
        description.length > 0 &&
        price != null &&
        discount != null &&
        stock != null) {
      if (widget.product.productId != null) {
        log('hello');
        Map<String, dynamic> product = {
          "productId": widget.product.productId,
          "title": title,
          "description": description,
          "price": price,
          "discount": discount,
          "stock": stock,
          "thumbImage": _thumbnailImageDownloadUrl,
          "previewImages": _previewImagesDownloadUrl
        };
        widget.datastore.updateProduct(widget.product.productId, product);
      } else {
        String id = widget.datastore.getProductId();
        Map<String, dynamic> product = {
          "productId": id,
          "title": title,
          "description": description,
          "price": price,
          "discount": discount,
          "stock": stock,
          "thumbImage": _thumbnailImageDownloadUrl,
          "previewImages": _previewImagesDownloadUrl
        };
        widget.datastore.addProduct(id, product);
      }
      log('saved');
    }
    log('saving cancel');
    _saving = false;
    setState(() {});
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 88,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          'Add Product',
          style: Custom().appbarTitleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InSectionSpacing(),
            Column(
                children: inputFields.map((f) {
              return _buildProductDetailFields(f);
            }).toList()),
            _chooseImage(),
            _thumnailImageLoading
                ? CircularProgressIndicator()
                : Stack(
                    children: <Widget>[
                      _thumbnailImageDownloadUrl != null
                          ? Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          _thumbnailImageDownloadUrl[
                                              'image']))))
                          : Container(),
                      _thumbnailImageDownloadUrl != null
                          ? Container(
                              width: 100,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                    onTap: () async {
                                      String status = await widget.datastore
                                          .deleteProductImage(
                                              _thumbnailImageDownloadUrl['id']);
                                      if (status == 'success') {
                                        _thumbnailImageDownloadUrl = null;
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                        margin:
                                            EdgeInsets.only(right: 4, top: 4),
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                            color: Colors.red[200]
                                                .withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(36)),
                                        child: Icon(Icons.close))),
                              ),
                            )
                          : Container()
                    ],
                  ),
            InSectionSpacing(),
            _choosePreviewImage(),
            SectionSpacing(),
            Opacity(
                opacity: _saving ? 0.25 : 1,
                child: PrimaryButton(_saving ? 'Saving..' : 'Save', () {
                  if (!_saving) saveProduct();
                })),
            _saving ? CircularProgressIndicator() : Container()
          ],
        ),
      )),
    );
  }

  Widget _choosePreviewImage() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Text(
        'Choose Preview Image *',
        style: Custom().inputLabelTextStyle,
      ),
      SizedBox(height: 4),
      GestureDetector(
        onTap: () {
          getImageForPreview();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Choose Image', style: Custom().hintTextStyle)),
        ),
      ),
      SizedBox(
        height: 8,
      ),
      Row(
        children: <Widget>[
          _previewImagesDownloadUrl.length > 0
              ? Row(
                  children: _previewImagesDownloadUrl.map((p) {
                    int idx = _previewImagesDownloadUrl.indexOf(p);
                    return Stack(children: [
                      Container(
                        child: _previewImageLoading
                            ? Center(child: CircularProgressIndicator())
                            : Container(),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(p['image']))),
                      ),
                      Container(
                        width: 100,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                              onTap: () async {
                                String status = await widget.datastore
                                    .deleteProductImage(
                                        _previewImagesDownloadUrl[idx]['id']);
                                if (status == 'success') {
                                  _previewImagesDownloadUrl.removeAt(idx);
                                }
                                setState(() {});
                              },
                              child: Container(
                                  margin: EdgeInsets.only(right: 4, top: 4),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      color: Colors.red[200].withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(36)),
                                  child: Icon(Icons.close))),
                        ),
                      )
                    ]);
                  }).toList(),
                )
              : Container(),
        ],
      ),
    ]);
  }

  Widget _chooseImage() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Choose Thumbnail Image *',
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              getImageForThumbnail();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 36,
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8)),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Choose Image', style: Custom().hintTextStyle)),
            ),
          ),
          SizedBox(
            height: 8,
          ),
        ]);
  }

  Future getImageForThumbnail() async {
    setThumbnailImageLoadingTrue();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var id = generateId();
    String downloadUrl = await widget.datastore.addProductImage(image, id);
    setState(() {
      _thumbnailImage = image;
      _thumbnailImageDownloadUrl = {'id': id, 'image': downloadUrl};
      _thumnailImageLoading = false;
    });
  }

  Future getImageForPreview() async {
    setPreviewImageLoadingTrue();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var id = generateId();
    String downloadUrl = await widget.datastore.addProductImage(image, id);
    setState(() {
      _previewImages.add(image);
      _previewImagesDownloadUrl.add({'id': id, 'image': downloadUrl});
      _previewImageLoading = false;
    });
  }

  Widget _buildProductDetailFields(Map<String, dynamic> f) {
    log(f["label"]);
    if (f["label"].toString() == "Description") {
      log('hlelo');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          f["label"] + " *",
          style: Custom().inputLabelTextStyle,
        ),
        SizedBox(height: 4),
        Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              minLines: f["label"] == "Description" ? 3 : 1,
              maxLines: f["label"] == "Description" ? 3 : 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: Custom().hintTextStyle,
                  hintText: "Eg. " + f["hintText"]),
              controller: f["textEditingController"],
            ),
          ),
        ),
        InSectionSpacing()
      ],
    );
  }
}
