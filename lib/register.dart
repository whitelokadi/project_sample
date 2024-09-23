import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:project_sample/login.dart';
/*import 'package:interviewtask/registerscreen.dart';
import 'package:interviewtask/otpscreen.dart';*/
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  var userID;
  @override
  void initState() {
    super.initState();
    getPhoneDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Image.asset('lib/assets/Milogo.jpg'),
      const Text(
        "Let's Begin!",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
      const Text(
        "please enter your credentials to proceed",
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: emailcontroller,
          decoration: const InputDecoration(
            labelText: 'Your Email',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: passwordcontroller,
          decoration: const InputDecoration(
              labelText: 'Create Password',
              suffixIcon: Icon(Icons.remove_red_eye)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Referral Code(Optional)',
          ),
        ),
      ),
      FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const LoginScreen();
            },
          ));
        },
        backgroundColor: Colors.red,
        splashColor: Colors.white,
        child: const Icon(Icons.arrow_right),
      )
    ]));
  }

  register() async {
    try {
      var url = 'http://devapiv4.dealsdray.com/api/v2/user/email/referral';

      var body = json.encode(
        {
          "email": emailcontroller.text,
          "password": passwordcontroller.text,
          "referralCode": 12345678,
          "userId": userID
        },
      );
      if (kDebugMode) {
        print("request body:$body");
      }
      var response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'}, body: body);
      if (kDebugMode) {
        print("Response Code ${response.statusCode}");
      }
      if (kDebugMode) {
        print("Response Body ${response.body}");
      }
      var responsedata = json.decode(response.body);
      if (kDebugMode) {
        print('Response data: $responsedata');
      }
      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Register Sucessfully');
        //savePhoneNumberValues();
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return const OtpScreen();
        // }));
      } else {
        EasyLoading.showError('Failed to Register');
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred: $e');
      }
    }
  }

  Future<void> getPhoneDetails() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userID = sharedPreferences.getString('UserId') ?? '';
    });
  }
}
