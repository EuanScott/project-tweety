import 'package:flutter/material.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';

/// Holds the root and branch navigator keys used by the app router.
///
/// The root key is for routes that sit above the tab shell. Branch keys keep
/// each tab's nested navigation stack independent.
class AppNavigatorKeys {
  /// Creates navigator keys with debug labels for easier route inspection.
  AppNavigatorKeys()
    : root = GlobalKey<NavigatorState>(debugLabel: 'rootNavigator'),
      home = GlobalKey<NavigatorState>(debugLabel: 'homeNavigator'),
      cards = GlobalKey<NavigatorState>(debugLabel: 'cardsNavigator'),
      settings = GlobalKey<NavigatorState>(debugLabel: 'settingsNavigator');

  /// Navigator key for routes above the tab shell.
  final GlobalKey<NavigatorState> root;

  /// Navigator key for the home tab branch.
  final GlobalKey<NavigatorState> home;

  /// Navigator key for the cards tab branch.
  final GlobalKey<NavigatorState> cards;

  /// Navigator key for the settings tab branch.
  final GlobalKey<NavigatorState> settings;

  /// Returns the navigator key owned by [tab].
  GlobalKey<NavigatorState> branchKeyFor(AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return home;
      case AppTab.cards:
        return cards;
      case AppTab.settings:
        return settings;
    }
  }
}
