import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Pages/HomePage/HomePage.dart';
import 'package:resort_pos/Services/AppFontStyles.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:http/http.dart' as http;

class addicon_page extends StatefulWidget {
  Map<String, String> _posData;

  addicon_page(this._posData);

  _addicon_page createState() => _addicon_page(this._posData);
}

class _addicon_page extends State<addicon_page> {
  Map<String, String> _posData;
  _addicon_page(this._posData);

  AppFontStyle _appFontStyle;
  Authentication _authentication;
  LanguageServices _languageServices;
  bool isLoaded;

  int iconActive = 0;
  List<IconData> icons = [
    Icons.map,
    Icons.language,
    Icons.supervised_user_circle,
    Icons.card_travel,
    Icons.add_shopping_cart,
    Icons.local_library,
    Icons.receipt,
    Icons.recent_actors,
    Icons.lock,
    Icons.pause_circle_filled,
    Icons.camera_alt,
    Icons.restore_from_trash,
    Icons.fastfood,
    Icons.accessibility,
    Icons.remove_red_eye,
    Icons.favorite
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoaded = true;
    _appFontStyle = new AppFontStyle();
    _posData['icon'] = icons[0].codePoint.toString();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _authentication = Provider.of<Authentication>(context);
    _languageServices = Provider.of<LanguageServices>(context);
  }

  Future uploadPosData()async{
    setState(() {
      isLoaded = false;
    });

    Map<String,double> currentLocation = _authentication.getCurrentPosition();
    Map<String,String> dataToUpload = {
      'user_id': _authentication.getId(),
      'business_id': _posData['business_id'],
      'business_type_id': _posData['business_type_id'],
      'pos_name': _posData['name'],
      'icon': _posData['icon'],
      'color': _posData['color'],
      'language_id': _languageServices.getLanguageId(),
      'latitude': currentLocation['latitude'].toString(),
      'longitude': currentLocation['longitude'].toString()
    };
    http.Response res = await http.post('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/pos/addpos.php', body: dataToUpload);
    setState(() {
      isLoaded = true;
    });
    if(res.body == '1'){
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
        return home_page();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    double _paddingTop = MediaQuery.of(context).padding.top;
    double _paddingBottom = MediaQuery.of(context).padding.bottom;
    // TODO: implement build
    return Scaffold(
      body: isLoaded ? Container(
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
                "POS Icon",
                style: _appFontStyle.getTopBarText(),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 3)
                  ],
                ),
                child: GridView.count(
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  padding: EdgeInsets.zero,
                  crossAxisCount: 7,
                  children: List.generate(icons.length, (index) {
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          _posData['icon'] = icons[index].codePoint.toString();
                          iconActive = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: iconActive == index ? Color(0xffe5e5e5) : Colors.white,
                        ),
                        child: Icon(IconData(icons[index].codePoint, fontFamily: 'MaterialIcons'),color: Color(0xff333333),),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      margin: EdgeInsets.only(right: 25),
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Color(0xff707070),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            child: Text(
                              _languageServices.getText('back'),
                              style: _appFontStyle.getLightText(
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      uploadPosData();
//                      Navigator.push(context,
//                          MaterialPageRoute(builder: (BuildContext context) {
//                        return addicon_page(_posData);
//                      }));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Color(0xff0092C7),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Icon(
                              Icons.check_box,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            child: Text(
                              _languageServices.getText('confirm'),
                              style: _appFontStyle.getLightText(
                                  color: Colors.white),
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
