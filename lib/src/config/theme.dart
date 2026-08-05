import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';

ThemeData getThemeData() {
  return new ThemeData(
    scaffoldBackgroundColor: whiteColor,
    primaryColor: appColorPrimary,
    primaryColorDark: appColorPrimary,
    hoverColor: Colors.grey,
    dividerColor: viewLineColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: appBarTheme(),
    cardTheme: CardThemeData(color: Colors.white),
    iconTheme: IconThemeData(color: textPrimaryColor),
    textTheme: textTheme(), colorScheme: colorScheme().copyWith(error: Colors.red),
    //inputDecorationTheme: inputDecorationTheme(),
  );
}

ColorScheme colorScheme() {
  return ColorScheme.light(
    primary: appColorPrimary,
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(color: textPrimaryColor),
    gapPadding: 10,
  );
  return InputDecorationTheme(
      // If  you are using latest version of flutter then lable text and hint text shown like this
      // if you r using flutter less then 1.20.* then maybe this is not working properly
      // if we are define our floatingLabelBehavior in our theme then it's not applayed
      // floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 17),
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      border: outlineInputBorder,
      labelStyle: TextStyle(color: textPrimaryColor));
}

TextTheme textTheme() {
  return TextTheme(
    labelLarge: TextStyle(color: appColorPrimary),
    titleLarge: TextStyle(color: textPrimaryColor),
    titleSmall: TextStyle(color: textSecondaryColor),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    backgroundColor: appLayout_background,
    iconTheme: IconThemeData(color: textPrimaryColor),
    elevation: 0, systemOverlayStyle: SystemUiOverlayStyle.dark, toolbarTextStyle: TextTheme(
      titleLarge: TextStyle(color: textPrimaryColor, fontSize: textSizeMedium),
    ).bodyMedium, titleTextStyle: TextTheme(
      titleLarge: TextStyle(color: textPrimaryColor, fontSize: textSizeMedium),
    ).titleLarge,
  );
}
