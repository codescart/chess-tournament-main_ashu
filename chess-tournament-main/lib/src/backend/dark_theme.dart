import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkThemePreference {
  static const themeStatus = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(themeStatus, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeStatus) ?? false;
  }
}

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = true;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }
}

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    Color baseGreen = const Color(0xff739749);
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = baseGreen.red, g = baseGreen.green, b = baseGreen.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    Color darkBG = const Color.fromARGB(255, 71, 66, 62);
    Color darkCard = const Color(0xff211F1E);

    Color lightBG = const Color(0xffF0F0F0);
    Color lightCard = const Color(0XFFE1E0E0);

    return ThemeData(
      primarySwatch: MaterialColor(baseGreen.value, swatch),
      primaryColor: isDarkTheme ? swatch[600] : swatch[500],
      backgroundColor: isDarkTheme ? darkBG : lightBG,
      scaffoldBackgroundColor: isDarkTheme ? darkBG : lightBG,
      // indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
      // buttonColor: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),

      hintColor: isDarkTheme ? Colors.grey : Colors.grey,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: isDarkTheme ? swatch[400] : swatch[500]),
      // highlightColor: isDarkTheme ? swatch[400] : swatch[400],
      // hoverColor: isDarkTheme ? Colors.black : swatch[700],
      // focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? darkCard : lightCard,
      // canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme
              ? const ColorScheme.dark()
              : const ColorScheme.light()),
      appBarTheme: AppBarTheme(
        color: isDarkTheme ? swatch[600] : swatch[500],
        elevation: 0.0,
      ),
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: isDarkTheme ? Colors.grey : Colors.black,
            displayColor: isDarkTheme ? Colors.grey : Colors.black,
          ),
    );
  }
}
