import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:restapiputdelet/bnowbar.dart';
import 'package:restapiputdelet/homepages.dart';
import 'package:restapiputdelet/pages/signin_page.dart';
import 'package:restapiputdelet/pages/signup_page.dart';
import 'package:restapiputdelet/pages/splash_page.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   
   await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('wishlistBox');
  runApp(Myapp());
}
class Myapp extends StatefulWidget {
  const Myapp({super.key});

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
 
  @override 


  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
      routes: {
        SplashPage.id:(context)=>const SplashPage(),
        SigninPage.id:(context)=>const SigninPage(),
        SignupPage.id:(context)=> const SignupPage(),
        Homepages.id:(context)=>const Homepages(),
        Bnowbar.id:(context)=>const Bnowbar(),
      },
    );
  }
}