import '../bari_context.dart';
import '../bari_models.dart';

abstract class BariProvider {
  Future<BariResponse?> tryRespond(String message, BariContext ctx, {bool forceOnline = false});
}






