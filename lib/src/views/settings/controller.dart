import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mxd/src/models/cookie_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  SettingsController() {
    _loadSettings();
  }

  late ThemeMode _themeMode = ThemeMode.system;
  late double _titleFontSize = 16.0;
  late double _contentFontSize = 16.0;
  List<CookieCardModel> _cookies = [];

  ThemeMode get themeMode => _themeMode;
  double get titleFontSize => _titleFontSize;
  double get contentFontSize => _contentFontSize;
  List<CookieCardModel> get cookies => _cookies;

  CookieCardModel? _enabledCookie;

  CookieCardModel? get enabledCookie => _enabledCookie;

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> _loadSettings() async {
    final prefs = await _getPrefs();
    _themeMode = _loadThemeMode(prefs);
    _titleFontSize = _loadContentFontSize(prefs);
    _contentFontSize = _loadContentFontSize(prefs);
    _cookies = _loadCookies(prefs);
    notifyListeners();
  }

  double _loadTitleFontSize(SharedPreferences prefs) {
    double? titleFontSize = prefs.getDouble('titleFontSize');
    return titleFontSize ?? 16.0;
  }

  double _loadContentFontSize(SharedPreferences prefs) {
    double? contentFontSize = prefs.getDouble('contentFontSize');
    return contentFontSize ?? 16.0;
  }

  ThemeMode _loadThemeMode(SharedPreferences prefs) {
    String? theme = prefs.getString('themeMode');
    return ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$theme',
        orElse: () => ThemeMode.system);
  }

  List<CookieCardModel> _loadCookies(SharedPreferences prefs) {
    String? cookiesString = prefs.getString('cookies');
    if (cookiesString != null) {
      final List<CookieCardModel> cookies = List<String>.from(
              jsonDecode(cookiesString))
          .map((cookieData) => CookieCardModel.fromJson(jsonDecode(cookieData)))
          .toList();

      _enabledCookie = cookies.firstWhere(
        (cookie) => cookie.isEnabled,
        orElse: () => CookieCardModel.empty(),
      );

      if (_enabledCookie == null && cookies.isNotEmpty) {
        _enabledCookie = cookies.first;
        _enabledCookie!.isEnabled = true;
      }

      return cookies;
    }
    return [];
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newThemeMode.toString().split('.').last);

    notifyListeners();
  }

  Future<void> updateTitleFontSize(double newFontSize) async {
    if (newFontSize == _titleFontSize) return;

    _titleFontSize = newFontSize;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('titleFontSize', newFontSize);

    notifyListeners();
  }

  Future<void> updateContentFontSize(double newFontSize) async {
    if (newFontSize == _contentFontSize) return;

    _contentFontSize = newFontSize;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('contentFontSize', newFontSize);

    notifyListeners();
  }

  void setEnabledCookie(CookieCardModel cookie) {
    if (_enabledCookie != cookie) {
      _enabledCookie?.isEnabled = false;
      cookie.isEnabled = true;
      _enabledCookie = cookie;
      updateCookies();

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
