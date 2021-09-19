import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:kayan_hr/constants.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({Key? key}) : super(key: key);
  static const String id = 'no_internet';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('images/no_internet.jpg')),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No internet connection!!',
              style: TextStyle(color: kMainColor, fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Please check your wifi or mobile data.',
              style: TextStyle(color: kMainColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              child: Text('Try Again', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(primary: Colors.teal, padding: EdgeInsets.all(10)),
              onPressed: () async {
                showSpinner(context);
                await Future.delayed(Duration(seconds: 5), () {
                  Phoenix.rebirth(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
