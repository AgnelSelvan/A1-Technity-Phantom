import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_q/constants/strings.dart';
import 'package:stock_q/models/bill.dart';
import 'package:stock_q/models/category.dart';
import 'package:stock_q/models/paid.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/services.dart';
import 'package:stock_q/models/stock.dart';
import 'package:stock_q/models/sub-category.dart';
import 'package:stock_q/models/unit.dart';
import 'package:stock_q/models/user.dart';
import 'package:stock_q/utils/utilities.dart';

class AdminMethods {
  static final _firestore = FirebaseFirestore.instance;

  CollectionReference _unitCollection = _firestore.collection(UNITS_STRING);
  CollectionReference _categoryCollection =
      _firestore.collection(CATEGORIES_STRING);
  CollectionReference _subCategoryCollection =
      _firestore.collection('sub_categories');
  CollectionReference _productCollection = _firestore.collection('product');
  CollectionReference _customerCollection = _firestore.collection('customers');
  CollectionReference _stocksCollection = _firestore.collection('stocks');
  CollectionReference _billsCollection = _firestore.collection('bills');
  CollectionReference _paidsCollection = _firestore.collection('paids');
  CollectionReference _servicesCollection = _firestore.collection('services');

  Future<void> addSymbolToDb(String formalName, String symbol) async {
    Unit unit = Unit(formalName: formalName, unit: symbol, unitId: symbol);
    await _unitCollection.doc(symbol).set(unit.toMap(unit));
  }

  Future<bool> isUnitExists(String symbol) async {
    try {
      QuerySnapshot docs =
          await _unitCollection.where('unit', isEqualTo: symbol).get();
      List<DocumentSnapshot> doc = docs.docs;
      return doc.length == 0 ? false : true;
    } catch (e) {
      //print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> fetchAllUnit() {
    return _unitCollection.snapshots();
  }

  Future<void> deleteUnit(String unit) async {
    await _unitCollection.doc(unit).delete();
  }

  Future<void> addCategoryToDb(String hsnCode, String productName, int tax) async {
    String docId = _categoryCollection.doc().id;
    Category category = Category(
      id: docId,
      hsnCode: hsnCode,
      productName: productName,
      tax: tax,
    );
    _categoryCollection.doc(docId).set(category.toMap(category));
  }

  Future<bool> isCategoryExists(String hsnCode) async {
    try {
      QuerySnapshot docs =
          await _categoryCollection.where('hsn_code', isEqualTo: hsnCode).get();
      List<DocumentSnapshot> doc = docs.docs;
      return doc.length == 0 ? false : true;
    } catch (e) {
      //print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> fetchAllCategory() {
    return _categoryCollection.snapshots();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryCollection.doc(id).delete();
  }

  Future<void> addSubCategoryToDb(String productName, String hsnCode) async {
    String docId = _subCategoryCollection.doc().id;
    SubCategory subCategory =
        SubCategory(id: docId, productName: productName, hsnCode: hsnCode);
    _subCategoryCollection.doc(docId).set(subCategory.toMap(subCategory));
  }

  Future<bool> isSubCategoryExists(String productName, String hsnCode) async {
    try {
      QuerySnapshot docs = await _subCategoryCollection
          .where('product_name', isEqualTo: productName)
          .where('hsn_code', isEqualTo: hsnCode)
          .get();
      List<DocumentSnapshot> doc = docs.docs;
      return doc.length == 0 ? false : true;
    } catch (e) {
      //print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> fetchAllSubCategory() {
    return _subCategoryCollection.snapshots();
  }

  Future<void> deleteSubCategory(String id) async {
    await _subCategoryCollection.doc(id).delete();
  }

  Future<void> addProductToDb(String code, String name, double purchaseRate,
      double sellingRate, String hsnCode, String unit, int unitQty) async {
    String docId = _productCollection.doc().id;
    Product product = Product(
        id: docId,
        name: name,
        code: code,
        hsnCode: hsnCode,
        unit: unit,
        purchaseRate: purchaseRate,
        sellingRate: sellingRate,
        unitQty: unitQty);
    _productCollection.doc(docId).set(product.toMap(product));
    addStockToDb(docId, code, 0);
  }

  Future<String> getUnitNameByUnitId(String unitId) async {
    DocumentSnapshot doc = await _unitCollection.doc(unitId).get();
    Unit unit = Unit.fromMap(doc.data());
    return unit.unit;
  }

  Future<bool> isProductExists(String code) async {
    try {
      QuerySnapshot docs =
          await _productCollection.where('code', isEqualTo: code).get();

      List<DocumentSnapshot> doc = docs.docs;

      return doc.length == 0 ? false : true;
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot> fetchAllProduct() {
    return _productCollection.snapshots();
  }

  Future<void> addCustomerToDb(String name, String email, String address,
      String state, int pincode, int mobileNo, String gstin) async {
    String docId = _customerCollection.doc().id;
    UserModel user = UserModel(
        uid: docId,
        name: name,
        email: email,
        mobileNo: mobileNo.toString().trim(),);
    _customerCollection.doc(docId).set(user.toMap(user));
  }

  Future<bool> isCustomerExists(String name) async {
    try {
      QuerySnapshot docs =
          await _customerCollection.where('name', isEqualTo: name).get();

      List<DocumentSnapshot> doc = docs.docs;

      return doc.length == 0 ? false : true;
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot> fetchAllCustomer() {
    return _customerCollection.snapshots();
  }

  Future<Category> getTaxFromHsn(String hsnCode) async {
    QuerySnapshot docs =
        await _categoryCollection.where('hsn_code', isEqualTo: hsnCode).get();
    List<DocumentSnapshot> doc = docs.docs;
    //print('doc:${doc[0].data["tax"]}');

    Category category = Category.fromMap(doc[0].data());

    return category;
  }

  Future<void> addStockToDb(String productId, String productCode, int qty) async {
    String docId = Utils.getDocId();
    Stock stock = Stock(
        stockId: docId,
        productId: productId,
        productCode: productCode,
        qty: qty);
    _stocksCollection.doc(docId).set(stock.toMap(stock));
  }

  Future<bool> isStockExists(String productId) async {
    QuerySnapshot docs =
        await _stocksCollection.where('product_id', isEqualTo: productId).get();
    return docs.docs.length == 0 ? false : true;
  }

  Future<Stock> getStockDetails(String productId) async {
    Stock stock;
    //print(productId);
    QuerySnapshot docs =
        await _stocksCollection.where('product_id', isEqualTo: productId).get();
    List<DocumentSnapshot> doc = docs.docs;
    //print(doc.length);
    if (doc.length == 1) {
      //print("Yes");
      stock = Stock.fromMap(doc[0].data());
    }

    return stock;
  }

  Future<void> updateStockById(String stockId, int qty) async {
    await _stocksCollection.doc(stockId).set({'quantity': qty});
  }

  Stream<QuerySnapshot> getStockDetailsByProductId(String productId) {
    Stream<QuerySnapshot> docs =
    _stocksCollection.where('product_id', isEqualTo: productId).snapshots();
    // //print(docs.length);
    return docs;
  }

  Stream<QuerySnapshot> getProductFromHsn(String hsnCode) {
    return _productCollection.where('hsn_code', isEqualTo: hsnCode).snapshots();
  }

  Stream<QuerySnapshot> getCategoryFromHsn(String hsnCode) {
    return _productCollection.where('hsn_code', isEqualTo: hsnCode).snapshots();
  }

  Future<bool> isQrExists(String qrCode) async {
    QuerySnapshot docs =
        await _productCollection.where('code', isEqualTo: qrCode).get();

    return docs.docs.length == 0 ? false : true;
  }

  Future<Product> getProductDetailsByQrCode(String qrCode) async {
    QuerySnapshot docs =
        await _productCollection.where('code', isEqualTo: qrCode).get();
    List<DocumentSnapshot> doc = docs.docs;
    Product product = Product.fromMap(doc[0].data());
    return product;
  }



  Future<List<DocumentSnapshot>> getAllBills() async {
    QuerySnapshot docs =
        await _billsCollection.orderBy('bill_no', descending: false).get();
    List<DocumentSnapshot> docsList = docs.docs.toList();
    //print(docsList.length);
    return docsList;
  }

  Future<Bill> getBillById(String billId) async {
    try {
      //print(billId);
      DocumentSnapshot doc = await _billsCollection.doc(billId).get();

      Bill bill = Bill.fromMap(doc.data());
      //print(bill.customerName);
      return bill;
    } catch (e) {
      //print(e);
      return null;
    }
  }


  Future<Product> getProductDetailsFromProductId(String productId) async {
    DocumentSnapshot doc = await _productCollection.doc(productId).get();

    Product product = Product.fromMap(doc.data());
    return product;
  }

  Future<bool> addBillToDb(Bill bill) async {
    try {
      _billsCollection.doc(bill.billId).set(bill.toMap(bill));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addBuyToDb(Paid paid) async {
    try {
      _paidsCollection.doc(paid.buyId).set(paid.toMap(paid));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Bill>> getTaxReport(Timestamp startDate, Timestamp endDate) async {
    List<Bill> billsList = List();
    QuerySnapshot docs = await _billsCollection
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .orderBy('timestamp')
        // .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();

    List<DocumentSnapshot> docsList = docs.docs.toList();
    for (var doc in docsList) {
      Bill bill = Bill.fromMap(doc.data());
      // //print(bill.isTax);
      if (bill.isTax) {
        billsList.add(bill);
      }
    }

    return billsList;
  }

  Future<String> getBillNo() async {
    QuerySnapshot docs =
        await _billsCollection.orderBy('timestamp', descending: true).get();
    if (docs.docs.length == 0) {
      return 1001.toString();
    }
    List<DocumentSnapshot> docsList = docs.docs.toList();

    //print(docsList[0].data['bill_no']);
    return (int.parse(docsList[0]['bill_no']) + 1).toString();
  }

  Future<List<DocumentSnapshot>> getAllPaids() async {
    QuerySnapshot docs = await _paidsCollection.get();
    List<DocumentSnapshot> docsList = docs.docs.toList();
    return docsList;
  }

  Future<List<Bill>> getBillByMobileNo(String mobileNo) async {
    List<Bill> billsList = List();
    QuerySnapshot docs =
        await _billsCollection.where('mobile_no', isEqualTo: mobileNo).get();
    List<DocumentSnapshot> docsList = docs.docs.toList();

    for (var doc in docsList) {
      Bill bill = Bill.fromMap(doc.data());
      billsList.add(bill);
    }
    return billsList;
  }

  Future addServiceInDB(ServicesModel serviceModel)async{
    _servicesCollection.doc(serviceModel.serviceId).set(serviceModel.toMap(serviceModel));
  }

}
