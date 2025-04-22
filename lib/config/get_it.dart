import 'package:get_it/get_it.dart';
import 'package:toyvalley/config/soundpool_manager.dart';

import '../data/network/net_repository.dart';
import '../data/network/net_service.dart';

final getIt = GetIt.instance;

Future setup() async {
  getIt.registerSingleton<NetworkService>(NetworkService());
  getIt.registerSingleton<NetworkRepository>(NetworkRepository());

  final spm = SoundpoolManager();
  await spm.init();
  getIt.registerSingleton<SoundpoolManager>(
    spm,
    dispose: (instance) {
      instance.dispose();
    },
  );
}
