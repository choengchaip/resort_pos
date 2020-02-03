import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:resort_pos/Pages/HomePage/AddPos.dart';
import 'package:resort_pos/Pages/POSMenu/MainPage.dart';
import 'package:resort_pos/Pages/POSMenu/ProfilePage.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:resort_pos/Services/POSService.dart';

class home_page extends StatefulWidget {
  @override
  _home_page createState() => _home_page();
}

class _home_page extends State<home_page> {
  LanguageServices _languageServices;
  Authentication _authentication;
  POSService _posService;
  AppFontStyle _appFontStyle;
  bool isLoaded;

  List<dynamic> posData;
  String configEmail;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoaded = false;
    _appFontStyle = new AppFontStyle();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context);
    _languageServices = Provider.of<LanguageServices>(context);
    _posService = Provider.of<POSService>(context);
    if (!isLoaded) {
      loadConfig().then((e){
        loadPosData();
      });
    }
  }

  Future loadPosData() async {
    http.Response res = await http.get(
        '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/pos/getpos.php?user_id=${_authentication.getId()}');
    List<dynamic> tmp = jsonDecode(res.body);
    print(tmp);
    setState(() {
      posData = tmp;
      print(posData);
      isLoaded = true;
    });
  }

  Future loadConfig()async{
    await _languageServices.loadDefaultLanguage();
    http.Response res = await http.get('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/pos/loademailconfig.php');
    setState(() {
      configEmail = res.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _paddingBottom = MediaQuery.of(context).padding.bottom;
    // TODO: implement build
    return Scaffold(
      body: isLoaded
          ? Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: _paddingTop,
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return profile_page();
                            }));
                          },
                          child: _authentication.getUserAvatar() != null
                              ? Container(
                                  height: 55,
                                  width: 55,
                                  margin: EdgeInsets.only(right: 15),
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              _authentication.getUserAvatar()),fit: BoxFit.cover)),
                                )
                              : Container(
                                  height: 55,
                                  width: 55,
                                  margin: EdgeInsets.only(right: 15),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset('assets/icons/user.png'),
                                ),
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              "${_authentication.getUserName()}",
                              style: _appFontStyle.getTopBarText(),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: Container(
                    child: ListView.builder(
                        itemCount: posData.length == 0 ? 0 : posData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: (){
                              print(posData);
                              if(posData[index][5] == '1'){
                                if(posData[index][6] == '1'){
                                  _posService.setPosId(posData[index][0]);
                                  _posService.setPosName(posData[index][1]);
                                  _posService.setPosIcon(posData[index][2]);
                                  _posService.setPosColor(posData[index][3]);
                                  _posService.setPermissionId(posData[index][4]);
                                  _posService.setRowNumber(2);
                                  _posService.setWidth(MediaQuery.of(context).size.width);
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                    return main_page();
                                  }));
                                }else{
                                  showDialog(context: context,builder: (BuildContext context){
                                    return AlertDialog(
                                      title: Text("ไม่สามารถเข้าใช้งานได้",style: _appFontStyle.getSmallButtonText(),),
                                      content: Text("กรุณาติดต่อ : ${configEmail}",style: _appFontStyle.getNormalText(),),
                                    );
                                  });
                                }
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 15),
                              padding: EdgeInsets.only(left: 15, right: 15),
                              height: 55,
                              decoration: BoxDecoration(
                                  color: Color(int.parse(posData[index][5]) == 2 ? 0xffffffff : int.parse(posData[index][3])),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: int.parse(posData[index][5]) == 2 ? Colors.black : Color.fromRGBO(0, 0, 0, 0.3),
                                        blurRadius: int.parse(posData[index][5]) == 2 ? 0 : 3)
                                  ]),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 15),
                                    child: Icon(IconData(int.parse(posData[index][2]),fontFamily: 'MaterialIcons'),color: int.parse(posData[index][5]) == 2 ? Colors.grey : Colors.white,),
                                  ),
                                  Container(
                                    child: Text(posData[index][1],
                                      style: _appFontStyle.getSmallButtonText(color: int.parse(posData[index][5]) == 2 ? Colors.grey : Colors.white),),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  )),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return addpos_page();
                      }));
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 15),
                      height: 55,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 3)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Icon(
                              Icons.add_circle,
                              color: Color(0xff565656),
                            ),
                          ),
                          Container(
                            child: Text(
                              '${_languageServices.getText('add')} Point of Sales [ POS ]',
                              style: _appFontStyle.getSmallButtonText(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _paddingBottom,
                  )
                ],
              ),
            )
          : Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
    );
  }
}
