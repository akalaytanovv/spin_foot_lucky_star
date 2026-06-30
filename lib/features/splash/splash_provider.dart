import 'package:flutter/foundation.dart';

import '../../services/audio_service.dart';

class SplashProvider extends ChangeNotifier {
  Future<void> preloadAudio() => AudioService.instance.preloadAssets();
}
