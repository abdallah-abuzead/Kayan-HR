import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

showSpinner(context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(tr('please_wait_dialog')),
        content: Container(
          height: 50,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}
