import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medstoker/Distributor/HomeScreenDistributer.dart';
import 'package:medstoker/util/constant.dart';
import 'package:medstoker/util/authService.dart';

import '../Screens/newProfile.dart';

class DistributerLoginScreen extends StatefulWidget {
  static String id = "distributer_login_screen";

  const DistributerLoginScreen({super.key});

  @override
  State<DistributerLoginScreen> createState() => _DistributerLoginScreenState();
}

class _DistributerLoginScreenState extends State<DistributerLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.7), BlendMode.dstATop),
            image: const NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ0i5RA4OLXdXHmwl7iJ_0H1qOdHI36Ng1_FQ&s'),
            fit: BoxFit.fill),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 65.0,
                        fontFamily: 'Anton',
                        letterSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
                const Center(
                  child: Text(
                    "Distributor Login",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20,),
                TextField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  decoration: kInputDecoration.copyWith(hintText: 'Email'),
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextField(
                  controller: _passwordController,
                  textAlign: TextAlign.center,
                  obscureText: true,
                  decoration: kInputDecoration.copyWith(hintText: 'Password'),
                ),
                SizedBox(
                  height: 15.0,
                ),
                RoundedButton(
                  buttonColor: Colors.white,
                  buttonFunction: () async {
                    final message = await AuthService().login(
                        email: _emailController.text,
                        password: _passwordController.text);
                    if (message!.contains("Success")) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>DistributerHomeScreen(),
                        ),
                      );
                    }
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                  },
                  buttonText: 'Login',
                ),
                RoundedButton(
                  buttonColor: Colors.white,
                  buttonFunction: () async {
                    final message = await AuthService().registration(
                        email: _emailController.text,
                        password: _passwordController.text);
                    if (message!.contains("Success")) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => DistributerHomeScreen(),
                        ),
                      );
                    }
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                  },
                  buttonText: 'Register',
                ),
                SizedBox(
                  height: 30.0,
                ),
                Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Or Login With",
                          style: TextStyle(color: Colors.white60),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                              onPressed: () {},
                              child: Text(
                                'Google',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              minWidth: 150.0,
                              color: Colors.white60,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {},
                              child: Text(
                                'Facebook',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              color: Colors.white60,
                              minWidth: 150.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {super.key,
      required this.buttonText,
      required this.buttonFunction,
      required this.buttonColor});

  final String buttonText;
  final Function buttonFunction;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: buttonColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: () {
            buttonFunction();
          },
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            buttonText,
          ),
        ),
      ),
    );
  }
}
