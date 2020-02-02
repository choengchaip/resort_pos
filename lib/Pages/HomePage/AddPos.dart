import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Pages/HomePage/AddBusiness.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

class addpos_page extends StatefulWidget{
  _addpos_page createState() => _addpos_page();
}

class _addpos_page extends State<addpos_page>{
  AppFontStyle _appFontStyle;
  LanguageServices _languageServices;
  Color _posColor = Colors.redAccent;
  TextEditingController _posName = TextEditingController();

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
      resizeToAvoidBottomPadding: false,
      body: Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _paddingTop,
            ),
            Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 15),
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
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "POS",
                      style: _appFontStyle.getTopBarText(),
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
                  BorderRadius.all(Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                        blurRadius: 3)
                  ]),
              child: TextField(
                controller: _posName,
                style: _appFontStyle.getInputText(),
                decoration:
                InputDecoration.collapsed(
                  hintText:
                  _languageServices.getText('name'),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  child: CircleColorPicker(
                    initialColor: Colors.redAccent,
                    onChanged: (Color color){
                      setState(() {
                        _posColor = color;
                      });
                    },
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
                    onTap: ()async{
                      if(_posName.text.isEmpty){
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
                      Map<String, String> tmp = {};
                      tmp['name'] = _posName.text;
                      tmp['color'] = '0xff${_posColor.value.toRadixString(16)}';
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                        return addbusiness_page(tmp);
                      }));
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
      ),
    );
  }
}