import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/LanguageService.dart';

class forget_page extends StatefulWidget{
  @override
  _forget_page createState() => _forget_page();
}

class _forget_page extends State<forget_page>{
  LanguageServices _languageServices;
  AppFontStyle _appFontStyle;

  bool isLoaded = true;
  Map<String, String> languageData;

  Future loadLanguageData() async {
    Map<String, String> tmp;
    if (await _languageServices.getLanguageStatus()) {
      tmp = await _languageServices.getLanguageData();
    } else {

    }
    setState(() {
      isLoaded = true;
      languageData = tmp;
    });
  }

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
//    loadLanguageData();
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
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
                _languageServices.getText('login'),
                style: _appFontStyle.getTopBarText(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              height: 120,
              width: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                        blurRadius: 2)
                  ]),
              child: Text("Logo"),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.centerLeft,
              height: 55,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                        blurRadius: 3)
                  ]),
              child: TextField(
                style: _appFontStyle.getInputText(),
                decoration: InputDecoration.collapsed(
//                    hintText: languageData == null ? 'Loading' : languageData['reEmail']),
                    hintText: _languageServices.getText('reEmail')),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.only(left: 15, right: 15),
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xff0092C7),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Text(
//                languageData == null ? 'Loading' : languageData['sendPassword'],
                _languageServices.getText('sendPassword'),
                style: _appFontStyle.getButtonText(
                    color: Color(0xffffffff)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}