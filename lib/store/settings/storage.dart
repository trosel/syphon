import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:syphon/global/libs/storage/secure-storage.dart';
import 'package:syphon/global/print.dart';
import 'package:syphon/storage/constants.dart';
import 'package:syphon/storage/database.dart';
import 'package:syphon/store/settings/state.dart';

///
/// Settings Queries - unencrypted (Cold Storage)
///
/// In storage, messages are indexed by eventId
/// In redux, they're indexed by RoomID and placed in a list
///
extension SettingsQueries on StorageDatabase {
  Future<int> insertSettingsStore(SettingsStore store) async {
    final storeJson = json.decode(json.encode(store));

    return into(settings).insertOnConflictUpdate(SettingsCompanion(
      id: Value(StorageKeys.SETTINGS),
      store: Value(storeJson),
    ));
  }

  Future<SettingsStore?> selectSettingStore() async {
    final row = await (select(settings)..where((tbl) => tbl.id.isNotNull())).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return SettingsStore.fromJson(row.store ?? {});
  }
}

Future<int> saveSettings(
  SettingsStore store, {
  required StorageDatabase storage,
}) async {
  return storage.insertSettingsStore(store);
}

///
/// Load Auth Store (Cold Storage)
///
Future<SettingsStore?> loadSettings({required StorageDatabase storage}) async {
  try {
    return storage.selectSettingStore();
  } catch (error) {
    printError(error.toString(), title: 'loadAuth');
    return null;
  }
}

const TERMS_OF_SERVICE_ACCEPTANCE_KEY = 'TERMS_OF_SERVICE_ACCEPTANCE_KEY';

final _storage = SecureStorage();

Future<dynamic> saveTermsAgreement({required int timestamp}) async {
  return _storage.write(key: TERMS_OF_SERVICE_ACCEPTANCE_KEY, value: json.encode(timestamp));
}

Future<int> loadTermsAgreement() async {
  return int.parse(await _storage.read(key: TERMS_OF_SERVICE_ACCEPTANCE_KEY) ?? '0');
}
