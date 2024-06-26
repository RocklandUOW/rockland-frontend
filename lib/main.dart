import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/screens/welcome.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/user_provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: CustomColor.mainBrown,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(ChangeNotifierProvider(
    create: (context) => UserProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final bool test1 = true; // check first time app opened.
  final bool test2 =
      false; // check auth token. if both false open welcome, else just the login.

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.mainBrown),
          useMaterial3: true,
          fontFamily: "Lato"),
      home: test1 ? const WelcomePage() : const HomeScreen(),
    );
  }
}
