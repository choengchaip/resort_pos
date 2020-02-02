import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/LoginPage.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:resort_pos/Services/POSService.dart';
import 'package:resort_pos/Services/SQLiteService.dart';

class profile_page extends StatefulWidget{
  _profile_page createState() => _profile_page();
}

class _profile_page extends State<profile_page>{
  Authentication _authentication;
  LanguageServices _languageServices;
  AppFontStyle _appFontStyle;
  SQLiteDatabase _sqLiteDatabase;
  POSService _posService;
  bool isLoad;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appFontStyle = AppFontStyle();
    _sqLiteDatabase = SQLiteDatabase();
    isLoad = false;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context);
    _languageServices = Provider.of<LanguageServices>(context);
    _posService = Provider.of<POSService>(context);
    if(!isLoad){

    }
  }

  void logout(){
    _sqLiteDatabase.clearCurrentUser().then((e) {
      Navigator.popUntil(context, (route)=>route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
        return login_page();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _width = MediaQuery.of(context).size.width;

    // TODO: implement build
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: _paddingTop,
              color: Color(int.parse(_posService.getPosColor())),
            ),
            Container(
              height: 55,
              color: Color(int.parse(_posService.getPosColor())),
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Icon(Icons.arrow_back_ios,color: Colors.white,size: 17,),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 5),
                    child: Icon(Icons.settings,color: Colors.white,),
                  ),
                  Container(
                    child: Text("Setting",style: _appFontStyle.getTopBarText(color: Colors.white),),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView(
                  padding: EdgeInsets.only(top: 0,left: 15,right: 15),
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xffd5d5d5),width: 0.5))
                      ),
                      alignment: Alignment.centerLeft,
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Icon(Icons.account_circle,color: Color(0xff333333),),
                          ),
                          Container(
                            child: Text("Profile",style: _appFontStyle.getNormalText(),),
                          ),
                        ],
                      ),
                    ),
                    _posService.getPermissionId() == '1' || _posService.getPermissionId() == '2' ? GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop(true);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xffd5d5d5),width: 0.5))
                        ),
                        alignment: Alignment.centerLeft,
                        height: 60,
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(Icons.edit,color: Color(0xff333333),),
                            ),
                            Container(
                              child: Text("Management POS",style: _appFontStyle.getNormalText(),),
                            ),
                          ],
                        ),
                      ),
                    ):Container(),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xffd5d5d5),width: 0.5))
                      ),
                      alignment: Alignment.centerLeft,
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Icon(Icons.picture_as_pdf,color: Color(0xff333333),),
                          ),
                          Container(
                            child: Text("Report",style: _appFontStyle.getNormalText(),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xffd5d5d5),width: 0.5))
                      ),
                      alignment: Alignment.centerLeft,
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Icon(Icons.lock_open,color: Color(0xff333333),),
                          ),
                          Container(
                            child: Text("Permission",style: _appFontStyle.getNormalText(),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xffd5d5d5),width: 0.5))
                      ),
                      alignment: Alignment.centerLeft,
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Icon(Icons.bluetooth_connected,color: Color(0xff333333),),
                          ),
                          Container(
                            child: Text("Connect",style: _appFontStyle.getNormalText(),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xffd5d5d5),width: 0.5))
                      ),
                      alignment: Alignment.centerLeft,
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Icon(Icons.g_translate,color: Color(0xff333333),),
                          ),
                          Container(
                            child: Text("Language",style: _appFontStyle.getNormalText(),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xffd5d5d5),width: 0.5))
                      ),
                      alignment: Alignment.centerLeft,
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Icon(Icons.device_unknown,color: Color(0xff333333),),
                          ),
                          Container(
                            child: Text("Point of Sales [POS]",style: _appFontStyle.getNormalText(),),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xffd5d5d5),width: 0.5))
                      ),
                      alignment: Alignment.centerLeft,
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Icon(Icons.local_convenience_store,color: Color(0xff333333),),
                          ),
                          Container(
                            child: Text("About us",style: _appFontStyle.getNormalText(),),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        logout();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xffd5d5d5),width: 0.5))
                        ),
                        alignment: Alignment.centerLeft,
                        height: 60,
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(Icons.account_circle,color: Color(0xff333333),),
                            ),
                            Container(
                              child: Text("Logout",style: _appFontStyle.getNormalText(),),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}