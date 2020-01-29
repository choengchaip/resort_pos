import 'package:flutter/material.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:provider/provider.dart';

class home_page extends StatefulWidget {
  @override
  _home_page createState() => _home_page();
}

class _home_page extends State<home_page> {
  LanguageServices _languageServices;
  Authentication _authentication;
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
    _authentication = Provider.of<Authentication>(context);
    _languageServices = Provider.of<LanguageServices>(context);
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _paddingBottom = MediaQuery.of(context).padding.bottom;
    // TODO: implement build
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _paddingTop,
            ),
            Container(
//              height: 55,
              child: Row(
                children: <Widget>[
                  Container(
                    height: 55,
                    width: 55,
                    margin: EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                        color: Colors.grey, shape: BoxShape.circle),
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
            Expanded(child: Container()),
            Container(
              height: 55,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 3)
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
                    child: Text('${_languageServices.getText('add')} Point of Sales [ POS ]',
                    style: _appFontStyle.getSmallButtonText(),),
                  )
                ],
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
