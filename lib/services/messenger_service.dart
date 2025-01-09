import 'package:share_plus/share_plus.dart';

class MessengerService {
  static Future<bool> shareToMessenger(String message) async {
    try {
      await Share.share(message);
      return true;
    } catch (e) {
      return false;
    }
  }
}