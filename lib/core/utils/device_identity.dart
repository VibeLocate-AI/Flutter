import 'package:uuid/uuid.dart';

import '../storage/token_storage.dart';

class DeviceIdentity {
  DeviceIdentity._();

  static const Uuid _uuid = Uuid();

  static Future<String> getDeviceUuid() async {
    final existing =
    await TokenStorage.getDeviceUuid();

    if (existing != null &&
        existing.isNotEmpty) {
      return existing;
    }

    final generated = _uuid.v4();

    await TokenStorage.saveDeviceUuid(
      generated,
    );

    return generated;
  }
}