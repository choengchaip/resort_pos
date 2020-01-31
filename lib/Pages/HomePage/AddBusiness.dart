import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Pages/HomePage/AddIcon.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:http/http.dart' as http;

class addbusiness_page extends StatefulWidget{
  Map<String,String> _posData;
  addbusiness_page(this._posData);
  _addbusiness_page createState() => _addbusiness_page(this._posData);
}

class _addbusiness_page extends State<addbusiness_page>{
  Map<String,String> _posData;
  _addbusiness_page(this._posData);

  AppFontStyle _appFontStyle;
  Authentication _authentication;
  LanguageServices _languageServices;
  Color _posColor = Colors.redAccent;
  TextEditingController _posName = TextEditingController();
  bool isLoaded;
  bool selectType;

  List<String> businessList;
  List<String> businessType = [];
  String currentBusiness;
  String currentBusinessType;
  Map<String,dynamic> businessData;
  Map<String,dynamic> businessTypeData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoaded = false;
    selectType = false;
    _appFontStyle = new AppFontStyle();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context);
    _languageServices = Provider.of<LanguageServices>(context);
    if(!isLoaded){
      loadBusinessData().then((e){
        loadBusinessTypeData();
      });
    }
  }

  Future loadBusinessData()async{
    List<String> _tmpList = [];
    Map<String,dynamic> _tmpMap = {};
    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/pos/getbusiness.php');
    List<dynamic> tmp = jsonDecode(res.body);
    for(int i=0;i<tmp.length;i+=2) {
      _tmpMap.addAll({tmp[i+1]: tmp[i]});
      _tmpList.add(tmp[i+1].toString());
    }

    setState(() {
      businessList = _tmpList;
      businessData = _tmpMap;
      currentBusiness = tmp[1];
      _posData['business_id'] = businessData[currentBusiness];
    });
  }

  Future loadBusinessTypeData()async{
    List<String> _tmpList = [];
    Map<String,dynamic> _tmpMap = {};
    String business_id = _posData['business_id'];
    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/pos/getbusinesstype.php?business_id=${business_id}');
    List<dynamic> tmp = jsonDecode(res.body);
    for(int i=0;i<tmp.length;i+=2) {
      _tmpMap.addAll({tmp[i+1]: tmp[i]});
      _tmpList.add(tmp[i+1].toString());
    }
    print(tmp);
    setState(() {
      businessType = _tmpList;
      businessTypeData = _tmpMap;
      currentBusinessType = tmp[1];
      _posData['business_type_id'] = businessTypeData[currentBusinessType];
      selectType = true;
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _paddingBottom = MediaQuery.of(context).padding.bottom;
    // TODO: implement build
    return Scaffold(
      body: isLoaded ? Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _paddingTop,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                _languageServices.getText('business'),
                style: _appFontStyle.getTopBarText(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                _languageServices.getText('business'),
                style: _appFontStyle.getLightText(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.centerLeft,
              height: 55,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.all(Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                        blurRadius: 3)
                  ]),
              child: DropdownButton<String>(
                value: currentBusiness,
                icon: Icon(Icons.arrow_drop_down),
                isExpanded: true,
                underline: Container(),
                onChanged: (String newValue) {
                  setState(() {
                    selectType = false;
                    currentBusiness = newValue;
                    loadBusinessTypeData();
                    _posData['business_id'] = businessData[currentBusiness];
                  });
                },
                items: businessList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: _appFontStyle.getLightText(),),
                  );
                }).toList(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                _languageServices.getText('businessType'),
                style: _appFontStyle.getLightText(),
              ),
            ),
            selectType ? Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.centerLeft,
              height: 55,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.all(Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                        blurRadius: 3)
                  ]),
              child: DropdownButton<String>(
                value: currentBusinessType,
                icon: Icon(Icons.arrow_drop_down),
                isExpanded: true,
                underline: Container(),
                onChanged: (String newValue) {
                  setState(() {
                    currentBusinessType = newValue;
                    _posData['business_type_id'] = businessTypeData[currentBusinessType];
                  });
                },
                items: businessType.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: _appFontStyle.getLightText(),),
                  );
                }).toList(),
              ),
            ):Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.centerLeft,
              height: 55,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.all(Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                        blurRadius: 3)
                  ]),
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      margin: EdgeInsets.only(right: 25),
                      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Color(0xff707070),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Icon(Icons.arrow_back,color: Colors.white,),
                          ),
                          Container(
                            child: Text(
                              _languageServices.getText('back'),
                              style: _appFontStyle.getLightText(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                        return addicon_page(_posData);
                      }));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Color(0xff0092C7),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Icon(Icons.check_box,color: Colors.white,),
                          ),
                          Container(
                            child: Text(
                              _languageServices.getText('confirm'),
                              style: _appFontStyle.getLightText(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: _paddingBottom,
            )
          ],
        ),
      ):Container(alignment: Alignment.center, child: CircularProgressIndicator(),),
    );
  }
}