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
import 'package:google_sign_in/google_sign_in.dart';

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
    isCurrentUserLogin();
  }

  Future isCurrentUserLogin() async {
    var result = await _sqLiteDatabase.getCurrentUserId();
    if(result.length == 0){
      return;
    }
    Map<String, double> currentLocation;
    currentLocation = _authentication.getCurrentPosition();
    Map<String, dynamic> userData = {
      'login_type': result[0]['provider'],
      'autologin': 'auto',
      'password': result[0]['password'],
      'facebook_id': result[0]['providerid'],
      'userautoid': result[0]['userid'],
      'latitude': currentLocation['latitude'].toString(),
      'longitude': currentLocation['longitude'].toString()
    };
    http.Response res = await http.post(
        '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/login/login.php',
        body: userData);
    if (res.body != '0') {
      var resData = jsonDecode(res.body);
      _authentication.setUserId(resData[0]);
      _authentication.setUserName(resData[1]);
      _authentication.setUserEmail(resData[2]);
      _authentication.setUserAvatar(resData[3] == null ? null : resData[3].toString().substring(0,4) != 'http' ? '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/Images/UserProfile/${resData[3]}' : resData[3]);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return home_page();
      }));
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context, listen: false);
    _languageServices = Provider.of<LanguageServices>(context, listen: false);
    if (!isLoaded) {
      initLanguage().then((a) {
        setState(() {
          isLoaded = true;
        });
        initLocation().then((b) {
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

    try {
      currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {}
      currentLocation = null;
    }
    _authentication.setCurrentPostion(latitude: currentLocation.latitude, longitude: currentLocation.longitude);
  }

  Future login() async {
    setState(() {
      isLoaded = false;
    });
    if(_email.text.isEmpty){
      setState(() {
        isLoaded = true;
      });
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('email')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text(_languageServices.getText('confirm')),
            )
          ],
        );
      });
      return;
    }
    if(_password.text.isEmpty){
      setState(() {
        isLoaded = true;
      });
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('password')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text(_languageServices.getText('confirm')),
            )
          ],
        );
      });
      return;
    }
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
      _authentication.setUserAvatar(userData[3] == null ? null : '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/Images/UserProfile/${userData[3]}');
      await _sqLiteDatabase.initialDatabase(_authentication.getId(), 'email',
          password: _password.text);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return home_page();
      }));
    } else if (res.body == '0') {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                _languageServices.getText('nouser'),
                style: _appFontStyle.getTopBarText(),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(_languageServices.getText('confirm')))
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
    String facebookId = result.accessToken.userId;
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
      'facebook_id': facebookId,
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
        'facebook_id': facebookId,
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
        _authentication.setUserEmail(
          email.isEmpty ? '' : email,
        );
        _authentication.setUserName(fullName);
        _authentication.setLoginStatus(true);
        _authentication.setUserAvatar(avatar);
        await _sqLiteDatabase.initialDatabase(
            _authentication.getId(), 'facebook',
            providerid: facebookId);
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
      await _sqLiteDatabase.initialDatabase(_authentication.getId(), 'facebook',
          providerid: facebookId);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return home_page();
      }));
    }
  }

  Future loginWithGoogle()async{
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount _googleUser;
    try{
      _googleUser = await _googleSignIn.signIn();
    }catch(err){
      print(err);
    }
    print(_googleUser);
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
        body: isLoaded
            ? Container(
                color: Color(0xffF4F4F4),
                padding: EdgeInsets.only(left: 25, right: 15),
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
                                    margin: EdgeInsets.only(bottom: 20,top: 5),
                                    height: 100,
                                    width: 100,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.3),
                                              blurRadius: 2)
                                        ],
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/pos-logo.png'),
                                            fit: BoxFit.cover)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 15,left: 5,right: 5),
                              padding: EdgeInsets.only(left: 15, right: 15),
                              alignment: Alignment.centerLeft,
                              height: _width/8.5,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
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
                              margin: EdgeInsets.only(bottom: 15,left: 5,right: 5),
                              padding: EdgeInsets.only(left: 15, right: 15),
                              alignment: Alignment.centerLeft,
                              height: _width/8.5,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.3),
                                        blurRadius: 3)
                                  ]),
                              child: TextField(
                                controller: _password,
                                obscureText: true,
                                style: _appFontStyle.getInputText(),
                                decoration: InputDecoration.collapsed(
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
                                margin: EdgeInsets.only(bottom: 15,left: 5,right: 5),
                                padding: EdgeInsets.only(left: 15, right: 15),
                                height: _width/8.5,
                                decoration: BoxDecoration(
                                  color: Color(0xff0092C7),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
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
                              margin: EdgeInsets.only(bottom: 15,left: 5,right: 5),
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
                              margin: EdgeInsets.only(bottom: 15,left: 5,right: 5),
                              child: Text(
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
                                  margin: EdgeInsets.only(bottom: 5,left: 5,right: 5),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  height: _width/8.5,
                                  decoration: BoxDecoration(
                                    color: Color(0xffADADAD),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(top: 13, bottom: 13, right: 13),
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
                                  margin: EdgeInsets.only(bottom: 5,left: 5,right: 5),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  height: _width/8.5,
                                  decoration: BoxDecoration(
                                    color: Color(0xff0076A2),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(
                                              top: 13, bottom: 13, right: 13),
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
                            GestureDetector(
                              onTap: (){
                                loginWithGoogle();
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 5,left: 5,right: 5),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  height: _width/8.5,
                                  decoration: BoxDecoration(
                                    color: Color(0xffDD4B39),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(
                                              top: 13, bottom: 13, right: 13),
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
                            ),
                            Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(bottom: 5,left: 5,right: 5),
                                padding: EdgeInsets.only(left: 15, right: 15),
                                height: _width/8.5,
                                decoration: BoxDecoration(
                                  color: Color(0xff00A4E0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(
                                            top: 13, bottom: 13, right: 13),
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
