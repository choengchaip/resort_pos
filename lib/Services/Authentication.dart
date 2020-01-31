import 'package:flutter/cupertino.dart';

class Authentication extends ChangeNotifier{
  String userId;
  String userName;
  String userEmail;
  String userAvatar;
  String authType;
  double latitude;
  double longitude;
  bool isLogin;
  final PROTOCAL = 'http';
//  final IP = 'chengchai.000webhostapp.com';
//  final PORT = 80;

  final IP = 'localhost';
  final PORT = 8080;

  get GETPROTOCAL => this.PROTOCAL;
  get GETIP => this.IP;
  get GETPORT => this.PORT;

  String getId(){
    return this.userId;
  }

  String getUserName(){
    return this.userName;
  }

  String getUserEmail(){
    return this.userEmail;
  }

  String getUserAvatar(){
    return this.userAvatar;
  }

  Map<String,double> getCurrentPosition(){
    return{
      'latitude' : latitude,
      'longitude' : longitude
    };
  }

  String getAuthType(){
    return this.authType;
  }

  bool getLoginStatus(){
    return this.isLogin;
  }

  void setUserId(userId){
    this.userId = userId;
  }

  void setUserName(userName){
    this.userName = userName;
  }

  void setUserEmail(userEmail){
    this.userEmail = userEmail;
  }

  void setLoginStatus(isLogin){
    this.isLogin = isLogin;
  }

  void setUserAvatar(userAvatar){
    this.userAvatar = userAvatar;
  }

  void setCurrentPostion({latitude,longitude}){
    this.latitude = latitude;
    this.longitude = longitude;
  }
  void setAuthType(authType){
    this.authType = authType;
  }

}