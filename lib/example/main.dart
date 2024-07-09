import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_purchase_helper/flutter_in_app_purchase_helper.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Widget for displaying a payment screen with in-app purchase options.
class PaymentScreen extends StatefulWidget {
  /// Widget for displaying a payment screen with in-app purchase options.

  const PaymentScreen({super.key});




  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

/// State class for the PaymentScreen widget.
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
          const SnackBar(content: Text('Success')),
        );
        if (kDebugMode) {
          print('Purchase successful for product ID: ${purchase.productID}');
        }
      },
      onPurchaseError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
        if (kDebugMode) {
          print('Error: $error');
        }
      },
    );
  }

  @override
  void dispose() {
    _flutterInAppPurchaseHelper.dispose();
    super.dispose();
  }

  /// Toggles the selection of a plan based on [planTitle].
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

/// Widget for displaying a plan card with title, description, and icon.
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

  /// Title of the plan card.
  final String title;

  /// Description of the plan card.
  final String description;

  /// Whether the plan card is currently active.
  final bool isActive;

  /// Whether the plan card is recommended.
  final bool isRecommended;

  /// Icon displayed on the plan card.
  final IconData icon;

  /// Callback function when the plan card is tapped.
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
          if (isActive) Container(), // Placeholder containers, remove if not needed
          if (isRecommended) Container(), // Placeholder containers, remove if not needed
        ],
      ),
    );
  }
}
