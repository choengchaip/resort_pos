import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:resort_pos/Pages/SignUp/TermsPage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:resort_pos/Services/SQLiteService.dart';
import 'package:email_validator/email_validator.dart';

class signup_form extends StatefulWidget {
  _signup_form createState() => _signup_form();
}

class _signup_form extends State<signup_form> {
  Authentication _authentication;
  LanguageServices _languageServices;
  AppFontStyle _appFontStyle;
  SQLiteDatabase _sqLiteDatabase;

  final format = DateFormat("yyyy-MM-dd");

  // Field

  TextEditingController _firstname = TextEditingController();
  TextEditingController _lastname = TextEditingController();
  TextEditingController _telephone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  String _birthday;

  //

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sqLiteDatabase = new SQLiteDatabase();
    _appFontStyle = new AppFontStyle();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context, listen: false);
    _languageServices = Provider.of<LanguageServices>(context,listen: false);
  }

  Future uploadData() async {
    if(_firstname.text.isEmpty){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('name')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      return;
    }
    if(_lastname.text.isEmpty){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('lastName')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      return;
    }
    if(_telephone.text.isEmpty){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('mobileNo')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      return;
    }
    if(_email.text.isEmpty || !EmailValidator.validate(_email.text)){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('email')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      return;
    }
    if(_password.text.isEmpty){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('password')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      return;
    }
    if(_birthday == null){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("${_languageServices.getText('please')}${_languageServices.getText('enter')}${_languageServices.getText('dateOfBirth')}",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      return;
    }

    Map<String, double> currentLocation;
    currentLocation = _authentication.getCurrentPosition();
    Map<String, dynamic> userData = {
      'register_type': 'email',
      'firstname': _firstname.text,
      'lastname': _lastname.text,
      'telephone': _telephone.text,
      'email': _email.text,
      'password': _password.text,
      'birthday': _birthday,
      'latitude': currentLocation['latitude'].toString(),
      'longitude': currentLocation['longitude'].toString()
    };

    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/signup/createaccount.php',
    body: userData);
    if(res.body != '0'){
      String userId = res.body;
      _authentication.setUserId(userId);
      _authentication.setUserEmail(_email.text);
      _authentication.setUserName(_firstname.text);
      _authentication.setLoginStatus(true);
      await _sqLiteDatabase.initialDatabase(_authentication.getId(), 'email',
          password: _password.text);
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
        return terms_page();
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
      resizeToAvoidBottomPadding: false,
      body: Container(
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
                _languageServices.getText('singUp'),
                style: _appFontStyle.getTopBarText(),
              ),
            ),
            Expanded(
              child: Container(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 15,left: 5, right: 5),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: _width/8.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 2)
                          ]),
                      child: TextField(
                        controller: _firstname,
                        decoration: InputDecoration.collapsed(
                            hintText: _languageServices.getText('firstName')),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 15,left: 5, right: 5),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: _width/8.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 2)
                          ]),
                      child: TextField(
                        controller: _lastname,
                        decoration: InputDecoration.collapsed(
                            hintText: _languageServices.getText('lastName')),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 15,left: 5, right: 5),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: _width/8.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 2)
                          ]),
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        controller: _telephone,
                        decoration: InputDecoration.collapsed(
                            hintText: _languageServices.getText('mobileNo')),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 15,left: 5, right: 5),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: _width/8.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 2)
                          ]),
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _email,
                        decoration: InputDecoration.collapsed(
                            hintText: _languageServices.getText('email')),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 15,left: 5, right: 5),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: _width/8.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 2)
                          ]),
                      child: TextField(
                        controller: _password,
                        obscureText: true,
                        decoration: InputDecoration.collapsed(
                            hintText: _languageServices.getText('password')),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async{
                        DateTime tmp_date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
                        setState(() {
                          _birthday = format.format(tmp_date);
                        });
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 15,left: 5, right: 5),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: _width/8.5,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.3),
                                  blurRadius: 2)
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text(
                                  _birthday == null
                                      ? _languageServices.getText('dateOfBirth')
                                      : _birthday,
                                  style: _appFontStyle.getInputText()),
                            ),
                            Container(
                              child: Icon(
                                Icons.calendar_today,
                                color: Color(0xff565656),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                uploadData();
              },
              child: Container(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 15,left: 5, right: 5),
                  padding: EdgeInsets.only(left: 15, right: 15),
                  height: _width/8.5,
                  decoration: BoxDecoration(
                    color: Color(0xff0092C7),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Text(
                    _languageServices.getText('singUp'),
                    style:
                        _appFontStyle.getButtonText(color: Color(0xffffffff)),
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
