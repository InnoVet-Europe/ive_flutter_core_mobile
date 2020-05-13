import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:crypto/crypto.dart';

class CoreMoblieUtilities {
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










