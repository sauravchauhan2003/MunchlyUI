import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  Widget _buildCodeBox(int index) {
    return Container(
      width: 55,
      margin: EdgeInsets.symmetric(horizontal: 6),
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controllers.forEach((c) => c.dispose());
    focusNodes.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Verification',
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'We have sent a code to your email\nexample@gmail.com',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => _buildCodeBox(index),
                      ),
                    ),
                    SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: () {
                        // Verify action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'VERIFY',
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
