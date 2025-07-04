import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restapiputdelet/bnowbar.dart';
import 'package:restapiputdelet/pages/signup_page.dart';

import 'package:restapiputdelet/service/auth_service.dart';

class SigninPage extends StatefulWidget {
  static final String id="signin_page";
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  var emailController=TextEditingController();
  var passwordController=TextEditingController();

  void _callSignUpPage(){
 Navigator.pushReplacementNamed(context, SignupPage.id);
  }

  Future<void> _doSignIn() async {
  String email=emailController.text.toString().trim();
  String password=passwordController.text.toString().trim();
  if(email.isEmpty||password.isEmpty)return;
 

 AuthService.signInUser( email, password).then((value)=>{
  responseSignIn(value!),
 });
  }
  void responseSignIn(User firebaseUser){
    Navigator.pushReplacementNamed(context, Bnowbar.id);
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                 Container(
             height: 50,
             padding: EdgeInsets.only(left: 10, right: 10),
             decoration:BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(7),
             ),
             child: TextField(
              controller: emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Email",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 17
                )
              ),
             ),
             ), 

             Container(
              margin: EdgeInsets.only(top: 10),
             height: 50,
             padding: EdgeInsets.only(left: 10, right: 10),
             decoration:BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(7),
             ),
             child: TextField(
              controller: passwordController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Password",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 17
                )
              ),
             ),
             ), 


             GestureDetector(
              onTap: _doSignIn,
               child: Container(
                margin: EdgeInsets.only(top: 10),
               height: 50,
               padding: EdgeInsets.only(left: 10, right: 10),
               decoration:BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(7),
               ),
               child: Center(
                 child: Text("Sign In", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),)
               ),
               ),
             ), 
               Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Dont have an account?", style: TextStyle(color: Colors.white, fontSize: 16),),
                TextButton(onPressed:_callSignUpPage, 
                child: Text("Sign Up", style: TextStyle(color: Colors.white, fontSize:17, fontWeight: FontWeight.bold ),))
          ],),
            SizedBox(height: 20,)
          ],
                ),
        ),
      )
      ),
    );
  }
}