import 'package:flutter/material.dart';
import 'package:munchly/logic/Routes.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Please sign in to your existing account',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMAIL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'example@gmail.com',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.VerificationPage);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'SEND CODE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
