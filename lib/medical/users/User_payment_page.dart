import 'package:demo/payment/Bcash/BcashIndex.dart';
import 'package:flutter/material.dart';

class PaymentSystem {
  final String name;
  final String imagePath;

  PaymentSystem({required this.name, required this.imagePath});
}

class PaymentConfirmationPage extends StatelessWidget {
  final PaymentSystem selectedPaymentSystem;
  final double price;

  PaymentConfirmationPage(
      {required this.selectedPaymentSystem, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Selected Payment System: ${selectedPaymentSystem.name}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Total Price: \$${price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Add any confirmation logic here
                // For example, you might want to proceed with payment processing
                _showPaymentSuccessDialog(context);
              },
              child: Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show payment success dialog
  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Successful'),
          content: Text('Thank you for your payment!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog
                Navigator.of(context).pop(); // Close the confirmation page
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class UserPaymentPage extends StatefulWidget {
  final double price;

  UserPaymentPage({required this.price});

  @override
  _UserPaymentPageState createState() => _UserPaymentPageState();
}

class _UserPaymentPageState extends State<UserPaymentPage> {
  List<PaymentSystem> paymentSystems = [
    PaymentSystem(name: 'bKash', imagePath: 'assets/OIP.jpeg'),
    PaymentSystem(name: 'Nagad', imagePath: 'assets/OIP.jpeg'),
    PaymentSystem(name: 'UPay', imagePath: 'assets/OIP.jpeg'),
    PaymentSystem(name: 'GPay', imagePath: 'assets/OIP.jpeg'),
    PaymentSystem(name: 'bKash', imagePath: 'assets/OIP.jpeg'),
    PaymentSystem(name: 'Nagad', imagePath: 'assets/OIP.jpeg'),
    PaymentSystem(name: 'UPay', imagePath: 'assets/OIP.jpeg'),
    // Add more payment systems as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the price at the top
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Total Price: \$${widget.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Select a payment method to proceed.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            // Display payment system options in a grid
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0, // Adjust as needed
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: paymentSystems.length,
              itemBuilder: (context, index) {
                final paymentSystem = paymentSystems[index];

                return ElevatedButton(
                  onPressed: () {
                    // Navigate to the respective payment system page based on the selected system
                    if (paymentSystem.name == 'bKash') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BcashIndex()),
                      );
                    } else if (paymentSystem.name == 'Nagad') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BcashIndex()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentConfirmationPage(
                            selectedPaymentSystem: paymentSystem,
                            price: widget
                                .price, // Pass the total price to the confirmation page
                          ),
                        ),
                      );
                    }
                    // Add more conditions for other payment systems as needed
                  },
                  // rest of the button code...
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.zero,
                    minimumSize: Size(100.0, 120.0),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          paymentSystem.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(paymentSystem.name),
                    ],
                  ),
                );
              },
            ),

            // Display additional text or details at the bottom
          ],
        ),
      ),
    );
  }
}
