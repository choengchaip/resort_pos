import 'package:flutter/material.dart';
import 'package:resort_pos/Pages/SignUp/SignUpForm.dart';
import 'package:resort_pos/Pages/SignUp/TermsPage.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class language_page extends StatefulWidget{
  _language_page createState() => _language_page();
}

class _language_page extends State<language_page>{
  Authentication _authentication;
  LanguageServices _languageServices;
  AppFontStyle _appFontStyle;
  bool isLoaded;
  Map<String, String> languageData;
  List<dynamic> languageList;
  String currentLanguage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoaded = false;
    _appFontStyle = new AppFontStyle();
    currentLanguage = '1';
  }

  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context);
    _languageServices = Provider.of<LanguageServices>(context,listen: false);
    if(!isLoaded){
      setState(() {
        currentLanguage = _languageServices.getLanguageId();
      });
      loadLanguageList();
    }
  }

  Future loadLanguageList()async{
    http.Response res = await http.get('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/languageservice/getlanguagelist.php');
    languageList = jsonDecode(res.body);
    setState(() {
      isLoaded = true;
    });
  }

  Future loadLanguageData(id)async{
    setState(() {
      isLoaded = false;
    });
    await _languageServices.initLanguage(id);
    await _languageServices.getLanguageData();
    setState(() {
      isLoaded = true;
    });
  }

  Future setConfigLanguage()async{
    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/languageservice/setlanguageconfig.php',body:{
      'language_id': currentLanguage
    });
    if(res.body == '1'){
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
        return _authentication.getAuthType() == 'email' ? signup_form() : terms_page(null);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _paddingBottom = MediaQuery.of(context).padding.bottom;
    double _width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
      body: isLoaded ? Container(
        color: Color(0xffF4F4F4),
        padding: EdgeInsets.only(left: 25, right: 25),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _paddingTop,
            ),
            Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      child: Icon(Icons.arrow_back_ios),
                      margin: EdgeInsets.only(right: 15),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _languageServices.getText('singUp'),
                      style: _appFontStyle.getTopBarText(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(padding: EdgeInsets.zero,itemCount: languageList == null ? 0 : languageList.length,itemBuilder: (BuildContext context, int index){
                  return GestureDetector(
                    onTap: (){
                      setState(() {
                        currentLanguage = languageList[index][0];
                        loadLanguageData(languageList[index][0]);
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 15,left: 5,right: 5),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: _width/8.5,
                      decoration: BoxDecoration(
                        color: currentLanguage == languageList[index][0] ? Color(0xff0092C7) : Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Text(
                        languageList[index][1],
                        style: _appFontStyle.getButtonText(
                            color: currentLanguage == languageList[index][0] ? Color(0xffffffff) : Color(0xff333333)),
                      ),
                    ),
                  );
                }),
              ),
            ),

            GestureDetector(
              onTap: (){
                setConfigLanguage();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 15,left: 5,right: 5),
                padding: EdgeInsets.only(left: 15, right: 15),
                height: _width/8.5,
                decoration: BoxDecoration(
                  color: Color(0xff0092C7),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: Text(
                  _languageServices.getText('confirm'),
                  style: _appFontStyle.getButtonText(color: Color(0xffffffff)),
                ),
              ),
            ),
            SizedBox(
              height: _paddingBottom,
            )
          ],
        ),
      ):Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
    );
  }
}