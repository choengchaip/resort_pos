import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Pages/HomePage/HomePage.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class add_profile extends StatefulWidget {
  _add_profile createState() => _add_profile();
}

class _add_profile extends State<add_profile> {
  Authentication _authentication;
  LanguageServices _languageServices;
  AppFontStyle _appFontStyle;
  bool isLoaded;

  File _file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appFontStyle = new AppFontStyle();
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
    File tmp = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _file = tmp;
    });
  }

  Future getImageFromCamera()async{
    File tmp = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _file = tmp;
    });
  }

  Future uploadImageToServer()async{
    setState(() {
      isLoaded = false;
    });
    if(_file == null){
      await showDialog(context: context,builder: (BuildContext context){
        return AlertDialog(
          title: Text("กรุณาเลือกรูป",style: _appFontStyle.getSmallButtonText(),),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();},child: Text("ตกลง"),)
          ],
        );
      });
      if(_authentication.getUserAvatar() != null){
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
          return home_page();
        }));
      }
      setState(() {
        isLoaded = true;
      });
      return;
    }

    String base64File = base64Encode(_file.readAsBytesSync());
    String imageName = 'imageprofile_${_authentication.getId()}';

    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/signup/uploadimage.php', body: {
      'image': base64File,
      'image_name': imageName,
      'user_id': _authentication.getId()
    });
    if(res.body == '1'){
      _authentication.setUserAvatar('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/Images/UserProfile/${imageName}.jpg');
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
        return home_page();
      }));
    }
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
                          child: Text('${_languageServices.getText('add')}${_languageServices.getText('picture')}',
                          style: _appFontStyle.getLightText(),),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      _authentication.setUserAvatar(null);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                        return home_page();
                      }));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      margin: EdgeInsets.only(right: 25),
                      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Color(0xff707070),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Icon(Icons.arrow_forward,color: Colors.white,),
                          ),
                          Container(
                            child: Text(
                              _languageServices.getText('skip'),
                              style: _appFontStyle.getLightText(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      uploadImageToServer();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Color(0xff0092C7),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Icon(Icons.check_box,color: Colors.white,),
                          ),
                          Container(
                            child: Text(
                              _languageServices.getText('confirm'),
                              style: _appFontStyle.getLightText(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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