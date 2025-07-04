import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restapiputdelet/pages/signin_page.dart';
import 'package:restapiputdelet/service/auth_service.dart';

class SignupPage extends StatefulWidget {
  static final String id = "signup_page";
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  var fullnameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var conformpasswordController = TextEditingController();

 void _doSignUp() async {
  String fullname = fullnameController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text.trim();
  String cpassword = conformpasswordController.text.trim();

  if (fullname.isEmpty || email.isEmpty || password.isEmpty || cpassword.isEmpty) {
    _showError("Barcha maydonlarni to‘ldiring");
    return;
  }

  if (password != cpassword) {
    _showError("Parollar mos emas");
    return;
  }

  try {
    User? user = await AuthService.signUpUser(fullname, email, password);
    if (user != null) {
      responseSignUp(user);
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      _showError("Bu email allaqachon ro‘yxatdan o‘tgan");
    } else if (e.code == 'weak-password') {
      _showError("Parol juda kuchsiz (kamida 6ta belgi bo‘lishi kerak)");
    } else {
      _showError("Xatolik: ${e.message}");
    }
  } catch (e) {
    _showError("Ro‘yxatdan o‘tishda xatolik yuz berdi");
  }
}


  void responseSignUp(User user) {
    Navigator.pushReplacementNamed(context, SigninPage.id);
  }

  void _callSignIpPage() {
    Navigator.pushReplacementNamed(context, SigninPage.id);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 88, 207, 92),
              Color.fromARGB(255, 30, 112, 32),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField("Fullname", fullnameController),
                  _buildTextField("Email", emailController),
                  _buildTextField("Password", passwordController, isPassword: true),
                  _buildTextField("Confirm Password", conformpasswordController, isPassword: true),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _doSignUp,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: _callSignIpPage,
                        child: const Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}
