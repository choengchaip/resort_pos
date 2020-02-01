import 'package:flutter/material.dart';
import 'package:resort_pos/Pages/SignUp/AddProfile.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class terms_page extends StatefulWidget {
  _terms_page createState() => _terms_page();
}

class _terms_page extends State<terms_page> {
  Authentication _authentication;
  LanguageServices _languageServices;
  AppFontStyle _appFontStyle;
  bool isLoaded;

  String termsData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appFontStyle = new AppFontStyle();
    isLoaded = false;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context);
    _languageServices = Provider.of<LanguageServices>(context);
    if(!isLoaded){
      loadTermsData();
    }
  }

  Future loadTermsData()async{
    http.Response res = await http.get('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/signup/getterms.php');
    setState(() {
      termsData = res.body;
      isLoaded = true;
    });
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
              margin: EdgeInsets.only(bottom: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                _languageServices.getText('termsOfServiceAndPrivacyPolicy'),
                style: _appFontStyle.getTopBarText(),
              ),
            ),
            Expanded(
              child: Container(
                  margin: EdgeInsets.only(bottom: 15,left: 5, right: 5),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 2)
                    ]),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Container(
                      child: Text(termsData == null ? 'Loading' : termsData,style: _appFontStyle.getNormalText(),),
                    )
                  ],
                )
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                  return add_profile();
                }));
              },
              child: Container(
                margin: EdgeInsets.only(top: 15,left: 5, right: 5),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.only(left: 15, right: 15),
                  height: _width/8.5,
                  decoration: BoxDecoration(
                    color: Color(0xff0092C7),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Text(
                    _languageServices.getText('agree'),
                    style: _appFontStyle.getButtonText(color: Color(0xffffffff)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: _paddingBottom,
            )
          ],
        ),
      ):Container(alignment: Alignment.center,child: CircularProgressIndicator(),),
    );
  }
}
