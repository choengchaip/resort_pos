import 'package:flutter/cupertino.dart';

class AppFontStyle{
  static const darkColor = Color(0xff333333);
//  static const lightColor = Color();

  TextStyle getTopBarText({color : darkColor}){
    return TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20);
  }

  TextStyle getInputText({color : darkColor}){
    return TextStyle(color: color,fontWeight: FontWeight.w300);
  }

  TextStyle getSmallButtonText({color: darkColor}){
    return TextStyle(color: color, fontSize: 15,fontWeight: FontWeight.bold);
  }

  TextStyle getButtonText({color : darkColor}){
    return TextStyle(color: color, fontSize: 20);
  }

  TextStyle getLightText({color: darkColor}){
    return TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w300);
  }
  TextStyle getNormalText({color: darkColor}){
    return TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.normal);
  }
}