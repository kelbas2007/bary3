import '../../services/storage_service.dart';

enum BariMode {
  offline, // Offline Coach (default)
  online,  // Online Reference (Wikipedia, DuckDuckGo)
  hybrid,  // Hybrid (сначала офлайн, если не нашёл — онлайн)
  ai,      // AI Mode (OpenAI GPT или совместимый API)
}

class BariSettingsStore {
  BariMode mode = BariMode.offline;
  bool showSources = true;
  bool smallTalkEnabled = true;
  bool useSystemAssistant = true; // Использовать системный ассистент как fallback
  
  // AI Settings
  String? aiApiKey;
  String aiBaseUrl = 'https://api.openai.com/v1';
  String aiModel = 'gpt-4o-mini';

  Future<void> load() async {
    final modeStr = await StorageService.getBariMode();
    mode = BariMode.values.firstWhere(
      (m) => m.name == modeStr,
      orElse: () => BariMode.offline,
    );
    showSources = await StorageService.getBariShowSources();
    smallTalkEnabled = await StorageService.getBariSmallTalkEnabled();
    useSystemAssistant = await StorageService.getBariUseSystemAssistant();
    
    // Load AI settings
    aiApiKey = await StorageService.getAiApiKey();
    aiBaseUrl = await StorageService.getAiBaseUrl() ?? 'https://api.openai.com/v1';
    aiModel = await StorageService.getAiModel() ?? 'gpt-4o-mini';
  }

  Future<void> setMode(BariMode v) async {
    mode = v;
    await StorageService.setBariMode(v.name);
  }

  Future<void> setShowSources(bool v) async {
    showSources = v;
    await StorageService.setBariShowSources(v);
  }

  Future<void> setSmallTalkEnabled(bool v) async {
    smallTalkEnabled = v;
    await StorageService.setBariSmallTalkEnabled(v);
  }

  Future<void> setUseSystemAssistant(bool v) async {
    useSystemAssistant = v;
    await StorageService.setBariUseSystemAssistant(v);
  }

  Future<void> setAiApiKey(String? key) async {
    aiApiKey = key;
    await StorageService.setAiApiKey(key);
  }

  Future<void> setAiBaseUrl(String url) async {
    aiBaseUrl = url;
    await StorageService.setAiBaseUrl(url);
  }

  Future<void> setAiModel(String model) async {
    aiModel = model;
    await StorageService.setAiModel(model);
  }

  // Удобные геттеры для совместимости
  bool get onlineEnabled => mode == BariMode.online || mode == BariMode.hybrid;
  bool get manualOnly => mode == BariMode.hybrid; // В hybrid режиме онлайн только по запросу
  bool get aiEnabled => mode == BariMode.ai && aiApiKey != null && aiApiKey!.isNotEmpty;
}

