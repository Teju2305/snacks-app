import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_web/razorpay_web.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Razorpay _razorpay;
  final _formKey = GlobalKey<FormState>();
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Razorpay Sample App'),
        ),
        body: !_isLoggedIn ? _buildLoginForm() : _buildCategoriesPage(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  // Login form
  Widget _buildLoginForm() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoggedIn = true;
                    });
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Categories Page with 20 items and price
  Widget _buildCategoriesPage() {
    final categories = [
      {'name': 'Pizza', 'image': 'assets/pizza.jpg', 'price': 500},
      {'name': 'Burger', 'image': 'assets/burger.jpg', 'price': 300},
      {'name': 'Pasta', 'image': 'assets/pasta.jpg', 'price': 400},
      {'name': 'Salad', 'image': 'assets/salad.jpg', 'price': 200},
      {'name': 'Sandwich', 'image': 'assets/sandwich.jpg', 'price': 150},
      {'name': 'Sushi', 'image': 'assets/sushi.jpg', 'price': 700},
      {'name': 'Fries', 'image': 'assets/fries.jpg', 'price': 100},
      {'name': 'Cake', 'image': 'assets/cake.jpg', 'price': 600},
      {'name': 'Donut', 'image': 'assets/donut.jpg', 'price': 80},
      {'name': 'Waffle', 'image': 'assets/waffle.jpg', 'price': 180},
      {'name': 'Steak', 'image': 'assets/steak.jpg', 'price': 800},
      {'name': 'Tacos', 'image': 'assets/tacos.jpg', 'price': 350},
      {'name': 'Smoothie', 'image': 'assets/smoothie.jpg', 'price': 250},
      {'name': 'Coffee', 'image': 'assets/coffee.jpg', 'price': 100},
      {'name': 'Tea', 'image': 'assets/tea.jpg', 'price': 90},
      {'name': 'Juice', 'image': 'assets/juice.jpg', 'price': 130},
      {'name': 'Soup', 'image': 'assets/soup.jpg', 'price': 300},
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(10),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          elevation: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                category['image']! as String, // Cast to String
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              Text(
                category['name']! as String, // Cast to String
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Price: ₹${category['price']! as int}', // Cast to int
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  openCheckout(category['price'] as int); // Cast to int
                },
                child: const Text('Buy Now'),
              ),
            ],
          ),
        );
      },
    );
  }

  void openCheckout(int price) async {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount':
          price * 100, // Razorpay expects amount in paise (₹1 = 100 paise)
      'name': 'Acme Corp.',
      'description': 'Food Item',
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('Success Response: $response');
    Fluttertoast.showToast(
        msg: "SUCCESS: ${response.paymentId!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log('Error Response: $response');
    Fluttertoast.showToast(
        msg: "ERROR: ${response.code} - ${response.message!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External SDK Response: $response');
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: ${response.walletName!}",
        toastLength: Toast.LENGTH_SHORT);
  }
}
