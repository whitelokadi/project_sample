import 'dart:convert';
import 'dart:io';
import 'package:app_install_date/app_install_date_imp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:http/http.dart' as http;
import 'package:project_sample/login.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  late Future<void> _initializationFuture;
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  late String _deviceId;
  late String _deviceManufacturer;
  late String _deviceType;
  late String _deviceName;
  String? _releaseVersion;
  double? _latitude;
  double? _longitude;
  dynamic _ipAddressData;
  late PackageInfo _packageInfo;
  late String _appInstallDate;
  late String _address;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _initPackageInfo();
      await _initPlatformState();
      await _initPlatformStateNetworkIp();

      bool permissionGranted = await _checkPermission();
      if (permissionGranted) {
        await _getLocation();
        await _getInstallDate();
        await _saveDeviceData();
      }

      // Save values to shared preferences
      await _saveValues();
    } catch (e) {
      EasyLoading.showError('An error occurred: $e');
    }
  }

  Future<void> _initPackageInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      if (mounted) setState(() {});
    } catch (e) {
      if (kDebugMode) print('Error fetching package info: $e');
    }
  }

  Future<void> _initPlatformState() async {
    if (Platform.isAndroid) {
      try {
        var androidInfo = await _deviceInfoPlugin.androidInfo;
        if (mounted) {
          setState(() {
            _deviceId = androidInfo.id;
            _deviceManufacturer = androidInfo.manufacturer;
            _deviceType = androidInfo.brand;
            _deviceName = androidInfo.device;
            _releaseVersion = androidInfo.version.release;
          });
        }
      } catch (e) {
        if (kDebugMode) print('Error fetching device info: $e');
      }
    }
  }

  Future<void> _getInstallDate() async {
    try {
      final DateTime date = await AppInstallDate().installDate;
      if (mounted) {
        setState(() {
          _appInstallDate = date.toString();
        });
      }
    } catch (e, st) {
      debugPrint('Failed to load install date due to $e\n$st');
      if (mounted) {
        setState(() {
          _appInstallDate = 'Failed to load install date';
        });
      }
    }
  }

  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        EasyLoading.showError('Location permission denied!');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Geolocator.openAppSettings();
      EasyLoading.showError('Location permission denied forever!');
      return false;
    }

    return true;
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        if (mounted) {
          setState(() {
            _address =
                '${placemarks[0].name}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}';
            _latitude = position.latitude;
            _longitude = position.longitude;
          });
        }
      }
    } catch (e) {
      EasyLoading.showError('Error fetching location: $e');
    }
  }

  Future<void> _initPlatformStateNetworkIp() async {
    try {
      var ipAddress = IpAddress(type: RequestType.json);
      var ipAddressdata = await ipAddress.getIpAddress();
      _ipAddressData = ipAddressdata['ip'];
      if (kDebugMode) print('IP Address data: $_ipAddressData');
    } on IpAddressException catch (exception) {
      if (kDebugMode) print('IP Address error: ${exception.message}');
    }
  }

  Future<void> _saveDeviceData() async {
    try {
      var url = 'http://devapiv4.dealsdray.com/api/v2/user/device/add';
      var body = json.encode({
        "deviceType": "android",
        "deviceId": _deviceId,
        "deviceName": _deviceName,
        "deviceOSVersion": _releaseVersion,
        "deviceIPAddress": _ipAddressData,
        "lat": _latitude,
        "long": _longitude,
        "buyer_gcmid": "",
        "buyer_pemid": "",
        "app": {
          "version": _packageInfo.version,
          "installTimeStamp": _appInstallDate,
          "uninstallTimeStamp": "2022-02-10T12:33:30.696Z",
          "downloadTimeStamp": "2022-02-10T12:33:30.696Z"
        }
      });

      if (kDebugMode) print('Request body: $body');

      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (kDebugMode) {
        print('Response Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Stored Device Data Successfully');
      } else {
        EasyLoading.showError('Failed to Store Device Data');
      }
    } catch (e) {
      if (kDebugMode) print('Error saving device data: $e');
    }
  }

  Future<void> _saveValues() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('DeviceId', _deviceId);
    } catch (e) {
      if (kDebugMode) print('Error saving values: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a splash image while waiting
          return Scaffold(
            body: Center(
              child: Image.asset(
                  'lib/assets/MiLanuchscreen.jpg'), // Replace with your splash image
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('An error occurred: ${snapshot.error}')),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
