import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/screen/home.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              auth.currentUser!.email.toString(),
              style: TextStyle(fontSize: 25),
            ),
            ElevatedButton(
                onPressed: () {
                  auth.signOut().then((value) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return HomeScreen();
                    }));
                  });
                },
                child: Text("ออกจากระบบ")),
          ],
        ),
      ),
    );
  }
}
