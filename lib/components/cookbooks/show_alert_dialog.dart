import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void showAlertDialog({
  required BuildContext context,
  required String title,
  String actionButtonText = '',
  required Function()? actionButtonOnPressed,
}) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        actions: [
          ElevatedButton(
            child: Text(tr('cancel_button')),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.all(10)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(),
          ElevatedButton(
            child: Text(actionButtonText == '' ? tr('delete_button') : actionButtonText),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.all(10)),
            onPressed: actionButtonOnPressed,
          ),
        ],
      );
    },
  );
}
