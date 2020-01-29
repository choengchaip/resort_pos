import 'package:flutter/material.dart';
import 'package:resort_pos/LoginPage.dart';
import 'package:provider/provider.dart';
import 'package:resort_pos/Services/Authentication.dart';
import 'package:resort_pos/Services/LanguageService.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Authentication>.value(value: Authentication()),
        ChangeNotifierProvider<LanguageServices>.value(value: LanguageServices()),
      ],
      child: MaterialApp(
        title: "Resort POS",
        home: login_page(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
