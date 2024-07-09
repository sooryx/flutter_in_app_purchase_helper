import 'package:flutter/material.dart';
import 'package:flutter_in_app_purchase_helper/flutter_in_app_purchase_helper.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late FlutterInAppPurchaseHelper _flutterInAppPurchaseHelper;
  String? _selectedPlan;
  late ProductDetails productDetails;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    ///Initialization (initState): Initializes FlutterInAppPurchaseHelper with context and sets up product IDs
    /// and callbacks for success and error handling.
    _flutterInAppPurchaseHelper = FlutterInAppPurchaseHelper();
    _flutterInAppPurchaseHelper.initialize(
      ///Mention your productIds here after configuring in playconsole or appstore

      productIds: {'PRODUCT_ID_1', 'PRODUCT_ID_2'},
      onProductsFetched: (products) {
        setState(() {
          _products = products;
        });
      },
      ///Handle Success
      onPurchaseSuccess: (purchase) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success')),
        );
      },
      ///Handle Error

      onPurchaseError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );
  }

  @override
  void dispose() {
    ///Dispose the service
    _flutterInAppPurchaseHelper.dispose();
    super.dispose();
  }

  ///Toggle plans
  ///Handles selection/deselection of plans.

  void _togglePlanSelection(String planTitle) {
    setState(() {
      if (_selectedPlan == planTitle) {
        _selectedPlan = null;
      } else {
        _selectedPlan = planTitle;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Replace getAssetImage with your actual image widget
              const Text(
                'Choose the BetterMeal AI plan that suits you: Monthly, or Yearly, and unlock the power of personalized nutrition insights for better health.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Container(
                color: Colors.white,
                margin: const EdgeInsets.all(2),
                child: Column(
                  children: [
                    ///Fetching and Showing Products (fetchAndShowProducts):
                    ///Retrieves product information from the store using FlutterInAppPurchaseHelper and displays them in the UI,
                    /// ensuring accurate pricing and details.
                    for (var prod in _products)
                      PlanCard(
                        title: prod.title,
                        description: prod.description,
                        isActive: _selectedPlan == prod.title,
                        isRecommended: true,
                        icon: Icons.workspaces_filled,
                        onTap: () {
                          setState(() {
                            productDetails = prod;
                          });
                          _togglePlanSelection(prod.title);
                        },
                      )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      ///Purchase Button: Triggers purchase through _inAppPurchaseHelper.buyProduct function when a plan is selected
      ///and handles errors based on the purchase.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            if (_selectedPlan == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a plan.')),
              );
            } else {
              _flutterInAppPurchaseHelper.buyProduct(
                productDetails,
                (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  );
                },
              );
            }
          },
          child: const Text('Select Plan'),
        ),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.title,
    required this.description,
    required this.isActive,
    required this.isRecommended,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isActive;
  final bool isRecommended;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            elevation: isActive ? 10 : 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isActive ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isActive) Container(),
          if (isRecommended) Container(),
        ],
      ),
    );
  }
}
