import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Informations sur l'appareil.
class DeviceInfo {
  final String deviceType;
  final String deviceName;
  final String? model;
  final String? osVersion;
  final String? deviceId;

  const DeviceInfo({
    required this.deviceType,
    required this.deviceName,
    this.model,
    this.osVersion,
    this.deviceId,
  });
}

/// Service pour recuperer les informations de l'appareil.
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Recupere les informations completes de l'appareil.
  Future<DeviceInfo> getDeviceInfo() async {
    if (Platform.isAndroid) {
      return _getAndroidDeviceInfo();
    } else if (Platform.isIOS) {
      return _getIosDeviceInfo();
    }
    return const DeviceInfo(
      deviceType: 'browser',
      deviceName: 'Navigateur web',
    );
  }

  Future<DeviceInfo> _getAndroidDeviceInfo() async {
    final androidInfo = await _deviceInfo.androidInfo;

    // Determiner le type d'appareil par le modele (heuristic)
    final modelLower = androidInfo.model.toLowerCase();
    final isTablet =
        modelLower.contains('tablet') ||
        modelLower.contains('pad') ||
        androidInfo.brand.toLowerCase().contains('tablet');
    final deviceType = isTablet ? 'tablet_android' : 'smartphone_android';

    // Construire le nom de l'appareil
    final deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
    final model = androidInfo.model;
    final osVersion = 'Android ${androidInfo.version.release}';
    final deviceId = androidInfo.id;

    return DeviceInfo(
      deviceType: deviceType,
      deviceName: deviceName,
      model: model,
      osVersion: osVersion,
      deviceId: deviceId,
    );
  }

  Future<DeviceInfo> _getIosDeviceInfo() async {
    final iosInfo = await _deviceInfo.iosInfo;

    // Determiner le type d'appareil
    final isTablet = _isIpad(iosInfo.model);
    final deviceType = isTablet ? 'tablet_ios' : 'smartphone_ios';

    // Construire le nom de l'appareil
    final deviceName = iosInfo.name;
    final model = iosInfo.model;
    final osVersion = 'iOS ${iosInfo.systemVersion}';
    final deviceId = iosInfo.identifierForVendor;

    return DeviceInfo(
      deviceType: deviceType,
      deviceName: deviceName,
      model: model,
      osVersion: osVersion,
      deviceId: deviceId,
    );
  }

  bool _isIpad(String model) {
    return model.toLowerCase().contains('ipad');
  }
}
