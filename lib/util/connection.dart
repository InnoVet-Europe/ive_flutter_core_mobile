import 'dart:core';

import 'package:flutter/material.dart';

import 'package:ive_flutter_core_mobile/util/core_mobile_utilities.dart';

abstract class Enum<T> {
  const Enum(this._value);
  final T _value;
  T get value => _value;
}

class EnumConnectionStatus<int> extends Enum<int> {
  const EnumConnectionStatus(int val) : super(val);
}

const EnumConnectionStatus<int> connectionStatus_notConnected = EnumConnectionStatus<int>(0);
const EnumConnectionStatus<int> connectionStatus_connected = EnumConnectionStatus<int>(1);

EnumConnectionStatus<int> globalConnectionStatus;

class Connection {
  static Widget styleForConnected(Widget w, {num borderRadius = 0.0}) {
    return Container(
      foregroundDecoration: globalConnectionStatus == connectionStatus_connected
          ? const BoxDecoration()
          : BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Colors.grey,
              backgroundBlendMode: BlendMode.lighten,
            ),
      child: Container(
        foregroundDecoration: globalConnectionStatus == connectionStatus_connected
            ? const BoxDecoration()
            : const BoxDecoration(
                color: Colors.grey,
                backgroundBlendMode: BlendMode.saturation,
              ),
        child: w,
      ),
    );
  }

  static bool checkForConnection(BuildContext context, {String title, String message}) {
    if (globalConnectionStatus == connectionStatus_notConnected) {
      IveCoreMobileUtilities.showAlert(context, title ?? 'Offline mode', message ?? 'This feature is not available in offline mode. Please connect to the internet to use this feature', 'OK');
    }
    return globalConnectionStatus == connectionStatus_connected;
  }

  
}
