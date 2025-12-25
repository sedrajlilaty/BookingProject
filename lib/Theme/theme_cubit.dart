import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(LightState());

  bool isDark = false;

  void changeTheme() {
    isDark = !isDark;
    emit(isDark ? DarkState() : LightState());
  }
}
