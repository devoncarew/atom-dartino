// Copyright (c) 2016, the Dartino project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library atom.dartino.sdk;

import 'dart:async';

import 'package:atom/atom.dart';
import 'package:atom_dartino/sdk/dartino_sdk.dart';
import 'package:atom_dartino/sdk/sod_sdk.dart';

import '../dartino.dart' show pluginId, openDartinoSettings;

/// Return the SDK associated with the given application.
/// If the SDK cannot be determined, notify the user and return `null`.
Future<Sdk> findSdk(String srcPath) async {
  //TODO(danrubel) read the .packages file to determine the associated SDK
  // and support both SDKs in the same workspace
  Sdk sdk;

  String dartinoPath = atom.config.getValue('$pluginId.dartinoPath');
  if (dartinoPath != null && dartinoPath.trim().isNotEmpty) {
    sdk = new DartinoSdk(dartinoPath);
  }

  String sodPath = atom.config.getValue('$pluginId.sodPath');
  if (sodPath != null && sodPath.trim().isNotEmpty) {
    sdk = new SodSdk(sodPath);
  }

  if (sdk == null) {
    atom.notifications.addError('No SOD or Dartino path specified.',
        detail: 'Please download SOD or Dartino and set the path in\n'
            'Settings > Packages > $pluginId > SOD root directory.\n'
            'See Dartino settings for more information.',
        dismissable: true,
        buttons: [
          new NotificationButton('Open settings', openDartinoSettings)
        ]);
    return null;
  }

  return await sdk.verifyInstall() ? sdk : null;
}

/// Common interface for all Dartino based SDKs.
abstract class Sdk {
  final String sdkRootPath;

  Sdk(this.sdkRootPath);

  /// Rebuild the binary to be deployed and return the path for that file.
  /// If there is a problem, notify the user and return `null`.
  Future<String> compile(String srcPath);

  /// Deploy the application at [dstPath] to the device on [deviceName],
  /// launch the application, and return `true`.
  /// If there is a problem, notify the user and return `false`.
  Future<bool> deployAndRun(String deviceName, String dstPath);

  /// Return `true` if the SDK is correctly installed and usable.
  /// If there is a problem, notify the user and automatically fix if possible.
  /// If the problem persists, return `false`.
  Future<bool> verifyInstall();
}