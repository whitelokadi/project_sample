import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'otpscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phonenumber = TextEditingController();
  String? deviceid;
  var userid;
  @override
  void initState() {
    getLoginDetails();
    super.initState();
  }

  getLoginDetails() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(
      () {
        deviceid = sharedPreferences.getString("DeviceId")!;
      },
    );
  }

  savePhoneNumberValues() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('PhoneNumber', _phonenumber.text);
    await sharedPreferences.setString('UserId', userid);
    if (!mounted) return;

    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const OtpScreen();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('lib/assets/Milogo.jpg'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const LoginScreen();
                        },
                      ),
                    );
                  },
                  child: const Text(
                    "Phone",
                    style: TextStyle(
                      fontSize: 23.0,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 23.0,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              "GLAD TO SEE YOU !",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23.0,
              ),
            ),
            const Text(
              "please provide your phone number",
              style: TextStyle(
                fontSize: 23.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _phonenumber,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextButton(
                onPressed: () {
                  saveUsers();
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return const OtpScreen();
                  // }));
                },
                child: const Text(
                  "SEND CODE",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  saveUsers() async {
    try {
      var url = 'http://devapiv4.dealsdray.com/api/v2/user/otp';

      var body = json.encode(
        {"mobileNumber": _phonenumber.text, "deviceId": deviceid},
      );
      if (kDebugMode) {
        print("request body:$body");
      }
      var response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'}, body: body);

      var responsedata = json.decode(response.body);
      userid = responsedata['data']['userId'];

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Otp Send Sucessfully');
        savePhoneNumberValues();
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return const OtpScreen();
        // }));
      } else {
        EasyLoading.showError('Failed to Send the OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred: $e');
      }
    }
  }
}
