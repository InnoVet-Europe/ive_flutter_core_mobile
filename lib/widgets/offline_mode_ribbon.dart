import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class OfflineModeRibbon extends StatelessWidget {
  OfflineModeRibbon({@required this.showRibbon, @required this.lastSync, @required this.ribbonImage});

  final bool showRibbon;
  final DateTime lastSync;
  final String ribbonImage;

  @override
  Widget build(BuildContext context) {
    return showRibbon
        ? Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                if (lastSync != null) {
                  showAlert(context, 'Offline Mode', 'The data displayed in the Harrier Central app might be out of date. The last time the app connected to the server was ${DateFormat("E, MMM d \'at\' h:mm a").format(lastSync)}', 'OK');
                } else {
                  showAlert(context, 'Offline Mode', 'The data displayed in the Harrier Central app might be out of date. There is no record indicating when the last sync occurred.', 'OK');
                }
              },
              child: Image.asset(
                ribbonImage,
                //'images/icons/offline_mode.png',
                height: 120,
                width: 120,
              ),
            ),
          )
        : Container();
  }



static Future<bool> showAlert(BuildContext context, String title, String body, String buttonText, {bool showCancelButton = false, String cancelButtonText = 'Cancel'}) async {
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
                  textAlign: TextAlign.justify,
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
