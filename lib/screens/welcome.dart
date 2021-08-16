import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayan_hr/screens/login.dart';
import 'package:kayan_hr/screens/sign_up.dart';

class Welcome extends StatefulWidget {
  static const String id = 'welcome';

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    animation = ColorTween(begin: Colors.teal, end: Colors.white).animate(controller);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              SizedBox(height: 20),
              Hero(
                tag: 'logo',
                child: Container(
                  child: Image.asset('images/logo_red.png'),
                  height: controller.value * 250,
                ),
              ),
              SizedBox(height: 60),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'K @ y @ N     H R',
                    textStyle: GoogleFonts.acme(
                      textStyle: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    speed: Duration(milliseconds: 300),
                    textAlign: TextAlign.center,
                  ),
                ],
                totalRepeatCount: 5,
                pause: Duration(milliseconds: 100),
              ),
              SizedBox(height: 60),
              ElevatedButton(
                child: Text(tr('login_title')),
                onPressed: () {
                  Navigator.pushNamed(context, Login.id);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(tr('sign_up_title')),
                onPressed: () {
                  Navigator.pushNamed(context, SignUp.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
