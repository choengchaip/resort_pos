import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:resort_pos/Services/POSService.dart';

class menu_page extends StatefulWidget{
  int rowNum;
  menu_page(this.rowNum);
  _menu_page createState() => _menu_page(this.rowNum);
}

class _menu_page extends State<menu_page>{
  int rowNum;
  _menu_page(this.rowNum);

  Authentication _authentication;
  LanguageServices _languageServices;
  POSService _posService;
  AppFontStyle _appFontStyle;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appFontStyle = new AppFontStyle();
  }


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _posService = Provider.of<POSService>(context);
    print('b');
  }

  void refresh(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 2),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Color(0xff333333),
                          shape: BoxShape.circle
                        ),
                      ),
                      Container(
                        child: Text("Food",style: _appFontStyle.getNormalText(),),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 2),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Color(0xff333333),
                            shape: BoxShape.circle
                        ),
                      ),
                      Container(
                        child: Text("Cocktail",style: _appFontStyle.getNormalText(),),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 2),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Color(0xff333333),
                            shape: BoxShape.circle
                        ),
                      ),
                      Container(
                        child: Text("Beverage",style: _appFontStyle.getNormalText(),),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 2),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Color(0xff333333),
                            shape: BoxShape.circle
                        ),
                      ),
                      Container(
                        child: Text("Smoothies",style: _appFontStyle.getNormalText(),),
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
                  child: Text("Pizza",style: _appFontStyle.getSmallButtonText(color: Color(int.parse(_posService.getPosColor()))),),
                ),
                Container(
                  margin: EdgeInsets.only(right: 25),
                  child: Text("Pasta",style: _appFontStyle.getSmallButtonText(color: Color(0xff656565)),),
                ),
                Container(
                  margin: EdgeInsets.only(right: 25),
                  child: Text("Burger",style: _appFontStyle.getSmallButtonText(color: Color(0xff656565)),),
                ),
                Container(
                  margin: EdgeInsets.only(right: 25),
                  child: Text("Appetizers",style: _appFontStyle.getSmallButtonText(color: Color(0xff656565)),),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
//              padding: EdgeInsets.only(left: 15, right: 15,top: 15),
//              child: GridView.count(
//                padding: EdgeInsets.zero,
//                crossAxisCount: this.rowNum,
//                mainAxisSpacing: 15,
//                crossAxisSpacing: 15,
//                children: List.generate(5, (index){
//                  return Container(
//                    color: Colors.red,
//                  );
//                }),
//              )
              child: Text(rowNum.toString()),
            ),
          ),
        ],
      ),
    );
  }
}