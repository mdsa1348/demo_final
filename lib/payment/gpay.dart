// import 'package:flutter/material.dart';
// import 'package:pay/pay.dart';


// class GPayPage extends StatefulWidget {
//   final List<PaymentItem> paymentItems;

//   GPayPage({required this.paymentItems});

//   @override
//   _GPayPageState createState() => _GPayPageState();
// }

// class _GPayPageState extends State<GPayPage> {
//   late final Future<PaymentConfiguration> _googlePayConfigFuture;

//   @override
//   void initState() {
//     super.initState();
//     _googlePayConfigFuture = PaymentConfiguration.fromAsset('google_pay_config.json');
//   }

//   void onGooglePayResult(paymentResult) {
//     // Send the resulting Google Pay token to your server / PSP
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Pay Page'),
//       ),
//       body: Center(
//         child: FutureBuilder<PaymentConfiguration>(
//           future: _googlePayConfigFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               if (snapshot.hasData) {
//                 return Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GooglePayButton(
//                       paymentConfiguration: snapshot.data!,
//                       paymentItems: widget.paymentItems,
//                       type: GooglePayButtonType.buy,
//                       margin: const EdgeInsets.only(top: 15.0),
//                       onPaymentResult: onGooglePayResult,
//                       loadingIndicator: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//                     // Add additional UI or widgets as needed
//                   ],
//                 );
//               } else {
//                 // Handle the case where loading configuration failed
//                 return Center(
//                   child: Text('Failed to load Google Pay configuration'),
//                 );
//               }
//             } else {
//               // Loading indicator while waiting for configuration
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
