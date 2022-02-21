import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/model/profile.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'dart:async';
import 'package:flutter_login/screen/home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  late Profile profile = Profile();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Error"),
              ),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("สร้างบัญชีผู้ใช้"),
              ),
              // ignore: avoid_unnecessary_containers
              body: Container(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "อีเมล์",
                            style: TextStyle(fontSize: 20),
                          ),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: MultiValidator([
                              RequiredValidator(errorText: "กรุณากรอกอีเมล"),
                              EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง")
                            ]),
                            onSaved: (String? email) {
                              profile.email = email.toString();
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "รหัสผ่าน",
                            style: TextStyle(fontSize: 20),
                          ),
                          TextFormField(
                            obscureText: true,
                            validator: RequiredValidator(
                                errorText: "กรุณากรอกรหัสผ่าน"),
                            onSaved: (String? password) {
                              profile.password = password.toString();
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState?.save();
                                    // print("email = ${profile.email} password = ${profile.password}");
                                    try {
                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                              email: profile.email,
                                              password: profile.password)
                                          .then((value) {
                                        formKey.currentState?.reset();

                                        MotionToast.success(
                                          title: const Text("Success"),
                                          position:
                                              MOTION_TOAST_POSITION.bottom,
                                          description: const Text(
                                              "สร้างบัญชีผู้ใช้เรียบร้อยแล้ว"),
                                        ).show(context);

                                        Timer(const Duration(seconds: 1), () {
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return HomeScreen();
                                          }));
                                        });
                                      });
                                    } on FirebaseAuthException catch (e) {
                                      // print(e.code);
                                      // print(e.message);
                                      String message = "";
                                      if (e.code == "email-already-in-use") {
                                        message =
                                            "มีอีเมลนี้ในระบบแล้ว โปรดใช้อีเมลอื่น";
                                      } else if (e.code == "weak-password") {
                                        message =
                                            "รหัสผ่านต้องมีความยาว 6 ตัวอักษรขึ้นไป";
                                      } else {
                                        message = e.message.toString();
                                      }

                                      MotionToast.error(
                                        title: const Text("Error"),
                                        position: MOTION_TOAST_POSITION.bottom,
                                        description: Text(message),
                                      ).show(context);
                                    }
                                  }
                                },
                                child: const Text(
                                  "ลงทะเบียน",
                                  style: TextStyle(fontSize: 20),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        });
  }
}
