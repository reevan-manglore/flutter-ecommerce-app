import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../.api_key.dart' as keys;

import '../exceptions/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryTime;
  String? _userId;
  Timer? _scheduledTimeOut;
  static const _apiKey = keys.apiKey;

  bool get isAuthorized {
    return _token != null;
  }

  String get token {
    return _token ?? "";
  }

  String get userId {
    return _userId ?? "";
  }

  DateTime _convertSecondsToDateTime(String? secondsString) {
    Duration seconds = Duration(
      seconds: int.tryParse(secondsString ?? '0') ??
          0, //if in case there is mistake in string then return 0 seconds
    );
    return DateTime.now().add(seconds);
  }

  Duration _convertSecondsToDuartion(String? secondsString) {
    return Duration(
      seconds: int.tryParse(secondsString ?? '0') ??
          0, //if in case there is mistake in string then return 0 seconds
    );
  }

  Future<void> _saveAuthDataInPrefs(
      //prefs means preferances
      String token,
      String userId,
      DateTime expiryTime) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      "authData",
      json.encode(
        {
          'idToken': _token,
          'localId': _userId,
          'expiresIn': expiryTime.toIso8601String(),
        },
      ),
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey");

    final response = await http.post(
      url,
      body: json.encode(
        {
          "email": email,
          "password": password,
          "returnSecureToken": true,
        },
      ),
    );
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    if (responseData.containsKey('error')) {
      print("error occured");
      throw HttpException(responseData['error']['message']);
    }
    _token = responseData['idToken'];
    _expiryTime = _convertSecondsToDateTime(responseData['expiresIn']);
    Duration seconds = _convertSecondsToDuartion(responseData['expiresIn']);
    _scheduledTimeOut = Timer(seconds, () => logout());
    _userId = responseData['localId'];
    _saveAuthDataInPrefs(
      //once logged in save data in local storage of device
      _token ?? "",
      _userId ?? "",
      _expiryTime ?? DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey");
    final response = await http.post(
      url,
      body: json.encode(
        {
          "email": "$email",
          "password": "$password",
          "returnSecureToken": true,
        },
      ),
    );

    final responseData = json.decode(response.body);
    if (responseData.containsKey('error')) {
      print("error occured");
      throw HttpException(responseData['error']['message']);
    }
    _token = responseData['idToken'];
    _expiryTime = _convertSecondsToDateTime(responseData['expiresIn']);
    Duration seconds = _convertSecondsToDuartion(responseData['expiresIn']);
    _scheduledTimeOut = Timer(seconds, () => logout());
    _userId = responseData['localId'];
    _saveAuthDataInPrefs(
      _token ?? "",
      _userId ?? "",
      _expiryTime ?? DateTime.now(),
    );
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    print("try auto login called");
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("authData")) {
      return false;
    }

    final prefsData = json.decode(prefs.getString('authData') ?? "");
    DateTime expiryTime = DateTime.parse(prefsData['expiresIn'] ?? "0");

    if (expiryTime.isBefore(DateTime.now())) {
      //if expiry date is before current date then token expired
      return false;
    }

    _token = prefsData['idToken'];
    _userId = prefsData['localId'];
    _expiryTime = expiryTime;
    _scheduledTimeOut = Timer(
        _convertSecondsToDuartion(
          _expiryTime!.difference(DateTime.now()).inSeconds.toString(),
        ),
        logout);

    notifyListeners();
    return true;
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryTime = null;

    if (_scheduledTimeOut != null) {
      _scheduledTimeOut!.cancel();
      _scheduledTimeOut = null;
      print("timer destroyed");
    }
    SharedPreferences.getInstance()
        .then(
      (prefs) => prefs.clear(),
    )
        .catchError(
      (e) {
        print("an error occured while clearing preferances");
      },
    );
    print("logout called");
    notifyListeners();
  }
}
