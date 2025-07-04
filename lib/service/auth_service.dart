  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:restapiputdelet/pages/signin_page.dart';

  class AuthService {
    static final FirebaseAuth _auth = FirebaseAuth.instance;

    static bool isLoggedIn() {
      final User? firebaseUser = _auth.currentUser;
      return firebaseUser != null;
    }

    static Future<User?> signInUser(String email, String password) async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _auth.currentUser;
    }

 static Future<User?> signUpUser(String fullname, String email, String password) async {
  try {
    var authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    User? user = authResult.user;

    await user?.updateDisplayName(fullname);
    await user?.reload();

    return _auth.currentUser;
  } on FirebaseAuthException catch (e) {
    debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
    throw e; // juda muhim — xatoni tashqariga chiqaramiz
  } catch (e) {
    debugPrint("Umumiy signup xatosi: $e");
    throw Exception("Ro‘yxatdan o‘tishda xatolik yuz berdi");
  }
}



    static void signOutUser(BuildContext context) {
      _auth.signOut();
      Navigator.pushReplacementNamed(context, SigninPage.id);
    }
  }
