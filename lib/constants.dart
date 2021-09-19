import 'package:flutter/material.dart';

const kMainColor = Color(0xFFc41a3b);

const MaterialColor _buttonTextColor = MaterialColor(0xFFC41A3B, {
  50: kMainColor,
  100: kMainColor,
  200: kMainColor,
  300: kMainColor,
  400: kMainColor,
  500: kMainColor,
  600: kMainColor,
  700: kMainColor,
  800: kMainColor,
  900: kMainColor,
});

final kShowDatePickerTheme = ThemeData(
  // primaryColor: kMainColor,
  // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: kMainColor),
  primarySwatch: _buttonTextColor,
);

const kHeaderTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 15,
  color: kMainColor,
);

const kNumbersTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
  color: Colors.black,
);

const kTabsTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const kVacationLabelsTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 15,
);

final kUserDataTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 15,
  color: Colors.blueGrey.shade200,
);

const kVacationLabelsWidth = 85.0;
const kVacationRequestLabelsWidth = 120.0;
const kVacationLabelsPostfix = ':    ';

final kVacationDataTextStyle = TextStyle(
  fontSize: 15,
  color: Colors.grey.shade900,
);
