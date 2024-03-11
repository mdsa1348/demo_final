import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BcashIndex extends StatelessWidget {
  final TextEditingController amountController = TextEditingController();

  Future<String> getToken() async {
    final baseUrl =
        "https://tokenized.sandbox.bka.sh/v1.2.0-beta/tokenized/checkout/";
    final app = "YOUR_APP_KEY";
    final appSecret = "YOUR_APP_SCREATE_KEY";
    final password = "YOUR_USER_PASSWORD";
    final username = "YOUR_USERNAME";

    final response = await http.post(
      Uri.parse("$baseUrl/token/grant"),
      headers: {
        "accept": "application/json",
        "content-type": "application/json",
      },
      body: jsonEncode({
        "app_key": app,
        "app_secret": appSecret,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id_token'];
    } else {
      throw Exception('Failed to get token');
    }
  }

  Future<String> createPayment(String token, String amount) async {
    final baseUrl =
        "https://tokenized.sandbox.bka.sh/v1.2.0-beta/tokenized/checkout/";
    final app = "YOUR_APP_KEY";

    final response = await http.post(
      Uri.parse("$baseUrl/create"),
      headers: {
        "Authorization": token,
        "X-APP-Key": app,
        "accept": "application/json",
        "content-type": "application/json",
      },
      body: jsonEncode({
        "mode": "0011",
        "callbackURL":
            'http://localhost/payment/execute.php?token=$token&app=$app&baseUrl=$baseUrl',
        "payerReference": "5432",
        "amount": amount,
        "currency": "BDT",
        "intent": "sale",
        "merchantInvoiceNumber":
            "Islamic_Edu_${DateTime.now().millisecondsSinceEpoch}",
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['bkashURL'];
    } else {
      throw Exception('Failed to create payment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bKash Payment'),
        backgroundColor: Colors.yellow,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount (BDT)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final token = await getToken();
                    final amount = amountController.text;
                    final paymentURL = await createPayment(token, amount);
                    // Open paymentURL in a WebView or launch a browser.
                  } catch (e) {
                    // Handle the exception here, e.g., show a SnackBar or a dialog.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Pay with bKash'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.yellow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
