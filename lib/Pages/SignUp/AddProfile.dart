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
      if(_authentication.getUserAvatar() != null){
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
          return home_page();
        }));
      }
      return;
    }

    String base64File = base64Encode(_file.readAsBytesSync());
    String imageName = 'imageprofile_${_authentication.getId()}';

    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/signup/uploadimage.php', body: {
      'image': base64File,
      'image_name': imageName
    });
    if(res.body == '1'){
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
    double _paddingBottom = MediaQuery.of(context).padding.bottom;
    // TODO: implement build
    return Scaffold(
      body: isLoaded ? Container(
        color: Color(0xffF4F4F4),
        child: Column(
          children: <Widget>[
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 100,
                    margin: EdgeInsets.only(right: 25),
                    padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      color: Color(0xff707070),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                        borderRadius: BorderRadius.all(Radius.circular(10)),
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