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
  const PaymentScreen({Key? key}) : super(key: key);

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
    _flutterInAppPurchaseHelper = FlutterInAppPurchaseHelper(context: context);
    _flutterInAppPurchaseHelper.initialize(
      productIds: {'PRODUCT_ID_1', 'PRODUCT_ID_2'},
      onProductsFetched: (products) {
        setState(() {
          _products = products;
        });
      },
      onPurchaseSuccess: (purchase) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Success')),
        );
        print('Purchase successful for product ID: ${purchase.productID}');
      },
      onPurchaseError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
        print('Error: $error');
      },
    );
  }

  @override
  void dispose() {
    _flutterInAppPurchaseHelper.dispose();
    super.dispose();
  }

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
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Replace getAssetImage with your actual image widget
              const Text(
                'Choose the BetterMeal AI plan that suits you: Monthly, or Yearly, and unlock the power of personalized nutrition insights for better health.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 40),
              Container(
                color: Colors.white,
                margin: EdgeInsets.all(2),
                child: Column(
                  children: [
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
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
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
    Key? key,
    required this.title,
    required this.description,
    required this.isActive,
    required this.isRecommended,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

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
          Container(
            child: Card(
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
          ),
          if (isActive) Container(),
          if (isRecommended) Container(),
        ],
      ),
    );
  }
}
