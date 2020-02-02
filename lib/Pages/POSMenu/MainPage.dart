import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:resort_pos/LoginPage.dart';
import 'package:resort_pos/Pages/POSMenu/ProfilePage.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:resort_pos/Services/POSService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:reorderables/reorderables.dart';
import 'package:resort_pos/Services/SQLiteService.dart';

class main_page extends StatefulWidget {
  _main_page createState() => _main_page();
}

enum ProductView { TwoRow, ThreeRow }

class _main_page extends State<main_page> {
  AppFontStyle _appFontStyle;
  Authentication _authentication;
  LanguageServices _languageServices;
  POSService _posService;
  SQLiteDatabase _sqLiteDatabase;

  ProductView _productView;
  int _currentPage;
  bool searchExpand = false;
  bool isLoaded;
  List<Map<String, String>> _type;

  bool isEdit = false;
  bool categoryLoad = false;
  bool typeLoad = false;
  bool productLoad = false;

  //Category
  TextEditingController _categoryName = TextEditingController();
  File _categoryFile;
  String _categoryImageName;
  bool _categoryStatus;
  int _categorySelect;

  //Product Type
  List<dynamic> productType;
  int _productTypeSelect;
  TextEditingController _productType = TextEditingController();
  bool _productTypeStatus;

  //Product
  List<dynamic> productData;
  List<dynamic> realProductData;
  TextEditingController _productName = TextEditingController();
  TextEditingController _productPrice = TextEditingController();
  File _productImage;
  String _productImageName;
  bool _productStatus;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentPage = 0;
    _appFontStyle = new AppFontStyle();
    _productView = ProductView.TwoRow;
    isLoaded = false;
    _sqLiteDatabase = new SQLiteDatabase();

    //Category
    _categoryStatus = false;
    _categorySelect = 0;

    //ProductType
    _productTypeStatus = false;
    _productTypeSelect = 0;


    //Product
    _productStatus = false;

  }

  Future onEntry() async {
    Map<String, double> currentLocation;
    currentLocation = _authentication.getCurrentPosition();
    await http.post(
        '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/pos/enterlog.php',
        body: {
          'pos_id': _posService.getPosId(),
          'user_id': _authentication.getId(),
          'latitude': currentLocation['latitude'].toString(),
          'longitude': currentLocation['longitude'].toString(),
        });
  }

  Future deleteCategory(id) async {
    setState(() {
      isLoaded = false;
      Navigator.of(context).pop();
    });
    http.Response res = await http.post(
        '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/posmenu/deleteposcategory.php',
        body: {'pos_id': id});
    print(res.body);
    if (res.body == '1') {
      await loadCategoryData();
    }
    setState(() {
      isLoaded = true;
    });
  }

  Future uploadCategory({isUpdate: 'false', oldImage: '', categoryId: ''}) async {
    if(_categoryName.text.isEmpty){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('name')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text(_languageServices.getText('confirm')),)
          ],
        );
      });
      setState(() {
        isLoaded = true;
      });
      return;
    }

    setState(() {
      isLoaded = true;
    });

    Navigator.of(context).pop();
    Map<String, double> currentLocation = _authentication.getCurrentPosition();
    Map<String, String> categoryData = {
      'user_id': _authentication.getId(),
      'is_update': isUpdate,
      'pos_id': _posService.getPosId(),
      'name': _categoryName.text,
      'image_name': _categoryImageName == null ? 'null' : _categoryImageName,
      'image': _categoryFile == null ? 'null' : base64Encode(_categoryFile.readAsBytesSync()),
      'status': _categoryStatus ? '1' : '2',
      'old_image': oldImage == null ? 'null' : oldImage,
      'category_id': categoryId,
      'latitude': currentLocation['latitude'].toString(),
      'longitude': currentLocation['longitude'].toString()
    };
    print(categoryData);
    http.Response res = await http.post(
        '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/posmenu/addposcategory.php',
        body: categoryData);
    print(res.body);
    if (res.body != '1') {}
    clearCategory();
    setState(() {
      isLoaded = false;
    });
  }

  Future addCategoryImage() async {
    File tmp = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 128);
    String tmpName =
        '${_posService.getPosId()}_${new DateTime.now().millisecondsSinceEpoch.toString()}';
    setState(() {
      _categoryImageName = tmpName;
      _categoryFile = tmp;
    });
  }

  Future addProductImage() async {
    File tmp = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 512);
    String tmpName =
        '${productType[_productTypeSelect][0]}_${new DateTime.now().millisecondsSinceEpoch.toString()}';
    setState(() {
      _productImageName = tmpName;
      _productImage = tmp;
    });
  }

  void clearCategory() {
    setState(() {
      _categoryFile = null;
      _categoryName.text = '';
      _categoryImageName = null;
      _categoryStatus = false;
    });
  }

  void clearProductType(){
    setState(() {
      _productTypeSelect = 0;
      _productType.text = '';
      _productTypeStatus = false;
    });
  }

  void clearProduct(){
    setState(() {
      _productImage = null;
      _productImageName = null;
      _productStatus = false;
      _productName.text = '';
      _productPrice.text = '';
    });
  }

  Future addCategory() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 321,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 15),
                          child: Icon(IconData(
                              int.parse(_posService.getPosIcon()),
                              fontFamily: 'MaterialIcons')),
                        ),
                        Container(
                          child: Text(
                            "Category",
                            style: _appFontStyle.getSmallButtonText(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Color(0xffc5c5c5),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 15, top: 15),
                    padding: EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.centerLeft,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                              blurRadius: 3)
                        ]),
                    child: TextField(
                      controller: _categoryName,
                      style: _appFontStyle.getNormalText(),
                      decoration: InputDecoration.collapsed(
                        hintText: _languageServices.getText('name'),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      addCategoryImage();
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 2)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Text(
                                _categoryImageName == null
                                    ? _languageServices.getText('picture')
                                    : _categoryImageName,
                                style: _appFontStyle.getNormalText()),
                          ),
                          Container(
                            child: Icon(
                              Icons.add_photo_alternate,
                              color: Color(0xff565656),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 15),
                          child: Text(
                            "Online",
                            style: _appFontStyle.getNormalText(),
                          ),
                        ),
                        Container(
                          child: Transform.scale(
                            scale: 1.5,
                            child: Switch(
                              activeColor:
                                  Color(int.parse(_posService.getPosColor())),
                              value: _categoryStatus,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _categoryStatus = newValue;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              clearCategory();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: Color(0xffD66B6B),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      _languageServices.getText('back'),
                                      style: _appFontStyle.getLightText(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoaded = false;
                              });
                              uploadCategory().then((e) {
                                loadCategoryData().then((e) {

                                });
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: Color(0xff0076A2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.check_box,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      _languageServices.getText('confirm'),
                                      style: _appFontStyle.getLightText(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future editCategory(Map<String, dynamic> categoryData) async {
    String oldImage = categoryData['image'];
    setState(() {
      _categoryName.text = categoryData['name'];
      _categoryImageName = categoryData['image'];
      _categoryStatus = categoryData['status'] == '1' ? true : false;
    });
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 321,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 15),
                          child: Icon(IconData(
                              int.parse(_posService.getPosIcon()),
                              fontFamily: 'MaterialIcons')),
                        ),
                        Container(
                          child: Text(
                            "Category",
                            style: _appFontStyle.getSmallButtonText(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Color(0xffc5c5c5),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 15, top: 15),
                    padding: EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.centerLeft,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                              blurRadius: 3)
                        ]),
                    child: TextField(
                      controller: _categoryName,
                      style: _appFontStyle.getNormalText(),
                      decoration: InputDecoration.collapsed(
                        hintText: _languageServices.getText('name'),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      addCategoryImage();
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 2)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Text(
                                _categoryImageName == null
                                    ? _languageServices.getText('picture')
                                    : _categoryImageName,
                                style: _appFontStyle.getNormalText()),
                          ),
                          Container(
                            child: Icon(
                              Icons.add_photo_alternate,
                              color: Color(0xff565656),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 15),
                          child: Text(
                            "Online",
                            style: _appFontStyle.getNormalText(),
                          ),
                        ),
                        Container(
                          child: Transform.scale(
                            scale: 1.5,
                            child: Switch(
                              activeColor:
                                  Color(int.parse(_posService.getPosColor())),
                              value: _categoryStatus,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _categoryStatus = !_categoryStatus;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap:
                                () {
                              showDialog(
                                  context:
                                  context,
                                  builder:
                                      (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        "ยืนยันการลบหรือไม่?",
                                        style: _appFontStyle.getSmallButtonText(),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("ยกเลิก"),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            deleteCategory(categoryData['id']).then((a){
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          child: Text("ยืนยัน"),
                                        )
                                      ],
                                    );
                                  });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: Color(0xffD66B6B),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      _languageServices.getText('delete'),
                                      style: _appFontStyle.getLightText(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoaded = false;
                              });
                              uploadCategory(isUpdate: 'true', oldImage: oldImage, categoryId: categoryData['id']).then((e) {loadCategoryData().then((e) {
                                  clearCategory();
                                });
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: Color(0xff0076A2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.check_box,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      _languageServices.getText('confirm'),
                                      style: _appFontStyle.getLightText(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future deleteProductType(id) async {
    setState(() {
      isLoaded = false;
      Navigator.of(context).pop();
    });
    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/posmenu/deleteproducttype.php', body: {'product_type_id': id});
    print(res.body);
    if (res.body == '1') {
      await loadCategoryType(_categorySelect);
    }
    setState(() {
      isLoaded = true;
    });
  }

  Future loadCategoryData() async {
    setState(() {
      categoryLoad = true;
    });

    http.Response res = await http.get('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/posmenu/getposcategory.php?pos_id=${_posService.getPosId()}');
    List<dynamic> _tmpType = jsonDecode(res.body);
    List<Map<String, String>> _tmp = [];
    print(_tmpType);
    for (int i = 0; i < _tmpType.length; i++) {
      _tmp.add({
        'name': _tmpType[i][0],
        'image': _tmpType[i][1],
        'id': _tmpType[i][2],
        'status': _tmpType[i][3],
        'position': _tmpType[i][4]
      });
    }
    _tmp.add({'name':'dummy'});
    setState(() {
      _type = _tmp;
      categoryLoad = false;
      isLoaded = true;
    });
  }

  Future uploadProductType({isUpdate:'false',productTypeId: ''})async{
    if(_productType.text.isEmpty){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('name')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      setState(() {
        isLoaded = false;
      });
      return;
    }

    Navigator.of(context).pop();

    setState(() {
      isLoaded = true;
    });

    Map<String, double> currentLocation = _authentication.getCurrentPosition();
    Map<String, String> postTypeData = {
      'user_id': _authentication.getId(),
      'is_update': isUpdate,
      'product_type_id': productTypeId,
      'category_id': _type[_categorySelect]['id'],
      'name': _productType.text,
      'status': _productTypeStatus ? '1' : '2',
      'latitude': currentLocation['latitude'].toString(),
      'longitude': currentLocation['longitude'].toString()
    };
    await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/posmenu/addproducttype.php',body: postTypeData);
    clearProductType();
    setState(() {
      isLoaded = false;
    });
  }

  Future addProductType()async{
    await showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        content: Container(
          height: 321,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Icon(IconData(
                          int.parse(_posService.getPosIcon()),
                          fontFamily: 'MaterialIcons')),
                    ),
                    Container(
                      child: Text(
                        '${_type[_categorySelect]['name']} / ',
                        style: _appFontStyle.getSmallButtonText(),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Color(0xffc5c5c5),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15, top: 15),
                padding: EdgeInsets.only(left: 15, right: 15),
                alignment: Alignment.centerLeft,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          blurRadius: 3)
                    ]),
                child: TextField(
                  controller: _productType,
                  style: _appFontStyle.getNormalText(),
                  decoration: InputDecoration.collapsed(
                    hintText: _languageServices.getText('name'),
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Text(
                        "Online",
                        style: _appFontStyle.getNormalText(),
                      ),
                    ),
                    Container(
                      child: Transform.scale(
                        scale: 1.5,
                        child: Switch(
                          activeColor:
                          Color(int.parse(_posService.getPosColor())),
                          value: _productTypeStatus,
                          onChanged: (bool newValue) {
                            setState(() {
                              _productTypeStatus = !_productTypeStatus;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          clearCategory();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            color: Color(0xffD66B6B),
                            borderRadius:
                            BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                child: Text(
                                  _languageServices.getText('back'),
                                  style: _appFontStyle.getLightText(
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isLoaded = false;
                          });
                          uploadProductType().then((e){
                            loadCategoryType(_categorySelect).then((b){

                            });
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            color: Color(0xff0076A2),
                            borderRadius:
                            BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.check_box,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                child: Text(
                                  _languageServices.getText('confirm'),
                                  style: _appFontStyle.getLightText(
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future editProductType(List<dynamic> productTypeData)async{
    print(productTypeData);
    String product_type_id = productTypeData[0];
    setState(() {
      _productType.text = productTypeData[2];
      _productTypeStatus = productTypeData[3] == '1' ? true : false;
    });
    await showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        content: Container(
          height: 321,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Icon(IconData(
                          int.parse(_posService.getPosIcon()),
                          fontFamily: 'MaterialIcons')),
                    ),
                    Container(
                      child: Text(
                        '${_type[_categorySelect]['name']} / ',
                        style: _appFontStyle.getSmallButtonText(),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Color(0xffc5c5c5),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15, top: 15),
                padding: EdgeInsets.only(left: 15, right: 15),
                alignment: Alignment.centerLeft,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          blurRadius: 3)
                    ]),
                child: TextField(
                  controller: _productType,
                  style: _appFontStyle.getNormalText(),
                  decoration: InputDecoration.collapsed(
                    hintText: _languageServices.getText('name'),
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Text(
                        "Online",
                        style: _appFontStyle.getNormalText(),
                      ),
                    ),
                    Container(
                      child: Transform.scale(
                        scale: 1.5,
                        child: Switch(
                          activeColor:
                          Color(int.parse(_posService.getPosColor())),
                          value: _productTypeStatus,
                          onChanged: (bool newValue) {
                            setState(() {
                              _productTypeStatus = !_productTypeStatus;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                              context:
                              context,
                              builder:
                                  (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "ยืนยันการลบหรือไม่?",
                                    style: _appFontStyle.getSmallButtonText(),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(_languageServices.getText('back')),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        deleteProductType(productTypeData[0]).then((a){
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text(_languageServices.getText('confirm')),
                                    )
                                  ],
                                );
                              });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            color: Color(0xffD66B6B),
                            borderRadius:
                            BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                child: Text(
                                  _languageServices.getText('delete'),
                                  style: _appFontStyle.getLightText(
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isLoaded = false;
                          });
                          uploadProductType(isUpdate: 'true',productTypeId: product_type_id).then((e){
                            loadCategoryType(_categorySelect);
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            color: Color(0xff0076A2),
                            borderRadius:
                            BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.check_box,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                child: Text(
                                  _languageServices.getText('confirm'),
                                  style: _appFontStyle.getLightText(
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future loadCategoryType(int index)async{
    setState(() {
      productLoad = true;
      _productTypeSelect = 0;
    });
    String tmp = _type.length == 1 ? null : _type[index]['id'];
    http.Response res = await http.get('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/posmenu/getproducttype.php?category_id=${tmp}');
    List<dynamic> _productType = jsonDecode(res.body);
    _productType.add(['dummy']);
    setState(() {
      productType = _productType;
      productLoad = false;
      isLoaded = true;
    });
  }

  Future loadProduct(int index)async{
    setState(() {
      productLoad = true;
    });
    String tmp = productType.length == 1 ? null : productType[index][0];
    http.Response res = await http.get('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/posmenu/getproduct.php?type_id=${tmp}');
    List<dynamic> _productTmp = jsonDecode(res.body);
    List<dynamic> tmp2 = [];
    print(_productTmp);
    _productTmp.add(['dummy']);
    for(int i=0;i<_productTmp.length-1;i++){
      if(_productTmp[i][6] == '1'){
        tmp2.add(_productTmp[i]);
      }
    }
    setState(() {
      productData = _productTmp;
      realProductData = tmp2;
      print(productData);
      productLoad = false;
      isLoaded = true;
    });
  }

  Future addProduct()async{
//    print(_type[_categorySelect]['name']);
//    print(productType[_productTypeSelect][2]);
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: SingleChildScrollView(
              child: Container(
                height: 400,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Icon(IconData(
                                int.parse(_posService.getPosIcon()),
                                fontFamily: 'MaterialIcons')),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                "${_type[_categorySelect]['name']} / ${productType[_productTypeSelect][2]} / ",
                                style: _appFontStyle.getSmallButtonText(),
                                overflow: TextOverflow.clip,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Color(0xffc5c5c5),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15,left: 5, right: 5),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      alignment: Alignment.centerLeft,
                      height: _posService.getWidth()/8.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 3)
                          ]),
                      child: TextField(
                        controller: _productName,
                        style: _appFontStyle.getNormalText(),
                        decoration: InputDecoration.collapsed(
                          hintText: _languageServices.getText('name'),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15,left: 5, right: 5),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      alignment: Alignment.centerLeft,
                      height: _posService.getWidth()/8.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 3)
                          ]),
                      child: TextField(
                        controller: _productPrice,
                        keyboardType: TextInputType.number,
                        style: _appFontStyle.getNormalText(),
                        decoration: InputDecoration.collapsed(
                          hintText: _languageServices.getText('price'),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        addProductImage();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 15,left: 5, right: 5),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: _posService.getWidth()/8.5,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.3),
                                  blurRadius: 2)
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text(
                                  _productImageName == null
                                      ? _languageServices.getText('picture')
                                      : _productImageName,
                                  style: _appFontStyle.getNormalText()),
                            ),
                            Container(
                              child: Icon(
                                Icons.add_photo_alternate,
                                color: Color(0xff565656),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Text(
                              "Online",
                              style: _appFontStyle.getNormalText(),
                            ),
                          ),
                          Container(
                            child: Transform.scale(
                              scale: 1.5,
                              child: Switch(
                                activeColor:
                                Color(int.parse(_posService.getPosColor())),
                                value: _productStatus,
                                onChanged: (bool newValue) {
                                  setState(() {
                                    _productStatus = !_productStatus;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                clearProduct();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                  color: Color(0xffD66B6B),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Icon(
                                        Icons.clear,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        _languageServices.getText('back'),
                                        style: _appFontStyle.getLightText(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                              setState(() {
                                isLoaded = false;
                              });
                                uploadProduct().then((a){
                                  loadProduct(_productTypeSelect).then((b){

                                  });
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                  color: Color(0xff0076A2),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Icon(
                                        Icons.check_box,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        _languageServices.getText('confirm'),
                                        style: _appFontStyle.getLightText(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future uploadProduct({isUpdate : 'false',oldImage: '', productId: ''})async{
    if(_productName.text.isEmpty){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('name')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      setState(() {
        isLoaded = true;
      });
      return;
    }
    if(_productPrice.text.isEmpty){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('price')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      setState(() {
        isLoaded = true;
      });
      return;
    }

    Navigator.of(context).pop();

    String imageName = _productImage == null ? null : base64Encode(_productImage.readAsBytesSync());
    Map<String, double> currentLocation = _authentication.getCurrentPosition();

    Map<String, String> _productData = {
      'user_id': _authentication.getId(),
      'is_update': isUpdate,
      'product_type_id': productType[_productTypeSelect][0],
      'name': _productName.text,
      'price': _productPrice.text,
      'image': imageName == null ? 'null' : imageName,
      'image_name': _productImageName == null ? 'null' : _productImageName,
      'status': _productStatus ? '1':'2',
      'note': '',
      'latitude': currentLocation['latitude'].toString(),
      'longitude': currentLocation['longitude'].toString(),
      'product_id': productId,
      'old_image': oldImage == null ? 'null' : oldImage
    };
    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/posmenu/addproduct.php', body: _productData);
    print(res.body);
    if(res.body == '1'){

    }
    clearProduct();
    setState(() {
      isLoaded = false;
    });
  }

  Future editProduct(List<dynamic> _productData)async{
    print(_productData);
    String oldImage = _productData[5];
    setState(() {
      _productName.text = _productData[2];
      _productPrice.text = _productData[3];
      _productImageName = _productData[5];
      _productStatus = _productData[6] == '1' ? true : false;
    });
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: SingleChildScrollView(
              child: Container(
                height: 400,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Icon(IconData(
                                int.parse(_posService.getPosIcon()),
                                fontFamily: 'MaterialIcons')),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                "${_type[_categorySelect]['name']} / ${productType[_productTypeSelect][2]} / ",
                                style: _appFontStyle.getSmallButtonText(),
                                overflow: TextOverflow.clip,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Color(0xffc5c5c5),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15,left: 5, right: 5),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      alignment: Alignment.centerLeft,
                      height: _posService.getWidth()/8.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 3)
                          ]),
                      child: TextField(
                        controller: _productName,
                        style: _appFontStyle.getNormalText(),
                        decoration: InputDecoration.collapsed(
                          hintText: _languageServices.getText('name'),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15,left: 5, right: 5),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      alignment: Alignment.centerLeft,
                      height: _posService.getWidth()/8.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 3)
                          ]),
                      child: TextField(
                        controller: _productPrice,
                        keyboardType: TextInputType.number,
                        style: _appFontStyle.getNormalText(),
                        decoration: InputDecoration.collapsed(
                          hintText: _languageServices.getText('price'),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        addProductImage();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 15,left: 5, right: 5),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: _posService.getWidth()/8.5,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.3),
                                  blurRadius: 2)
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text(
                                  _productImageName == null
                                      ? _languageServices.getText('picture')
                                      : _productImageName,
                                  style: _appFontStyle.getNormalText()),
                            ),
                            Container(
                              child: Icon(
                                Icons.add_photo_alternate,
                                color: Color(0xff565656),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Text(
                              "Online",
                              style: _appFontStyle.getNormalText(),
                            ),
                          ),
                          Container(
                            child: Transform.scale(
                              scale: 1.5,
                              child: Switch(
                                activeColor:
                                Color(int.parse(_posService.getPosColor())),
                                value: _productStatus,
                                onChanged: (bool newValue) {
                                  setState(() {
                                    _productStatus = !_productStatus;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context:
                                    context,
                                    builder:
                                        (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "ยืนยันการลบหรือไม่?",
                                          style: _appFontStyle.getSmallButtonText(),
                                        ),
                                        actions: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("ยกเลิก"),
                                          ),
                                          FlatButton(
                                            onPressed: () {
                                              deleteProduct(_productData[0]).then((a){
                                                Navigator.of(context).pop();
                                              });
                                            },
                                            child: Text("ยืนยัน"),
                                          )
                                        ],
                                      );
                                    });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                  color: Color(0xffD66B6B),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Icon(
                                        Icons.clear,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        _languageServices.getText('delete'),
                                        style: _appFontStyle.getLightText(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLoaded = false;
                                });
                                uploadProduct(isUpdate: 'true',oldImage: oldImage,productId: _productData[0]).then((a){
                                  loadProduct(_productTypeSelect).then((b){
                                    clearProduct();
                                  });
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                  color: Color(0xff0076A2),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Icon(
                                        Icons.check_box,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        _languageServices.getText('confirm'),
                                        style: _appFontStyle.getLightText(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });

  }

  Future deleteProduct(id)async{
    setState(() {
      isLoaded = false;
      Navigator.of(context).pop();
    });
    http.Response res = await http.post(
        '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/posmenu/deleteproduct.php',
        body: {'product_id': id});
    print(res.body);
    if (res.body == '1') {
      await loadProduct(_productTypeSelect);
    }
    setState(() {
      isLoaded = true;
    });
  }

  void categoryReoder(int oldIndex, int newIndex) {
    if(oldIndex == _type.length -1){
      return;
    }else if(newIndex == _type.length -1){
      return;
    }
    setState(() {
      _type.insert(newIndex, _type.removeAt(oldIndex));
    });
  }

  void categoryTypeReorder(int oldIndex, int newIndex){
    if(oldIndex == productType.length -1){
      return;
    }else if(newIndex == productType.length -1){
      return;
    }
    setState(() {
      productType.insert(newIndex, productType.removeAt(oldIndex));
    });
  }

  void productReorder(int oldIndex, int newIndex) {
    if(oldIndex == productData.length -1){
      return;
    }else if(newIndex == productData.length -1){
      return;
    }
    setState(() {
      productData.insert(newIndex, productData.removeAt(oldIndex));
    });
  }


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context);
    _languageServices = Provider.of<LanguageServices>(context);
    _posService = Provider.of<POSService>(context);
    if (!isLoaded) {
      setState(() {
        isLoaded = false;
      });
      onEntry().then((e) {
        loadCategoryData().then((a){
          for(int i=0;i<_type.length;i++){
            if(_type[i]['status'] == '1'){
              setState(() {
                _categorySelect = i;
              });
              break;
            }
          }
          loadCategoryType(_categorySelect).then((b){
            if(productType.length > 1){
              for(int i=0;i<productType.length;i++){
                if(productType[i][3] == '1'){
                  setState(() {
                    _productTypeSelect = i;
                  });
                  break;
                }
              }
            }
            loadProduct(_productTypeSelect).then((c){
              print('p');
              print(productData);
              setState(() {
                isLoaded = true;
              });
            });
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _paddingBottom = MediaQuery.of(context).padding.bottom;

    // TODO: implement build
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        body: isLoaded
            ? Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: _paddingTop,
                      color: Color(int.parse(_posService.getPosColor())),
                    ),
                    Container(
                      child: Stack(
                        children: <Widget>[
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.only(top: searchExpand ? 55 : 0),
                            height: searchExpand ? 80 : 55,
                            color: Color(int.parse(_posService.getPosColor())),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    margin:
                                        EdgeInsets.only(left: 45, right: 45),
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25))),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(right: 10),
                                          child: Icon(Icons.search),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: TextField(
                                              style:
                                                  _appFontStyle.getInputText(),
                                              decoration:
                                                  InputDecoration.collapsed(
                                                      hintText: "Search"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 55,
                            color: Color(int.parse(_posService.getPosColor())),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 15),
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              color: Colors.white,
                                              size: 17,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 10),
                                          child: Icon(
                                            IconData(
                                                int.parse(
                                                    _posService.getPosIcon()),
                                                fontFamily: 'MaterialIcons'),
                                            color: Colors.white,
                                            size: 29,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                              _posService.getPosName(),
                                              style:
                                                  _appFontStyle.getTopBarText(
                                                      color: Colors.white),
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _productView = ProductView.TwoRow;
                                            _posService.setRowNumber(2);
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 15),
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _productView ==
                                                      ProductView.TwoRow
                                                  ? Color.fromRGBO(
                                                      255, 255, 255, 0.3)
                                                  : Color.fromRGBO(
                                                      1, 1, 1, 0.4)),
                                          child: Icon(
                                            Icons.dashboard,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _productView = ProductView.ThreeRow;
                                            _posService.setRowNumber(3);
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 15),
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _productView ==
                                                      ProductView.ThreeRow
                                                  ? Color.fromRGBO(
                                                      255, 255, 255, 0.3)
                                                  : Color.fromRGBO(
                                                      1, 1, 1, 0.4)),
                                          child: Icon(
                                            Icons.apps,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            searchExpand = !searchExpand;
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 15),
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: searchExpand
                                                  ? Color.fromRGBO(
                                                      255, 255, 255, 0.3)
                                                  : Color.fromRGBO(
                                                      1, 1, 1, 0.4)),
                                          child: Icon(
                                            Icons.search,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async{
                                          var res = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                            return profile_page();
                                          }));
                                          if(res != null){
                                            setState(() {
                                              isEdit = res;
                                            });
                                          }
                                        },
                                        child: _authentication
                                                    .getUserAvatar() !=
                                                null
                                            ? Container(
                                                margin:
                                                    EdgeInsets.only(left: 15),
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color.fromRGBO(
                                                      1, 1, 1, 0.4),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                        _authentication.getUserAvatar(),
                                                      ),
                                                      fit: BoxFit.cover),
                                                ),
                                              )
                                            : Container(
                                                margin:
                                                    EdgeInsets.only(left: 15),
                                                padding: EdgeInsets.all(8),
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color.fromRGBO(
                                                      1, 1, 1, 0.4),
                                                ),
                                                child: Image.asset(
                                                    'assets/icons/user.png'),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child:
//                                      child: _type.length == 1 ? Container(
//                                        padding: EdgeInsets.only(
//                                            left: 15, right: 15),
//                                        height: 85,
//                                        alignment: Alignment.centerLeft,
//                                        child: GestureDetector(
//                                          onTap: (){
//                                            setState(() {
//                                              isEdit = true;
//                                            });
//                                            addCategory();
//                                          },
//                                          child: Container(
//                                            alignment: Alignment.centerLeft,
//                                            child: Column(
//                                              mainAxisAlignment: MainAxisAlignment.center,
//                                              children: <
//                                                  Widget>[
//                                                Container(
//                                                  margin: EdgeInsets.only(
//                                                      bottom:
//                                                      5),
//                                                  height: 40,
//                                                  width: 40,
//                                                  decoration:
//                                                  BoxDecoration(
//                                                    shape: BoxShape
//                                                        .circle,
//                                                    color: Color(
//                                                        0xffb1b1b1),
//                                                  ),
//                                                  child: Icon(
//                                                    Icons
//                                                        .add_to_photos,
//                                                    color: Color(
//                                                        0xff656565),
//                                                  ),
//                                                ),
//                                                Container(
//                                                  child: Text(
//                                                    _languageServices
//                                                        .getText(
//                                                        'add'),
//                                                    style: _appFontStyle
//                                                        .getNormalText(),
//                                                  ),
//                                                ),
//                                              ],
//                                            ),
//                                          ),
//                                        )
//                                      ):
                                      isEdit
                                          ? Container(
                                              padding: EdgeInsets.only(
                                                  left: 15, right: 15),
                                              height: 85,
                                              alignment: Alignment.centerLeft,
                                              color: Color(0xffe8e8e8),
                                              child: SingleChildScrollView(
                                                child: Row(
                                                  children: <Widget>[
                                                    ReorderableWrap(
                                                      spacing: 15,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      onReorder: categoryReoder,
                                                      children: List.generate(
                                                          _type.length,
                                                          (int index) {
                                                        if (index == _type.length -1) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              addCategory();
                                                            },
                                                            child: Container(
                                                              child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    margin: EdgeInsets.only(
                                                                        bottom:
                                                                            5),
                                                                    height: 40,
                                                                    width: 40,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Color(
                                                                          0xffb1b1b1),
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .add_to_photos,
                                                                      color: Color(
                                                                          0xff656565),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: Text(
                                                                      _languageServices
                                                                          .getText(
                                                                              'add'),
                                                                      style: _appFontStyle
                                                                          .getNormalText(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        return Column(
                                                          children: <Widget>[
                                                            Container(
                                                              child: Stack(
                                                                children: <Widget>[
                                                                  Opacity(
                                                                    opacity:
                                                                        _type[index]['status'] !=
                                                                                '1'
                                                                            ? 0.3
                                                                            : 1,
                                                                    child: GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        editCategory(_type[index]);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        margin: EdgeInsets.only(
                                                                            bottom:
                                                                                5),
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            40,
                                                                        decoration: BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            color: Color(0xffa1a1a1),
                                                                            image: DecorationImage(image: _type[index]['image'] == null ? AssetImage('assets/images/pos-logo.png') : NetworkImage('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/Images/PosCategory/${_type[index]['image']}'), fit: BoxFit.cover)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              child: Text(
                                                                _type[index]
                                                                    ['name'],
                                                                style: _appFontStyle
                                                                    .getNormalText(),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : categoryLoad ? Container(alignment: Alignment.centerLeft, child: CircularProgressIndicator(),):Container(
                                              padding: EdgeInsets.only(
                                                  left: 15, right: 15),
                                              height: 85,
                                              alignment: Alignment.centerLeft,
                                              color: Color(0xffe8e8e8),
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _type.length ,
                                              itemBuilder: (BuildContext context, int index){
                                                if(index == _type.length - 1){
                                                  return Container();
                                                }
                                                if(_type[index]['status'] == '1'){
                                                  return GestureDetector(
                                                    onTap: (){
                                                      setState(() {
                                                        _categorySelect = index;
                                                        setState(() {
                                                          productLoad = true;
                                                          print(productLoad);
                                                        });
                                                        loadCategoryType(_categorySelect).then((e){
                                                          loadProduct(_productTypeSelect);
                                                        });
                                                      });
                                                    },
                                                    onLongPress: (){
                                                      if(_posService.getPermissionId() == '1' || _posService.getPermissionId() == '2'){
                                                        setState(() {
                                                          isEdit = true;
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(right: 15),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                          Container(
                                                            margin: EdgeInsets.only(bottom: 5),
                                                            height:
                                                            40,
                                                            width:
                                                            40,
                                                            decoration: BoxDecoration(
                                                                shape:
                                                                BoxShape.circle,
                                                                color: Color(0xffa1a1a1),
                                                                image: DecorationImage(image: _type[index]['image'] == null ? AssetImage('assets/images/pos-logo.png') : NetworkImage('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/Images/PosCategory/${_type[index]['image']}'), fit: BoxFit.cover),
                                                                border: Border.all(color: Color(_categorySelect != index ? 0xff : int.parse(_posService.getPosColor())),width: _categorySelect == index ? 3 : 0)
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Text(
                                                              _type[index]
                                                              ['name'],
                                                              style: _appFontStyle
                                                                  .getNormalText(),
                                                            ),
                                                          ),
                                                        ],

                                                      ),
                                                    ),
                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                            ),),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              height: 50,
                              color: Colors.white,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: isEdit ? Container(
                                      child: SingleChildScrollView(
                                        child: ReorderableWrap(
                                          onReorder: categoryTypeReorder,
                                          scrollDirection: Axis.horizontal,
                                          children: List.generate(productType == null ? 0 : productType.length, (int index){
                                            if(index == productType.length - 1){
                                              return GestureDetector(
                                                onTap: (){
                                                  addProductType();
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.only(right: 25),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        margin: EdgeInsets.only(right: 5),
                                                        child: Icon(Icons.add_to_photos,color: Color(0xff757575),size: 18,),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          _languageServices.getText('add'),
                                                          style: _appFontStyle.getSmallButtonText(color: Colors.grey),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                            return productType[index][3] != '0' ? Container(
                                              child: Stack(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: (){
                                                      setState(() {
                                                        editProductType(productType[index]).then((e){
                                                          loadProduct(0);
                                                        });
                                                      });
                                                    },
                                                    child: Container(
                                                      alignment: Alignment.center,
                                                      margin: EdgeInsets.only(right: 25),
                                                      child: Text(
                                                        productType[index][2],
                                                        style: _appFontStyle.getSmallButtonText(color: _productTypeSelect == index ? Color(int.parse(_posService.getPosColor())): productType[index][3] == '1' ? Colors.grey : Color(0xffc8c8c8)),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ):Container();
                                          }),
                                        ),
                                      ),
                                    ):typeLoad ? Container(alignment: Alignment.centerLeft,child: CircularProgressIndicator(),) : Container(
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: productType == null ? 0 : productType.length,
                                        itemBuilder: (BuildContext context, int index){
                                          if(index == productType.length - 1){
                                            return Container();
                                          }
                                          return _type[_categorySelect]['status'] == '1' ? productType[index][3] == '1' ? GestureDetector(
                                            onLongPress: (){
                                              if(_posService.getPermissionId() == '1' || _posService.getPermissionId() == '2'){
                                                setState(() {
                                                  isEdit = true;
                                                });
                                              }
                                            },
                                            onTap: (){
                                              setState(() {
                                                _productTypeSelect = index;
                                                loadProduct(_productTypeSelect);
                                              });
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.only(right: 25),
                                              child: Text(
                                                productType[index][2],
                                                style: _appFontStyle.getSmallButtonText(
                                                    color: _productTypeSelect == index ? Color(int.parse(_posService.getPosColor())):Colors.grey),
                                              ),
                                            ),
                                          ):Container():Container();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                child: isEdit
                                    ? Container(
                                        padding: EdgeInsets.only(left: 15),
                                        alignment: Alignment.topLeft,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: ReorderableWrap(
                                            padding: EdgeInsets.only(top: 10),
                                            spacing: 20,
                                            runSpacing: 20,
                                            children: List.generate(
                                                productData == null ? 0 :productData.length, (index) {
                                              if (index == productData.length - 1) {
                                                return GestureDetector(
                                                  onTap: (){
                                                    addProduct();
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 15),
                                                    height: _posService
                                                                .getWidth() /
                                                            _posService
                                                                .getRowNumber() -
                                                        25,
                                                    width: _posService
                                                                .getWidth() /
                                                            _posService
                                                                .getRowNumber() -
                                                        25,
                                                    decoration: BoxDecoration(
                                                        color: Color(0xffe1e1e1),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    child: Icon(
                                                      Icons.add_to_photos,
                                                      color: Color(0xff757575),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return GestureDetector(
                                                onTap: (){
                                                  editProduct(productData[index]);
                                                },
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Stack(
                                                          children: <Widget>[
                                                            Opacity(
                                                              opacity: productData[index][6] == '1' ? 1 : 0.3,
                                                              child: Container(
                                                                height: _posService
                                                                            .getWidth() /
                                                                        _posService
                                                                            .getRowNumber() -
                                                                    25,
                                                                width: _posService
                                                                            .getWidth() /
                                                                        _posService
                                                                            .getRowNumber() -
                                                                    25,
                                                                decoration: BoxDecoration(
                                                                    color: Color(int
                                                                        .parse(_posService
                                                                            .getPosColor())),
                                                                    borderRadius: BorderRadius
                                                                        .all(Radius
                                                                            .circular(
                                                                                10)),
                                                                    image: DecorationImage(image: productData[index][5] == null ? AssetImage('assets/images/pos-logo.png') : NetworkImage('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/Images/PosProduct/${productData[index][5]}'),fit: BoxFit.cover)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          productData[index][2],
                                                          style: _appFontStyle
                                                              .getSmallButtonText(),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          '${productData[index][3]}฿',
                                                          style: _appFontStyle
                                                              .getNormalText(
                                                                  color: Color(
                                                                      0xff656565)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                            onReorder: productReorder,
                                          ),
                                        ),
                                      ) :productLoad ? Container(alignment: Alignment.center, child: CircularProgressIndicator(),) : Container(
                                        padding: EdgeInsets.only(top: 10),
                                        child: ListView(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 0,
                                              bottom: 15),
                                          children: <Widget>[
                                            Wrap(
                                              alignment:
                                                  WrapAlignment.start,
                                              runSpacing: 10,
                                              spacing: _posService.getRowNumber() == 2 ? 20: 22,
                                              children: List.generate(realProductData.length, (index) {
                                                return _type.length != 0 ? productType.length != 0 ? _type[_categorySelect]['status'] == '1' ? productType[_productTypeSelect][3] == '1' ? GestureDetector(
                                                  onLongPress: (){
                                                    if(_posService.getPermissionId() == '1' || _posService.getPermissionId() == '2'){
                                                      setState(() {
                                                        isEdit = true;
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Container(
                                                          height: _posService
                                                                      .getWidth() /
                                                                  _posService
                                                                      .getRowNumber() -
                                                              25,
                                                          width: _posService
                                                                      .getWidth() /
                                                                  _posService
                                                                      .getRowNumber() -
                                                              25,
                                                          decoration: BoxDecoration(
                                                              color: Color(int.parse(_posService.getPosColor())),
                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                              image: DecorationImage(image: realProductData[index][5] == '' ? AssetImage('assets/images/pos-logo.png') : NetworkImage('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/Images/PosProduct/${realProductData[index][5]}'),fit: BoxFit.cover)
                                                          ),
                                                        ),
                                                        Container(
                                                          width: _posService
                                                              .getWidth() /
                                                              _posService
                                                                  .getRowNumber() -
                                                              25,
                                                          child: Text(realProductData[index][2],
                                                            style: _appFontStyle.getSmallButtonText(),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            '${realProductData[index][3]}฿',
                                                            style: _appFontStyle
                                                                .getNormalText(
                                                                    color: Color(
                                                                        0xff656565)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ):Container():Container():Container():Container();
                                              }),
                                            ),
                                          ],
                                        ),
                                      )),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: 65,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 1)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 50),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Icon(
                                          Icons.chrome_reader_mode,
                                          size: 30,
                                          color: _currentPage == 0 ? Color(int.parse(
                                                  _posService.getPosColor()))
                                              : Color(0xff333333),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _languageServices.getText('menu'),
                                          style: _appFontStyle.getLightText(
                                              color: _currentPage == 0
                                                  ? Color(int.parse(_posService
                                                      .getPosColor()))
                                                  : Color(0xff333333)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 50),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Icon(
                                          Icons.event_seat,
                                          size: 30,
                                          color: _currentPage == 1
                                              ? Color(int.parse(
                                                  _posService.getPosColor()))
                                              : Color(0xff333333),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _languageServices.getText('table'),
                                          style: _appFontStyle.getLightText(
                                              color: _currentPage == 1
                                                  ? Color(int.parse(_posService
                                                      .getPosColor()))
                                                  : Color(0xff333333)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Icon(
                                          Icons.hotel,
                                          size: 30,
                                          color: _currentPage == 2
                                              ? Color(int.parse(
                                                  _posService.getPosColor()))
                                              : Color(0xff333333),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _languageServices.getText('rooms'),
                                          style: _appFontStyle.getLightText(
                                              color: _currentPage == 2
                                                  ? Color(int.parse(_posService
                                                      .getPosColor()))
                                                  : Color(0xff333333)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isEdit ? Expanded(
                            child: GestureDetector(
                              onTap: (){
                                for(int i=0;i<_type.length;i++){
                                  if(_type[i]['status'] == '1'){
                                    setState(() {
                                      _categorySelect = i;
                                    });
                                    break;
                                  }
                                }
                                loadCategoryType(_categorySelect).then((b){
                                  if(productType.length > 1){
                                    for(int i=0;i<productType.length;i++){
                                      if(productType[i][3] == '1'){
                                        setState(() {
                                          _productTypeSelect = i;
                                        });
                                        break;
                                      }
                                    }
                                  }
                                  loadProduct(_productTypeSelect).then((c){
                                    setState(() {
                                      isLoaded = true;
                                    });
                                  });
                                });
                                setState(() {
                                  isEdit = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: 25),
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(_posService.getPosColor())),
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      child: Icon(Icons.check_box,color: Colors.white,),
                                    ),
                                    Container(
                                      child: Text(_languageServices.getText('confirm'),style: _appFontStyle.getLightText(color: Colors.white),),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ):
                          Container(
                            height: 65,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: <Widget>[
                                Container(
                                  child: Container(
                                    height: 45,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Color(0xff333333),
                                    ),
                                    child: Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 5,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: Text(
                                      "1",
                                      style: _appFontStyle.getSmallButtonText(
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: _paddingBottom,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            : Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ));
  }
}
