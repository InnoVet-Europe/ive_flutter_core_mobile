import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class CoreUtilities {
  static int logCounter = 0;

  static void logTiming(String item, DateTime startTime) {
    logCounter++;
    final Duration d = DateTime.now().difference(startTime);
    print((d.inMilliseconds / 1000.0).toString() + ' ($logCounter): ' + item);
  }

  static const int TIME_WINDOW = 30;
  
  static String generateToken(String userId, String procName, {String paramString = ''}) {
    final Duration difference = DateTime.now().toUtc().difference(DateTime.utc(1993, 7, 25, 15, 0, 0));
    //final int timeBlocks = (difference.inSeconds / 5760).toInt();
    final int timeBlocks = difference.inSeconds ~/ TIME_WINDOW;
    if (paramString.isNotEmpty) {
      paramString = '#' + paramString;
    }
    final String accessString = '${userId.toUpperCase()}#$procName#${timeBlocks.toString()}$paramString';
    final List<int> bytes = utf8.encode(accessString.toUpperCase()); // data being hashed
    final Digest digest = sha256.convert(bytes);
    return '$digest'.toUpperCase();
  }

  static String getFormattedMoney(num amount, num decimalPlaces, String currencySymbol) {
    String finalStr = '';
    if (amount != null) {
      String formatDecimals = '#####0.00';
      switch (decimalPlaces) {
        case 0:
          formatDecimals = '#####0';
          break;
        case 1:
          formatDecimals = '#####0.0';
          break;
        case 2:
          formatDecimals = '#####0.00';
          break;
        case 3:
          formatDecimals = '#####0.000';
          break;
        case 4:
          formatDecimals = '#####0.0000';
          break;
        default:
          formatDecimals = '#####0.00';
          break;
      }

      final String amountStr = NumberFormat(formatDecimals).format(amount);

      finalStr = currencySymbol.replaceAll('^', amountStr);
    }

    return finalStr;
  }

  static Widget elegantDivider(String text, num topPadding, num bottomPadding) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: <Color>[
                    Colors.white10,
                    Colors.white,
                  ],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 1.0),
                  stops: <double>[0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            width: 100.0,
            height: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: 'WorkSansMedium'),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: <Color>[
                    Colors.white,
                    Colors.white10,
                  ],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 1.0),
                  stops: <double>[0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            width: 100.0,
            height: 1.0,
          ),
        ],
      ),
    );
  }

  static void showInSnackBar(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
    String value, {
    int durationInSeconds = 5,
    num fontSize = 16.0,
    Color backgroundColor = Colors.blue,
  }) {
    FocusScope.of(context).requestFocus(FocusNode());
    scaffoldKey.currentState?.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: fontSize, fontFamily: 'WorkSansSemiBold'),
      ),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: durationInSeconds),
    ));
  }

  static num unInt(num n) {
    if (n == n.toInt()) {
      n += 0.00000001;
    }
    return n;
  }

  static Widget styleForDisabled(Widget w, {num borderRadius = 0.0}) {
    return Container(
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.grey,
        backgroundBlendMode: BlendMode.lighten,
      ),
      child: Container(
        foregroundDecoration: const BoxDecoration(
          color: Colors.grey,
          backgroundBlendMode: BlendMode.saturation,
        ),
        child: w,
      ),
    );
  }

  static Future<bool> showAlert(BuildContext context, String title, String body, String buttonText, {bool showCancelButton = false, String cancelButtonText = 'Cancel',TextAlign textAlign = TextAlign.justify}) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  body,
                  textAlign: textAlign,
                  style: const TextStyle(fontFamily: 'AvenirNextRegular', fontStyle: FontStyle.normal, fontSize: 16.0, height: 1.0),
                )
              ],
            ),
          ),
          actions: <Widget>[
            showCancelButton == true
                ? FlatButton(
                    child: Text(cancelButtonText),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  )
                : Container(),
            FlatButton(
              child: Text(buttonText),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}


SharedPreferences _sharedPreferences;

Future<void> initPrefs() async {
  _sharedPreferences ??= await SharedPreferences.getInstance();
}

Future<bool> clearPrefs() async {
  _sharedPreferences ??= await SharedPreferences.getInstance();
  return _sharedPreferences.clear();
}

// STRING

String getStringPref(dynamic key) {
  return _sharedPreferences.getString(key.toString());
}

Future<bool> setStringPref(dynamic key, String value) async {
  return _sharedPreferences.setString(key.toString(), value);
}

// NUM

num getNumPref(dynamic key) {
  return _sharedPreferences.getDouble(key.toString());
}

Future<bool> setNumPref(dynamic key, num value) async {
  return _sharedPreferences.setDouble(key.toString(), value);
}

// INT

num getIntPref(dynamic key) {
  return _sharedPreferences.getInt(key.toString());
}

Future<bool> setIntPref(dynamic key, int value) async {
  return _sharedPreferences.setInt(key.toString(), value);
}

// DATE

Future<bool> setDatePref(dynamic key, DateTime value) async {
  return _sharedPreferences.setInt(key.toString(), value.millisecondsSinceEpoch);
}

DateTime getDatePref(dynamic key) {
  final int ms = _sharedPreferences.getInt(key.toString());
  if (ms == null) 
  {
    return null;
  }
  return DateTime.fromMillisecondsSinceEpoch(ms);
}

// BOOL

Future<bool> setBoolPref(dynamic key, bool value) async {
  return _sharedPreferences.setInt(key.toString(), value == true ? 1 : 0);
}

bool getBoolPref(dynamic key) {
   return _sharedPreferences.getInt(key.toString()) == 1;
}










