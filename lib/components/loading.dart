import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

Widget loading([String loadingMessage = '']) {
  return Center(
    child: Text(
      loadingMessage == '' ? tr('loading') : loadingMessage,
      style: TextStyle(fontSize: 16),
    ),
  );
}
