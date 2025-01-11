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
  CookieCardModel? _enabledCookie;
  List<Map<String, dynamic>>? _forumData;

  ThemeMode get themeMode => _themeMode;
  double get titleFontSize => _titleFontSize;
  double get contentFontSize => _contentFontSize;
  List<CookieCardModel> get cookies => _cookies;
  CookieCardModel? get enabledCookie => _enabledCookie;
  List<Map<String, dynamic>>? get forumData => _forumData;

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> _loadSettings() async {
    final prefs = await _getPrefs();
    _themeMode = _loadThemeMode(prefs);
    _titleFontSize = _loadTitleFontSize(prefs);
    _contentFontSize = _loadContentFontSize(prefs);
    _cookies = _loadCookies(prefs);
    _forumData = _loadForumData(prefs);
    notifyListeners();
  }

  // 加载缓存的版面数据
  List<Map<String, dynamic>>? _loadForumData(SharedPreferences prefs) {
    String? forumDataString = prefs.getString('forumData');
    if (forumDataString != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(forumDataString));
    }
    return null;
  }

  // 加载标题字体大小
  double _loadTitleFontSize(SharedPreferences prefs) {
    double? titleFontSize = prefs.getDouble('titleFontSize');
    return titleFontSize ?? 16.0;
  }

  // 加载内容字体大小
  double _loadContentFontSize(SharedPreferences prefs) {
    double? contentFontSize = prefs.getDouble('contentFontSize');
    return contentFontSize ?? 16.0;
  }

  // 加载主题
  ThemeMode _loadThemeMode(SharedPreferences prefs) {
    String? theme = prefs.getString('themeMode');
    return ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$theme',
        orElse: () => ThemeMode.system);
  }

  // 加载保存的饼干
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

  // 更新主题
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    final prefs = await _getPrefs();
    await prefs.setString('themeMode', newThemeMode.toString().split('.').last);
    notifyListeners();
  }

  // 更新标题字体大小
  Future<void> updateTitleFontSize(double newFontSize) async {
    if (newFontSize == _titleFontSize) return;

    _titleFontSize = newFontSize;
    final prefs = await _getPrefs();
    await prefs.setDouble('titleFontSize', newFontSize);
    notifyListeners();
  }

  // 更新内容字体大小
  Future<void> updateContentFontSize(double newFontSize) async {
    if (newFontSize == _contentFontSize) return;

    _contentFontSize = newFontSize;
    final prefs = await _getPrefs();
    await prefs.setDouble('contentFontSize', newFontSize);
    notifyListeners();
  }

  // 设置启用的饼干
  void setEnabledCookie(CookieCardModel cookie) {
    if (_enabledCookie != cookie) {
      _enabledCookie?.isEnabled = false;
      cookie.isEnabled = true;
      _enabledCookie = cookie;
      updateCookies();

      notifyListeners();
    }
  }

  // 添加饼干
  Future<void> addCookie(String newCookie) async {
    if (!cookies.any((cookie) => cookie.name == newCookie)) {
      cookies.add(CookieCardModel.fromJson(jsonDecode(newCookie)));
      updateCookies();
      notifyListeners();
    }
  }

  // 移除饼干
  Future<void> removeCookie(String cookieName) async {
    cookies.removeWhere((cookie) => cookie.name == cookieName);
    updateCookies();
    notifyListeners();
  }

  // 更新饼干
  Future<void> updateCookies() async {
    final prefs = await _getPrefs();
    List<String> cookieStrings =
        cookies.map((cookie) => jsonEncode(cookie.toJson())).toList();
    await prefs.setString('cookies', jsonEncode(cookieStrings));
    notifyListeners();
  }

  // 更新版面数据
  Future<void> updateForumData(List<Map<String, dynamic>> newForumData) async {
    if (_forumData == newForumData) return;

    _forumData = newForumData;
    final prefs = await _getPrefs();
    await prefs.setString('forumData', jsonEncode(newForumData));
    notifyListeners();
  }
}
