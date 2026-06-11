class BackgroundService {
  static final BackgroundService _instance = BackgroundService._();
  factory BackgroundService() => _instance;
  BackgroundService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  Future<void> startCallMonitoring() async {}

  Future<void> stopCallMonitoring() async {}

  Future<void> startSmsMonitoring() async {}

  Future<void> stopSmsMonitoring() async {}

  Future<void> registerPeriodicTasks() async {}

  bool get isInitialized => _initialized;
}