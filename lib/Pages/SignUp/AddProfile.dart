import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Pages/HomePage/HomePage.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:resort_pos/Services/SQLiteService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class add_profile extends StatefulWidget {
  Map<String, dynamic> userData;
  add_profile(this.userData);
  _add_profile createState() => _add_profile(this.userData);
}

class _add_profile extends State<add_profile> {
  Map<String, dynamic> userData;
  _add_profile(this.userData);
  Authentication _authentication;
  LanguageServices _languageServices;
  SQLiteDatabase _sqLiteDatabase;
  AppFontStyle _appFontStyle;
  bool isLoaded;

  File _file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appFontStyle = new AppFontStyle();
    _sqLiteDatabase = SQLiteDatabase();
    isLoaded = true;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context);
    _languageServices = Provider.of<LanguageServices>(context);
  }

  Future getImageFromGallery()async{
    File tmp = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 256);
    setState(() {
      _file = tmp;
    });
  }

  Future uploadImageToServer()async{
    if(_file == null){
      if(_authentication.getUserAvatar() != null){
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
          return home_page();
        }));
      }
      _authentication.setUserAvatar(null);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
        return home_page();
      }));
      return;
    }

    String base64File = _file == null ? null : base64Encode(_file.readAsBytesSync());
    String imageName = 'imageprofile_${_authentication.getId()}';

    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/signup/uploadimage.php', body: {
      'image': base64File,
      'image_name': imageName,
      'user_id': _authentication.getId()
    });
    if(res.body == '1'){
      _authentication.setUserAvatar('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/Images/UserProfile/${imageName}.jpg');
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
        return home_page();
      }));
    }
  }

  Future uploadUserData()async{
    print(_authentication.getAuthType());
    if(_authentication.getAuthType() != 'email'){
      return;
    }
    setState(() {
      isLoaded = false;
    });
    http.Response res = await http.post(
        '${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/signup/createaccount.php',
        body: userData);
    if (res.body != '0') {
      String userId = res.body;
      _authentication.setUserId(userId);
      _authentication.setUserEmail(this.userData['email']);
      _authentication.setUserName(this.userData['firstname']);
      _authentication.setLoginStatus(true);
      await _sqLiteDatabase.initialDatabase(_authentication.getId(), 'email', password: this.userData['password']);
    }else{
      print(res.body);
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
        padding: EdgeInsets.only(left: 15, right: 15),
        color: Color(0xffF4F4F4),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _paddingTop,
            ),
            Container(
              height: 50,
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
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _file != null ? Container(
                              margin: EdgeInsets.only(bottom: 15),
                              height: 210,
                              width: 210,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  image: DecorationImage(image: FileImage(_file),alignment: Alignment.center,fit: BoxFit.cover)
                              ),
                            ): _authentication.getUserAvatar() == null ? Container(
                              margin: EdgeInsets.only(bottom: 15),
                              height: 210,
                              width: 210,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Image.asset('assets/icons/user.png'),
                            ):Container(
                              margin: EdgeInsets.only(bottom: 15),
                              height: 210,
                              width: 210,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  image: DecorationImage(image: NetworkImage(_authentication.getUserAvatar()),alignment: Alignment.center,fit: BoxFit.cover)
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          getImageFromGallery();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color(0xff0092C7),
                                  borderRadius: BorderRadius.all(Radius.circular(25))
                                ),
                                child: Text('${_languageServices.getText('add')}${_languageServices.getText('picture')}',
                                style: _appFontStyle.getLightText(color: Colors.white),),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                uploadUserData().then((a){
                  uploadImageToServer();
                }).catchError((a) {
                  setState(() {
                    isLoaded = true;
                  });
                  return;
                });
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