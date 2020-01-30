import 'dart:convert';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Pages/ForgetPassword/ForgetPassword.dart';
import 'package:resort_pos/Pages/HomePage/HomePage.dart';
import 'package:resort_pos/Pages/SignUp/LanguagePage.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:resort_pos/Services/SQLiteService.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class login_page extends StatefulWidget {
  @override
  _login_page createState() => _login_page();
}

class _login_page extends State<login_page> {
  bool isLoaded = false;
  Authentication _authentication;
  LanguageServices _languageServices;
  SQLiteDatabase _sqLiteDatabase;

  AppFontStyle _appFontStyle;
  Map<String, String> languageData;

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appFontStyle = new AppFontStyle();
    _sqLiteDatabase = new SQLiteDatabase();
    initLocation().then((a) {
      isCurrentUserLogin();
    });
  }

  Future isCurrentUserLogin() async {
    await _sqLiteDatabase.initialDatabase('12312');
    var result = await _sqLiteDatabase.getCurrentUserId();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context, listen: false);
    _languageServices = Provider.of<LanguageServices>(context, listen: false);
    if (!isLoaded) {
      initLanguage().then((a) {
        initLocation().then((b) {
          setState(() {
            isLoaded = true;
          });
        });
      });
    }
  }

  Future initLanguage() async {
    await _languageServices.loadDefaultLanguage();
  }

  Future initLocation() async {
    LocationData currentLocation;

    var location = new Location();

// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {}
      currentLocation = null;
    }
    _authentication.setCurrentPostion(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude);
  }

  Future login() async {
    setState(() {
      isLoaded = false;
    });
    Map<String, double> currentLocation;
    currentLocation = _authentication.getCurrentPosition();
    Map<String, dynamic> userData = {
      'login_type': 'email',
      'email': _email.text,
      'password': _password.text,
      'latitude': currentLocation['latitude'].toString(),
      'longitude': currentLocation['longitude'].toString()
    };
    http.Response res = await http.post(
        '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/login/login.php',
        body: userData);
    setState(() {
      isLoaded = true;
    });
    if (res.body != '0') {
      var userData = jsonDecode(res.body);
      _authentication.setUserId(userData[0]);
      _authentication.setUserName(userData[1]);
      _authentication.setUserEmail(userData[2]);
      _authentication.setUserAvatar(userData[3]);
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return home_page();
      }));
    } else if (res.body == '0') {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                "ไม่พบผู้ใช้",
                style: _appFontStyle.getTopBarText(),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("ตกลง"))
              ],
            );
          });
    }
  }

  Future loginWithFacebook() async {
    Map<String, double> currentLocation;
    currentLocation = _authentication.getCurrentPosition();

    FacebookLogin facebookLogin = FacebookLogin();
    FacebookLoginResult result =
        await facebookLogin.logIn(['email']).catchError((e) {
        print(e);
    });
    String userId = result.accessToken.userId;
    String token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture.width(512),email&access_token=${token}');
    final profile = json.decode(graphResponse.body);
    String fullName = profile['name'];
    String firstName = profile['first_name'];
    String lastName = profile['last_name'];
    String email = profile['email'];
    String avatar = profile['picture']['data']['url'];
    Map<String, dynamic> userData = {
      'login_type': 'facebook',
      'facebook_id': userId,
      'latitude': currentLocation['latitude'].toString(),
      'longitude': currentLocation['longitude'].toString()
    };
    http.Response res = await http.post(
        '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/login/login.php',
        body: userData);
    if (res.body == '0') {
      Map<String, dynamic> userData = {
        'register_type': 'facebook',
        'access_token': token,
        'firstname': firstName,
        'lastname': lastName,
        'provider': 'facebook',
        'facebook_id': userId,
        'email': email.isEmpty ? null : email,
        'latitude': currentLocation['latitude'].toString(),
        'longitude': currentLocation['longitude'].toString(),
        'avatar': avatar
      };

      http.Response res = await http.post(
          '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/signup/createaccount.php',
          body: userData);
      if (res.body != '0') {
        String userId = res.body;
        _authentication.setUserId(userId);
        _authentication.setUserEmail(email.isEmpty ? '' : email,);
        _authentication.setUserName(fullName);
        _authentication.setLoginStatus(true);
        _authentication.setUserAvatar(avatar);
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return language_page();
        }));
      }
    } else {
      var userData = jsonDecode(res.body);
      _authentication.setUserId(userData[0]);
      _authentication.setUserName(userData[1]);
      _authentication.setUserEmail(userData[2]);
      _authentication.setUserAvatar(userData[3]);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return home_page();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    // TODO: implement build
    return Scaffold(
        body: isLoaded
            ? Container(
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
                    Expanded(
                      child: Container(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    height: 120,
                                    width: 120,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 2)
                                      ],
                                      image: DecorationImage(image: AssetImage('assets/images/pos-logo.png'),fit: BoxFit.cover)
                                    ),
                                  ),
                                ],
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
                                      BorderRadius.all(Radius.circular(4)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.3),
                                        blurRadius: 3)
                                  ]),
                              child: TextField(
                                controller: _email,
                                style: _appFontStyle.getInputText(),
                                decoration: InputDecoration.collapsed(
                                  hintText:
                                      _languageServices.getText('username'),
                                ),
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
                                      BorderRadius.all(Radius.circular(4)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.3),
                                        blurRadius: 3)
                                  ]),
                              child: TextField(
                                controller: _password,
                                obscureText: true,
                                style: _appFontStyle.getInputText(),
                                decoration:
                                    InputDecoration.collapsed(
                                  hintText:
                                      _languageServices.getText('password'),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                login();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.only(left: 15, right: 15),
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Color(0xff0092C7),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                child: Text(
//                        languageData == null ? "Loading" : languageData['login'],
                                  _languageServices.getText('login'),
                                  style: _appFontStyle.getButtonText(
                                      color: Color(0xffffffff)),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (BuildContext context) {
                                        return forget_page();
                                      }));
                                    },
                                    child: Container(
                                      child: Text(
//                                languageData == null ? "Loading" : languageData['fogetYouPassword'],
                                        _languageServices
                                            .getText('fogetYouPassword'),
                                        style: _appFontStyle.getLightText(),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(bottom: 20),
                              child: Text(
//                        languageData == null ? "Loading" : languageData['singUp'],
                                _languageServices.getText('singUp'),
                                style: _appFontStyle.getLightText(),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _authentication.setAuthType('email');
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return language_page();
                                }));
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 15),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Color(0xffADADAD),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(
                                              top: 16, bottom: 16, right: 15),
                                          child: Image.asset(
                                              'assets/icons/mail.png'),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: Text(
                                            _languageServices.getText('email'),
                                            style: _appFontStyle
                                                .getSmallButtonText(
                                                    color: Color(0xffffffff)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            GestureDetector(
                              onTap: () {
                                _authentication.setAuthType('facebook');
                                loginWithFacebook();
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 15),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Color(0xff0076A2),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(
                                              top: 16, bottom: 16, right: 15),
                                          child: Image.asset(
                                              'assets/icons/facebook.png'),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: Text(
//                                  languageData == null ? "Loading" : languageData['facebook'],
                                            _languageServices
                                                .getText('facebook'),
                                            style: _appFontStyle
                                                .getSmallButtonText(
                                                    color: Color(0xffffffff)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.only(left: 15, right: 15),
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Color(0xffDD4B39),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(
                                            top: 16, bottom: 16, right: 15),
                                        child: Image.asset(
                                            'assets/icons/google.png'),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Text(
//                                  languageData == null ? "Loading" : languageData['google'],
                                          _languageServices.getText('google'),
                                          style:
                                              _appFontStyle.getSmallButtonText(
                                                  color: Color(0xffffffff)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.only(left: 15, right: 15),
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Color(0xff00A4E0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(
                                            top: 16, bottom: 16, right: 15),
                                        child: Image.asset(
                                            'assets/icons/twitter.png'),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Text(
//                                  languageData == null ? "Loading" : languageData['twitter'],
                                          _languageServices.getText('twitter'),
                                          style:
                                              _appFontStyle.getSmallButtonText(
                                                  color: Color(0xffffffff)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ));
  }
}
