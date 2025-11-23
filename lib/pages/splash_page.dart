import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:restapiputdelet/homepages.dart';
import 'package:restapiputdelet/pages/signin_page.dart';
import 'package:restapiputdelet/service/auth_service.dart';

class SplashPage extends StatefulWidget {
  static final String id ="splash_page";
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void initState(){
  super.initState();
  _initTimer();
}

void _initTimer(){
  Timer (const Duration(seconds: 2),(){
  _callNextPage();
  });
}
_callNextPage(){
  if(AuthService.isLoggedIn()){
   Navigator.pushReplacementNamed(context, Homepages.id);
  }else{
 Navigator.pushReplacementNamed(context, SigninPage.id);
  }
  
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 88, 207, 92),
            const Color.fromARGB(255, 30, 112, 32),
          ]),

      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: Center(
            child:
            Text("MealMapp", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
          )),
          Text("All right reserved", style: TextStyle(color: Colors.white, fontSize: 16),),
          SizedBox(height: 20,)
        ],
      ),
      ),
    );
  }
}