import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

final TelegramClient telegramClient = TelegramClient(chatId: "-819945622", botToken: "5845476657:AAHxvgq5S-gvz3rWuIFeSYCVTTLW1_Wa6eQ");

class TelegramClient {
  final String chatId;
  final String botToken;

  TelegramClient({
    required this.chatId,
    required this.botToken,
  });

  String _limitMessage(final String message) =>
      message.substring(0, min(4096, message.length));

  Future<http.Response> sendMessage(final String message) {
    final Uri uri = Uri.https(
      "api.telegram.org",
      "/bot$botToken/sendMessage",
      {
        "chat_id": chatId,
        "text": _limitMessage(message),
        "parse_mode": "html",
      },
    );
    debugPrint("message : ${uri.toString()}");
    return http.get(uri);
  }
}