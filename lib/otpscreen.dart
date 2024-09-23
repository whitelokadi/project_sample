/*
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Image.asset(
              'lib/assets/phone.jpeg',
              height: 70.0,
              width: double.infinity,
            ),
            Text(
              "OTP Verification",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            Text(
              "We have sent a unique OTP number to your mobile + 91 -9765232817 ",
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(width: 2),
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(width: 2),
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(width: 2),
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(width: 2),
                    ),
                  ),
                ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: Text("SEND AGAIN")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
*/

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
//import 'package:interviewtask/homescreen.dart';
//import 'package:interviewtask/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String phone = '';
  String verificationcode = '';
  String deviceid = '';
  var userId;

  @override
  void initState() {
    super.initState();
    getPhoneDetails();
  }

  Future<void> getPhoneDetails() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      phone = sharedPreferences.getString("PhoneNumber") ?? '';
      deviceid = sharedPreferences.getString("DeviceId") ?? '';
      userId = sharedPreferences.getString('UserId') ?? '';
    });
  }

  Future<void> verifyOtp(String otp) async {
    try {
      var url = 'http://devapiv4.dealsdray.com/api/v2/user/otp/verification';

      var body =
          json.encode({"otp": otp, "deviceId": deviceid, "userId": userId});

      if (kDebugMode) {
        print("Request body: $body");
      }

      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (kDebugMode) {
        print("Response Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }

      var responsedata = json.decode(response.body);
      if (kDebugMode) {
        print('Response data: $responsedata');
      }

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('OTP Verified Successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        EasyLoading.showError('Failed to Verify OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred: $e');
      }
      EasyLoading.showError('An error occurred while verifying OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'lib/assets/otpscreen.jpg',
              height: 70.0,
              width: double.infinity,
            ),
            const Text(
              "OTP Verification",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            Text(
              "We have sent a unique OTP number \n to your mobile +91-$phone",
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 20),
            OtpTextField(
              numberOfFields: 4,
              fillColor: Colors.black.withOpacity(0.1),
              filled: true,
              onSubmit: (String otp) {
                verificationcode = otp; // Store the OTP
                verifyOtp(
                    otp); // Call the verifyOtp method with the entered OTP
              },
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text("SEND AGAIN"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
