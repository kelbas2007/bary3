import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class CurrencyController extends ChangeNotifier {
  String _currencyCode = 'EUR';

  String get currencyCode => _currencyCode;

  Future<void> load() async {
    _currencyCode = await StorageService.getCurrencyCode();
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    if (code == _currencyCode) return;
    _currencyCode = code;
    await StorageService.setCurrencyCode(code);
    notifyListeners();
  }
}










