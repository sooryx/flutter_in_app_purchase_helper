import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class FlutterInAppPurchaseHelper {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = true;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  final BuildContext context;

  FlutterInAppPurchaseHelper({required this.context});

  Future<void> initialize({
    required Set<String> productIds,
    required Function(List<ProductDetails>) onProductsFetched,
    required Function(PurchaseDetails) onPurchaseSuccess,
    required Function(String) onPurchaseError,
  }) async {
    _available = await _inAppPurchase.isAvailable();

    if (_available) {
      await _getProducts(productIds, onProductsFetched);
      _subscription = _inAppPurchase.purchaseStream.listen((data) {
        _purchases.addAll(data);
        _verifyPurchases(data, onPurchaseSuccess, onPurchaseError);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        print('Error: $error');
        onPurchaseError(error.toString());
      });
    } else {
      onPurchaseError('In-app purchases not available');
    }
  }

  Future<void> _getProducts(Set<String> productIds, Function(List<ProductDetails>) onProductsFetched) async {
    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

    _products = response.productDetails;
    onProductsFetched(_products);
  }

  void buyProduct(ProductDetails productDetails, Function(String) onError) {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      onError(e.toString());
    }
  }

  void _verifyPurchases(List<PurchaseDetails> purchases, Function(PurchaseDetails) onSuccess, Function(String) onError) {
    for (PurchaseDetails purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        onSuccess(purchase);
      } else {
        onError('Purchase failed or not purchased for product ID: ${purchase.productID}');
      }
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
