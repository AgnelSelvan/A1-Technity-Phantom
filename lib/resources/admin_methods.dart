import 'package:stock_q/constants/strings.dart';
import 'package:stock_q/models/bill.dart';
import 'package:stock_q/models/borrow.dart';
import 'package:stock_q/models/category.dart';
import 'package:stock_q/models/paid.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/stock.dart';
import 'package:stock_q/models/sub-category.dart';
import 'package:stock_q/models/unit.dart';
import 'package:stock_q/models/user.dart';
import 'package:stock_q/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMethods {
  static final _firestore = Firestore.instance;

  CollectionReference _unitCollection = _firestore.collection(UNITS_STRING);
  CollectionReference _categoryCollection =
      _firestore.collection(CATEGORIES_STRING);
  CollectionReference _subCategoryCollection =
      _firestore.collection('sub_categories');
  CollectionReference _productCollection = _firestore.collection('product');
  CollectionReference _customerCollection = _firestore.collection('customers');
  CollectionReference _borrowsCollection = _firestore.collection('borrows');
  CollectionReference _stocksCollection = _firestore.collection('stocks');
  CollectionReference _billsCollection = _firestore.collection('bills');
  CollectionReference _paidsCollection = _firestore.collection('paids');

  Future<void> addSymbolToDb(String formalName, String symbol) async {
    Unit unit = Unit(formalName: formalName, unit: symbol, unitId: symbol);
    await _unitCollection.document(symbol).setData(unit.toMap(unit));
  }

  Future<bool> isUnitExists(String symbol) async {
    try {
      QuerySnapshot docs =
          await _unitCollection.where('unit', isEqualTo: symbol).getDocuments();
      List<DocumentSnapshot> doc = docs.documents;
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
    await _unitCollection.document(unit).delete();
  }

  Future<void> addCategoryToDb(
      String hsnCode, String productName, int tax) async {
    String docId = _categoryCollection.document().documentID;
    Category category = Category(
      id: docId,
      hsnCode: hsnCode,
      productName: productName,
      tax: tax,
    );
    _categoryCollection.document(docId).setData(category.toMap(category));
  }

  Future<bool> isCategoryExists(String hsnCode) async {
    try {
      QuerySnapshot docs = await _categoryCollection
          .where('hsn_code', isEqualTo: hsnCode)
          .getDocuments();
      List<DocumentSnapshot> doc = docs.documents;
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
    await _categoryCollection.document(id).delete();
  }

  Future<void> addSubCategoryToDb(String productName, String hsnCode) async {
    String docId = _subCategoryCollection.document().documentID;
    SubCategory subCategory =
        SubCategory(id: docId, productName: productName, hsnCode: hsnCode);
    _subCategoryCollection
        .document(docId)
        .setData(subCategory.toMap(subCategory));
  }

  Future<bool> isSubCategoryExists(String productName, String hsnCode) async {
    try {
      QuerySnapshot docs = await _subCategoryCollection
          .where('product_name', isEqualTo: productName)
          .where('hsn_code', isEqualTo: hsnCode)
          .getDocuments();
      List<DocumentSnapshot> doc = docs.documents;
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
    await _subCategoryCollection.document(id).delete();
  }

  Future<void> addProductToDb(String code, String name, double purchaseRate,
      double sellingRate, String hsnCode, String unit, int unitQty) async {
    String docId = _productCollection.document().documentID;
    Product product = Product(
        id: docId,
        name: name,
        code: code,
        hsnCode: hsnCode,
        unit: unit,
        purchaseRate: purchaseRate,
        sellingRate: sellingRate,
        unitQty: unitQty);
    _productCollection.document(docId).setData(product.toMap(product));
    addStockToDb(docId, code, 0);
  }

  Future<String> getUnitNameByUnitId(String unitId) async {
    DocumentSnapshot doc = await _unitCollection.document(unitId).get();
    Unit unit = Unit.fromMap(doc.data);
    return unit.unit;
  }

  Future<bool> isProductExists(String code) async {
    try {
      QuerySnapshot docs = await _productCollection
          .where('code', isEqualTo: code)
          .getDocuments();

      List<DocumentSnapshot> doc = docs.documents;

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
    String docId = _customerCollection.document().documentID;
    User user = User(
        uid: docId,
        name: name,
        email: email,
        address: address,
        state: state,
        pincode: pincode,
        mobileNo: mobileNo.toString().trim(),
        gstin: gstin);
    _customerCollection.document(docId).setData(user.toMap(user));
  }

  Future<bool> isCustomerExists(String name) async {
    try {
      QuerySnapshot docs = await _customerCollection
          .where('name', isEqualTo: name)
          .getDocuments();

      List<DocumentSnapshot> doc = docs.documents;

      return doc.length == 0 ? false : true;
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot> fetchAllCustomer() {
    return _customerCollection.snapshots();
  }

  Future<Category> getTaxFromHsn(String hsnCode) async {
    QuerySnapshot docs = await _categoryCollection
        .where('hsn_code', isEqualTo: hsnCode)
        .getDocuments();
    List<DocumentSnapshot> doc = docs.documents;
    //print('doc:${doc[0].data["tax"]}');

    Category category = Category.fromMap(doc[0].data);

    return category;
  }

  Future<void> addStockToDb(
      String productId, String productCode, int qty) async {
    String docId = Utils.getDocId();
    Stock stock = Stock(
        stockId: docId,
        productId: productId,
        productCode: productCode,
        qty: qty);
    _stocksCollection.document(docId).setData(stock.toMap(stock));
  }

  Future<bool> isStockExists(String productId) async {
    QuerySnapshot docs = await _stocksCollection
        .where('product_id', isEqualTo: productId)
        .getDocuments();
    return docs.documents.length == 0 ? false : true;
  }

  Future<Stock> getStockDetails(String productId) async {
    Stock stock;
    //print(productId);
    QuerySnapshot docs = await _stocksCollection
        .where('product_id', isEqualTo: productId)
        .getDocuments();
    List<DocumentSnapshot> doc = docs.documents;
    //print(doc.length);
    if (doc.length == 1) {
      //print("Yes");
      stock = Stock.fromMap(doc[0].data);
    }

    return stock;
  }

  Future<void> updateStockById(String stockId, int qty) async {
    await _stocksCollection.document(stockId).updateData({'quantity': qty});
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
    QuerySnapshot docs = await _productCollection
        .where('code', isEqualTo: qrCode)
        .getDocuments();

    return docs.documents.length == 0 ? false : true;
  }

  Future<Product> getProductDetailsByQrCode(String qrCode) async {
    QuerySnapshot docs = await _productCollection
        .where('code', isEqualTo: qrCode)
        .getDocuments();
    List<DocumentSnapshot> doc = docs.documents;
    Product product = Product.fromMap(doc[0].data);
    return product;
  }

  // Future<void> addBorrowToDb(BorrowModel borrowModel) async {
  //   QuerySnapshot docs = await _borrowsCollection.getDocuments();
  //   List<DocumentSnapshot> docsList = docs.documents.toList();
  //   bool isDataExists = false;
  //   String existsBorrowId;
  //   for (var doc in docsList) {
  //     BorrowModel borrow = BorrowModel.fromMap(doc.data);
  //     if (borrow.customerName == borrowModel.customerName) {
  //       isDataExists = true;
  //       existsBorrowId = borrow.borrowId;
  //     }
  //   }
  //   //print(isDataExists);
  //   if (isDataExists) {
  //     //print(existsBorrowId);
  //     await _borrowsCollection
  //         .document(existsBorrowId)
  //         .collection('same_user_borrow')
  //         .document(borrowModel.borrowId)
  //         .setData(borrowModel.toMap(borrowModel));
  //   } else {
  //     await _borrowsCollection
  //         .document(borrowModel.borrowId)
  //         .setData(borrowModel.toMap(borrowModel));
  //   }
  // }

  Future<void> addBorrowToDb(Borrow borrow) async {
    QuerySnapshot docs = await _borrowsCollection.getDocuments();
    List<DocumentSnapshot> docsList = docs.documents.toList();
    DocumentSnapshot recentBill =
        await _billsCollection.document(borrow.billId).get();
    bool isDataExists = false;
    String existsBorrowId;
    for (var doc in docsList) {
      Borrow oldBorrow = Borrow.fromMap(doc.data);
      DocumentSnapshot billDoc =
          await _billsCollection.document(oldBorrow.billId).get();
      Bill oldBill = Bill.fromMap(billDoc.data);
      if (oldBill.mobileNo == recentBill.data['mobile_no']) {
        isDataExists = true;
        existsBorrowId = oldBorrow.borrowId;
      }
    }
    if (isDataExists) {
      _borrowsCollection
          .document(existsBorrowId)
          .collection('same_user_borrow')
          .document(borrow.borrowId)
          .setData(borrow.toMap(borrow));
    } else {
      await _borrowsCollection
          .document(borrow.borrowId)
          .setData(borrow.toMap(borrow));
    }
  }

  // Future<int> getTotalAmountByBillId(String borrowId) async {
  //   var amount = 0;
  //   DocumentSnapshot doc = await _borrowsCollection.document(borrowId).get();
  //   amount = amount + (doc.data['price'] - doc.data['given_amount']);

  //   QuerySnapshot docs = await _borrowsCollection
  //       .document(borrowId)
  //       .collection('same_user_borrow')
  //       .getDocuments();
  //   List<DocumentSnapshot> docsList = docs.documents.toList();
  //   for (var doc in docsList) {
  //     BorrowModel borrowModel = BorrowModel.fromMap(doc.data);
  //     amount = amount + (borrowModel.price - borrowModel.givenAmount);
  //   }

  //   return amount;
  // }
  Future<double> getTotalAmountByBorrowId(String borrowId) async {
    double amount = 0;
    DocumentSnapshot doc = await _borrowsCollection.document(borrowId).get();
    DocumentSnapshot billDoc =
        await _billsCollection.document(doc.data['bill_id']).get();

    amount = amount + (billDoc.data['price'] - billDoc.data['given_amount']);

    QuerySnapshot docs = await _borrowsCollection
        .document(borrowId)
        .collection('same_user_borrow')
        .getDocuments();
    List<DocumentSnapshot> docsList = docs.documents.toList();
    for (var doc in docsList) {
      Borrow borrow = Borrow.fromMap(doc.data);
      DocumentSnapshot borrowDocSearch =
          await _billsCollection.document(borrow.billId).get();
      Bill bill = Bill.fromMap(borrowDocSearch.data);
      amount = amount + (bill.price - bill.givenAmount);
    }

    return amount;
  }

  Future<List<DocumentSnapshot>> getListOfBorrow(String borrowId) async {
    QuerySnapshot docs = await _borrowsCollection
        .document(borrowId)
        .collection('same_user_borrow')
        .getDocuments();
    List<DocumentSnapshot> docsList = docs.documents.toList();
    // for (var doc in docsList) {
    //   BorrowModel borrowModel = BorrowModel.fromMap(doc.data);
    //   //print(borrowModel.borrowId);
    // }
    return docsList;
  }

  Stream<QuerySnapshot> getAllBorrowList() {
    return _borrowsCollection.snapshots();
  }

  Future<double> totalAmountYouWillGet() async {
    QuerySnapshot docs = await _borrowsCollection.getDocuments();
    List<DocumentSnapshot> docList = docs.documents.toList();
    double sum = 0;
    for (var i = 0; i < docList.length; i++) {
      Borrow borrow = Borrow.fromMap(docList[i].data);
      QuerySnapshot manyBorrow = await _borrowsCollection
          .document(borrow.borrowId)
          .collection('same_user_borrow')
          .getDocuments();

      List<DocumentSnapshot> sameUserborrowsList =
          manyBorrow.documents.toList();

      DocumentSnapshot doc =
          await _billsCollection.document(borrow.billId).get();
      Bill bill = Bill.fromMap(doc.data);
      sum = sum + (bill.price - bill.givenAmount);
      for (var sameUserBorrow in sameUserborrowsList) {
        Borrow lastborrow = Borrow.fromMap(sameUserBorrow.data);
        DocumentSnapshot doc =
            await _billsCollection.document(lastborrow.billId).get();
        Bill bill = Bill.fromMap(doc.data);
        sum = sum + (bill.price - bill.givenAmount);
      }
    }
    return sum;
  }

  Future<List<DocumentSnapshot>> getAllBills() async {
    QuerySnapshot docs = await _billsCollection
        .orderBy('bill_no', descending: false)
        .getDocuments();
    List<DocumentSnapshot> docsList = docs.documents.toList();
    //print(docsList.length);
    return docsList;
  }

  Future<Bill> getBillById(String billId) async {
    try {
      //print(billId);
      DocumentSnapshot doc = await _billsCollection.document(billId).get();

      Bill bill = Bill.fromMap(doc.data);
      //print(bill.customerName);
      return bill;
    } catch (e) {
      //print(e);
      return null;
    }
  }

  Future<Borrow> getBorrowById(String borrowId) async {
    DocumentSnapshot doc = await _borrowsCollection.document(borrowId).get();
    Borrow borrowModel = Borrow.fromMap(doc.data);
    return borrowModel;
  }

  Future<Product> getProductDetailsFromProductId(String productId) async {
    DocumentSnapshot doc = await _productCollection.document(productId).get();

    Product product = Product.fromMap(doc.data);
    return product;
  }

  Future<List<Bill>> getBorrowListOfMe(User currentUser) async {
    QuerySnapshot docs = await _borrowsCollection.getDocuments();
    List<DocumentSnapshot> docsList = docs.documents.toList();
    List<Bill> myBorrowList = List();

    // for (var doc in docsList) {
    //   DocumentSnapshot myBill =
    //       await _billsCollection.document(doc['bill_id']).get();

    //   QuerySnapshot myList = await _billsCollection
    //       .where('mobile_no',
    //           isEqualTo: currentUser.mobileNo.replaceAll(' ', ''))
    //       .getDocuments();
    //   myBorrowList = myList.documents.toList();
    // }
    //print("currentUser.mobileNo:${currentUser.mobileNo}");
    for (var doc in docsList) {
      Borrow thisDoc = Borrow.fromMap(doc.data);
      Bill bill = await getBillById(thisDoc.billId);
      //print("bill.mobileNo:${bill.mobileNo}");
      if (currentUser.mobileNo == bill.mobileNo) {
        myBorrowList.add(bill);
      }
    }

    // QuerySnapshot docs = await _borrowsCollection
    //     .where('mobile_no', isEqualTo: currentUser.mobileNo.trim())
    //     .getDocuments();

    return myBorrowList;
  }

  Future<bool> addBillToDb(Bill bill) async {
    try {
      _billsCollection.document(bill.billId).setData(bill.toMap(bill));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addBuyToDb(Paid paid) async {
    try {
      _paidsCollection.document(paid.buyId).setData(paid.toMap(paid));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Bill>> getTaxReport(
      Timestamp startDate, Timestamp endDate) async {
    List<Bill> billsList = List();
    QuerySnapshot docs = await _billsCollection
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .orderBy('timestamp')
        // .where('timestamp', isLessThanOrEqualTo: endDate)
        .getDocuments();

    List<DocumentSnapshot> docsList = docs.documents.toList();
    for (var doc in docsList) {
      Bill bill = Bill.fromMap(doc.data);
      // //print(bill.isTax);
      if (bill.isTax) {
        billsList.add(bill);
      }
    }

    return billsList;
  }

  Future<String> getBillNo() async {
    QuerySnapshot docs = await _billsCollection
        .orderBy('timestamp', descending: true)
        .getDocuments();
    if (docs.documents.length == 0) {
      return 1001.toString();
    }
    List<DocumentSnapshot> docsList = docs.documents.toList();

    //print(docsList[0].data['bill_no']);
    return (int.parse(docsList[0].data['bill_no']) + 1).toString();
  }

  Future<List<DocumentSnapshot>> getAllPaids() async {
    QuerySnapshot docs = await _paidsCollection.getDocuments();
    List<DocumentSnapshot> docsList = docs.documents.toList();
    return docsList;
  }

  Future<List<Bill>> getBillByMobileNo(String mobileNo) async {
    List<Bill> billsList = List();
    QuerySnapshot docs = await _billsCollection
        .where('mobile_no', isEqualTo: mobileNo)
        .getDocuments();
    List<DocumentSnapshot> docsList = docs.documents.toList();

    for (var doc in docsList) {
      Bill bill = Bill.fromMap(doc.data);
      billsList.add(bill);
    }
    return billsList;
  }

  updateGivenAmount(Bill bill, double amount) async {
    double totalAmount = bill.givenAmount + amount;
    await _billsCollection
        .document(bill.billId)
        .updateData({'given_amount': totalAmount});

    Bill recentBill = await getBillById(bill.billId);
    //print(recentBill.isPaid);

    double totalTax = 0;
    for (var tax in recentBill.taxList) {
      totalTax = totalTax + tax;
    }
    if (recentBill.isTax) {
      if (recentBill.givenAmount.round() ==
          (recentBill.price + (recentBill.price * (totalTax / 100))).round()) {
        //print((recentBill.price + (recentBill.price * (totalTax / 100)))
        // .round()
        // .toString());
        //print(recentBill.givenAmount.toString());
        await _billsCollection
            .document(bill.billId)
            .updateData({'is_paid': true});
        await _borrowsCollection.document(recentBill.borrowId).delete();
        await _borrowsCollection
            .document()
            .collection('same_user_borrow')
            .document(recentBill.borrowId)
            .delete();
        String buyId = Utils.getDocId();
        Paid paid = Paid(billId: recentBill.billId, buyId: buyId);
        await _paidsCollection.document(buyId).setData(paid.toMap(paid));
      }
    } else {
      if (recentBill.givenAmount.round() == totalAmount.round()) {
        await _billsCollection
            .document(bill.billId)
            .updateData({'is_paid': true});
        await _borrowsCollection.document(recentBill.borrowId).delete();
        String buyId = Utils.getDocId();
        Paid paid = Paid(billId: recentBill.billId, buyId: buyId);
        await _paidsCollection.document(buyId).setData(paid.toMap(paid));
      }
    }
  }
}
