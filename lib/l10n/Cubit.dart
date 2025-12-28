import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- State --- //

class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState({this.locale = const Locale('en')});

  @override
  List<Object> get props => [locale];

  LanguageState copyWith({Locale? locale}) {
    return LanguageState(locale: locale ?? this.locale);
  }
}

// --- Cubit --- //

class LanguageCubit extends Cubit<LanguageState> {
  final SharedPreferences _prefs;
  static const String _languageKey = 'language_code';

  LanguageCubit(this._prefs) : super(const LanguageState()) {
    loadLanguage();
  }

  void loadLanguage() {
    final deviceLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    final code = _prefs.getString('language_code') ?? deviceLocale;
    // Default to 'en'
    emit(LanguageState(locale: Locale(code)));
  }

  void updateLanguage(Locale newLocale) {
    _prefs.setString(_languageKey, newLocale.languageCode);
    emit(state.copyWith(locale: newLocale));
  }
}
