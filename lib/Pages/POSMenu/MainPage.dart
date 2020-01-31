import 'package:flutter/material.dart';
import 'package:resort_pos/LoginPage.dart';
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
  List<String> _list;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentPage = 0;
    _appFontStyle = new AppFontStyle();
    _productView = ProductView.TwoRow;
    isLoaded = false;
    _sqLiteDatabase = new SQLiteDatabase();
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

  Future loadListData() async {
    _list = [
      'Pizza1',
      'Pizza2',
      'Pizza3',
      'Pizza4',
      'Pizza5',
      'Pizza6',
      'Pizza7',
      'Pizza8',
    ];
    setState(() {
      isLoaded = true;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      _list.insert(newIndex, _list.removeAt(oldIndex));
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
      onEntry().then((e) {
        loadListData();
        print(_posService.getPermissionId());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _paddingBottom = MediaQuery.of(context).padding.bottom;

    // TODO: implement build
    return Scaffold(
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
                                              style: _appFontStyle.getTopBarText(color: Colors.white),
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
                                        onTap: (){
                                          _sqLiteDatabase.clearCurrentUser().then((e){
                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
                                              return login_page();
                                            }));
                                          });
                                        },
                                        child: _authentication.getUserAvatar() != null
                                            ? Container(
                                          margin: EdgeInsets.only(left: 15),
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromRGBO(
                                                1, 1, 1, 0.4),
                                            image: DecorationImage(
                                              image: NetworkImage(_authentication.getUserAvatar(),),fit: BoxFit.cover
                                            ),
                                          ),
                                        )
                                            : Container(
                                          margin: EdgeInsets.only(left: 15),
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
                              padding: EdgeInsets.only(left: 15, right: 15),
                              height: 85,
                              color: Color(0xffe8e8e8),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 25),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(bottom: 2),
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              color: Color(0xff333333),
                                              shape: BoxShape.circle),
                                        ),
                                        Container(
                                          child: Text(
                                            "Food",
                                            style:
                                                _appFontStyle.getNormalText(),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 25),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(bottom: 2),
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              color: Color(0xff333333),
                                              shape: BoxShape.circle),
                                        ),
                                        Container(
                                          child: Text(
                                            "Cocktail",
                                            style:
                                                _appFontStyle.getNormalText(),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 25),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(bottom: 2),
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              color: Color(0xff333333),
                                              shape: BoxShape.circle),
                                        ),
                                        Container(
                                          child: Text(
                                            "Beverage",
                                            style:
                                                _appFontStyle.getNormalText(),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 25),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(bottom: 2),
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              color: Color(0xff333333),
                                              shape: BoxShape.circle),
                                        ),
                                        Container(
                                          child: Text(
                                            "Smoothies",
                                            style:
                                                _appFontStyle.getNormalText(),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              height: 50,
                              color: Colors.white,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 25),
                                    child: Text(
                                      "Pizza",
                                      style: _appFontStyle.getSmallButtonText(
                                          color: Color(int.parse(
                                              _posService.getPosColor()))),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 25),
                                    child: Text(
                                      "Pasta",
                                      style: _appFontStyle.getSmallButtonText(
                                          color: Color(0xff656565)),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 25),
                                    child: Text(
                                      "Burger",
                                      style: _appFontStyle.getSmallButtonText(
                                          color: Color(0xff656565)),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 25),
                                    child: Text(
                                      "Appetizers",
                                      style: _appFontStyle.getSmallButtonText(
                                          color: Color(0xff656565)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _posService.getPermissionId() == '1'
                                  ? ReorderableWrap(
                                      padding: EdgeInsets.only(top: 10),
                                      spacing: 10,
                                      runSpacing: 10,
                                      children:
                                          List.generate(_list.length, (index) {
                                        return Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                child: Stack(
                                                  children: <Widget>[
                                                    Container(
                                                      height: _posService.getWidth() / _posService.getRowNumber() - 45,
                                                      width: _posService.getWidth() / _posService.getRowNumber() - 15,
                                                      decoration: BoxDecoration(color: Color(int.parse(_posService.getPosColor())),
                                                          borderRadius: BorderRadius.all(Radius.circular(10))),
                                                    ),
                                                    Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: GestureDetector(
                                                          onTap: (){
                                                            setState(() {
                                                              _list.removeAt(index);
                                                            });
                                                          },
                                                          child: Container(
                                                            alignment: Alignment.center,
                                                            decoration: BoxDecoration(
                                                              color: Colors.redAccent,
                                                              shape: BoxShape.circle
                                                            ),
                                                            child: Icon(Icons.remove,color: Colors.white,),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  _list[index],
                                                  style: _appFontStyle
                                                      .getSmallButtonText(),
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  '100\$',
                                                  style: _appFontStyle
                                                      .getNormalText(
                                                          color: Color(
                                                              0xff656565)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      onReorder: _onReorder,
                                    )
                                  : Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: GridView.count(
                                        padding: EdgeInsets.only(left: 15, right: 15, top: 0),
                                        crossAxisCount:
                                            _posService.getRowNumber(),
                                        mainAxisSpacing: 15,
                                        crossAxisSpacing: 15,
                                        children: List.generate(_list.length,
                                            (index) {
                                          return Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Color(int.parse(
                                                            _posService
                                                                .getPosColor())),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    _list[index],
                                                    style: _appFontStyle
                                                        .getSmallButtonText(),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    '100\$',
                                                    style: _appFontStyle
                                                        .getNormalText(
                                                            color: Color(
                                                                0xff656565)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                            ),
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
                                          color: _currentPage == 0
                                              ? Color(int.parse(
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
