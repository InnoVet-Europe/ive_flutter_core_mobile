import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ive_flutter_core_mobile/util/core_mobile_utilities.dart';

enum EnumConnectionStatus { connected, not_connected }

class Connection {
  static Future<bool> checkInternetConnection() async {
    bool connected = false;
    try {
      final List<InternetAddress> result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        connected = true;
      }
    } on SocketException catch (_) {
      print('not connected');
      connected = false;
    }
    return connected;
  }

  static Widget styleForConnected(EnumConnectionStatus status, Widget w, {num borderRadius = 0.0}) {
    return Container(
      foregroundDecoration: status == EnumConnectionStatus.connected
          ? const BoxDecoration()
          : BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Colors.grey,
              backgroundBlendMode: BlendMode.lighten,
            ),
      child: Container(
        foregroundDecoration: status == EnumConnectionStatus.connected
            ? const BoxDecoration()
            : const BoxDecoration(
                color: Colors.grey,
                backgroundBlendMode: BlendMode.saturation,
              ),
        child: w,
      ),
    );
  }

  static bool checkForConnection(BuildContext context, EnumConnectionStatus status, {String title, String message}) {
    if (status == EnumConnectionStatus.not_connected) {
      IveCoreMobileUtilities.showAlert(context, title ?? 'Offline mode', message ?? 'This feature is not available in offline mode. Please connect to the internet to use this feature', 'OK');
    }
    return status == EnumConnectionStatus.connected;
  }
}
