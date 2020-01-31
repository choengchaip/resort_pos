import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:resort_pos/Services/Authentication.dart';

class LanguageServices extends ChangeNotifier{
  Authentication _authentication = new Authentication();
  final TH = {
    'NAME':'TH',
    'ID': '1'
  };
  final EN = {
    'NAME':'EN',
    'ID': '2'
  };
  final CH = {
    'NAME':'CH',
    'ID': '3'
  };
  String currentLanguage;
  Map<String, String> languageData = {};

  Future initLanguage(id)async{
    this.currentLanguage = id.toString();
    await getLanguageData();
  }

  Future<bool> getLanguageStatus()async{
    http.Response res = await http.get('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/languageservice/getstatuslanguage.php?language_id=${currentLanguage}');
    String response = res.body;
    if(response == '1'){
      return true;
    }
    return false;
  }

  Future<Map<String,String>> getLanguageData()async{
    http.Response res = await http.get('${_authentication.GETPROTOCAL}://${_authentication.GETIP}:${_authentication.GETPORT}/APIs/languageservice/loadlanguagedata.php?language_id=${currentLanguage}');
    List<dynamic> tmp = jsonDecode(res.body);
    this.languageData.clear();
    for(int i=0;i<tmp.length;i+=2){
      languageData[tmp[i]] = tmp[i+1];
    }
    return languageData;
  }
  String getText(key){
    return languageData[key];
  }

  Future loadDefaultLanguage()async{
    await initLanguage(1);
  }

  String getLanguageId(){
    return this.currentLanguage;
  }
}