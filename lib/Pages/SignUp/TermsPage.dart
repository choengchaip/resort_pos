import 'package:flutter/material.dart';
import 'package:resort_pos/Pages/SignUp/AddProfile.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:provider/provider.dart';

class terms_page extends StatefulWidget {
  _terms_page createState() => _terms_page();
}

class _terms_page extends State<terms_page> {
  LanguageServices _languageServices;
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
    _languageServices = Provider.of<LanguageServices>(context);
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _paddingBottom = MediaQuery.of(context).padding.bottom;
    // TODO: implement build
    return Scaffold(
      body: Container(
        color: Color(0xffF4F4F4),
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
                _languageServices.getText('termsOfServiceAndPrivacyPolicy'),
                style: _appFontStyle.getTopBarText(),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 2)
                    ]),
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                  return add_profile();
                }));
              },
              child: Container(
                margin: EdgeInsets.only(top: 15),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.only(left: 15, right: 15),
                  height: 55,
                  decoration: BoxDecoration(
                    color: Color(0xff0092C7),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
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
      ),
    );
  }
}
