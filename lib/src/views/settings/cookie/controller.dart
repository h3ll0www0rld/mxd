import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mxd/src/models/cookie_card.dart';
import 'package:mxd/src/views/settings/controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookiesController with ChangeNotifier {
  List<CookieCardModel> cookies = [];

  CookieCardModel? _enabledCookie;

  CookieCardModel? get enabledCookie => _enabledCookie;

  CookiesController(SettingsController settingsController) {
    _loadCookiesFromSettings(settingsController);
  }

  Future<void> _loadCookiesFromSettings(
      SettingsController settingsController) async {
    cookies = settingsController.cookies
        .map((cookieData) => CookieCardModel.fromJson(jsonDecode(cookieData)))
        .toList();

    notifyListeners();
  }

  void setEnabledCookie(CookieCardModel cookie) {
    if (_enabledCookie != cookie) {
      _enabledCookie?.isEnabled = false;

      cookie.isEnabled = true;
      _enabledCookie = cookie;
      notifyListeners();
    }
  }

  Future<void> addCookie(String newCookie) async {
    if (!cookies.any((cookie) => cookie.name == newCookie)) {
      cookies.add(CookieCardModel.fromJson(jsonDecode(newCookie)));
      updateCookies();
      notifyListeners();
    }
  }

  Future<void> removeCookie(String cookieName) async {
    cookies.removeWhere((cookie) => cookie.name == cookieName);
    updateCookies();
    notifyListeners();
  }

  Future<void> updateCookies() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cookieStrings =
        cookies.map((cookie) => jsonEncode(cookie.toJson())).toList();
    await prefs.setString('cookies', jsonEncode(cookieStrings));
    notifyListeners();
  }
}
