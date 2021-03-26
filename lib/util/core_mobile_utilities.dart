import 'dart:async';
import 'package:flutter/material.dart';

class IveCoreMobileUtilities {
  static Future<bool?> showAlert(
      BuildContext context, String title, String body, String buttonText,
      {bool showCancelButton = false,
      String cancelButtonText = 'Cancel',
      TextAlign textAlign = TextAlign.justify}) async {
    return showDialog<bool?>(
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
                  style: const TextStyle(
                      fontFamily: 'AvenirNextRegular',
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0,
                      height: 1.0),
                )
              ],
            ),
          ),
          actions: <Widget>[
            if (showCancelButton)
              TextButton(
                child: Text(cancelButtonText),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            else
              Container(),
            TextButton(
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
