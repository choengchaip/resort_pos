import 'package:flutter/material.dart';
import 'package:resort_pos/LoginPage.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';
import 'package:resort_pos/Services/POSService.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((a){
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<Authentication>.value(value: Authentication()),
          ChangeNotifierProvider<LanguageServices>.value(value: LanguageServices()),
          ChangeNotifierProvider<POSService>.value(value: POSService())
        ],
        child: MaterialApp(
          title: "Resort POS",
          home: login_page(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  });
}
