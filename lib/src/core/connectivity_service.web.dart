// Copyright (c) 2020, the MarchDev Toolkit project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:rxdart/rxdart.dart';

import 'connectivity_service.interface.dart';

/// Discover network connectivity configurations: Distinguish between WI-FI
/// and cellular, check WI-FI status and more.
class ConnectivityService extends ConnectivityServiceInterface {
  /// Constructs a singleton instance of [ConnectivityService].
  ConnectivityService() : super() {
    void update(bool isConnected) {
      print(isConnected);

      if (connected.value != isConnected) {
        connected.add(isConnected);
      }

      final status = _connectivityStatus;
      if (connectivityChanged.value != status) {
        connectivityChanged.add(status);
      }
    }

    html.window.addEventListener('online', (_) => update(true));
    html.window.addEventListener('offline', (_) => update(false));
    _subscription = html.window.navigator.connection.onChange
        .listen((_) => update(html.window.navigator.onLine));
    update(html.window.navigator.onLine);
  }

  StreamSubscription _subscription;

  /// Gets [ConnectivityStatus] from `Window.Navigator.NetworkInformation.type`
  ConnectivityStatus get _connectivityStatus {
    if (!html.window.navigator.onLine) {
      return ConnectivityStatus.none;
    }

    ConnectivityStatus status;

    switch (html.window.navigator.connection.type) {
      case 'ethernet':
        status = ConnectivityStatus.ethernet;
        break;
      case 'cellular':
        status = ConnectivityStatus.mobile;
        break;
      case 'wifi':
        status = ConnectivityStatus.wifi;
        break;
      case 'none':
        status = ConnectivityStatus.none;
        break;

      default:
        status = ConnectivityStatus.unknown;
    }

    return status;
  }

  /// Fires whenever the connection state changes.
  ///
  /// Only shows whether the device is `REALLY` connected to the network or not.
  @override
  ValueStream<bool> get isConnected => connected;

  /// Fires whenever the connectivity state changes.
  ///
  /// Please note that it will not let you know about state of the `REAL` network connection.
  @override
  ValueStream<ConnectivityStatus> get onConnectivityChanged =>
      connectivityChanged;

  /// Checks the `REAL` connection status of the device.
  ///
  /// Instead listen for connection status changes via [isConnected] stream.
  Future<bool> checkConnection() async {
    final status = html.window.navigator.onLine;

    if (connected.value != status) {
      connected.add(status);
    }

    return status;
  }

  /// Checks the connection status of the device.
  ///
  /// Do not use the result of this function to decide whether you can reliably
  /// make a network request. It only gives you the radio status.
  ///
  /// Instead listen for connectivity changes via [onConnectivityChanged] stream.
  @override
  Future<ConnectivityStatus> checkConnectivity() async => _connectivityStatus;

  /// Obtains the wifi name (SSID) of the connected network.
  ///
  /// Please note that it DOESN'T WORK on emulators, Web, Windows and Linux (returns null).
  ///
  /// From android 8.0 onwards the GPS must be ON (high accuracy)
  /// in order to be able to obtain the SSID.
  @override
  Future<String> getWifiName() => null;

  /// Obtains the wifi BSSID of the connected network.
  ///
  /// Please note that it DOESN'T WORK on emulators, Web, Windows and Linux (returns null).
  ///
  /// From Android 8.0 onwards the GPS must be ON (high accuracy)
  /// in order to be able to obtain the BSSID.
  @override
  Future<String> getWifiBSSID() => null;

  /// Obtains the IP address of the connected wifi network.
  @override
  Future<String> getWifiIP() => null;

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}