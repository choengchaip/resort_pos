import 'package:flutter/material.dart';
import 'package:resort_pos/Pages/SignUp/SignUpForm.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:provider/provider.dart';

class language_page extends StatefulWidget{
  _language_page createState() => _language_page();
}

enum Language{
  TH,EN,CH,SP,CH2,KR
}

class _language_page extends State<language_page>{
  LanguageServices _languageServices;
  AppFontStyle _appFontStyle;
  bool isLoaded;
  Map<String, String> languageData;
  Language _language = Language.TH;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoaded = true;
    _appFontStyle = new AppFontStyle();
  }

  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _languageServices = Provider.of<LanguageServices>(context,listen: false);
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

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _paddingBottom = MediaQuery.of(context).padding.bottom;

    // TODO: implement build
    return Scaffold(
      body: isLoaded ? Container(
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
//                languageData == null ? "Loading" : languageData['login'],
                _languageServices.getText('singUp'),
                style: _appFontStyle.getTopBarText(),
              ),
            ),
            Expanded(
              child: Container(
                child: ListView(
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _language = Language.TH;
                          loadLanguageData('1');
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 15),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: 55,
                        decoration: BoxDecoration(
                          color: _language == Language.TH ? Color(0xff0092C7) : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          "ไทย",
                          style: _appFontStyle.getButtonText(
                              color: _language == Language.TH ? Color(0xffffffff) : Color(0xff333333)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _language = Language.EN;
                          loadLanguageData('2');
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 15),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: 55,
                        decoration: BoxDecoration(
                          color: _language == Language.EN ? Color(0xff0092C7) : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          "English",
                          style: _appFontStyle.getButtonText(
                              color: _language == Language.EN ? Color(0xffffffff) : Color(0xff333333)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _language = Language.CH;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 15),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: 55,
                        decoration: BoxDecoration(
                          color: _language == Language.CH ? Color(0xff0092C7) : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          "中文语言",
                          style: _appFontStyle.getButtonText(
                              color: _language == Language.CH ? Color(0xffffffff) : Color(0xff333333)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _language = Language.SP;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 15),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: 55,
                        decoration: BoxDecoration(
                          color: _language == Language.SP ? Color(0xff0092C7) : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          "Idioma español",
                          style: _appFontStyle.getButtonText(
                              color: _language == Language.SP ? Color(0xffffffff) : Color(0xff333333)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _language = Language.CH2;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 15),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: 55,
                        decoration: BoxDecoration(
                          color: _language == Language.CH2 ? Color(0xff0092C7) : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          "日本語",
                          style: _appFontStyle.getButtonText(
                              color: _language == Language.CH2 ? Color(0xffffffff) : Color(0xff333333)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _language = Language.KR;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 15),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: 55,
                        decoration: BoxDecoration(
                          color: _language == Language.KR ? Color(0xff0092C7) : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          "한국어",
                          style: _appFontStyle.getButtonText(
                              color: _language == Language.KR ? Color(0xffffffff) : Color(0xff333333)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                    return signup_form();
                  }));
                });
              },
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