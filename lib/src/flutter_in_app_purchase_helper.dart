import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Helper class for managing in-app purchases in Flutter applications.
class FlutterInAppPurchaseHelper {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = true;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];


  /// Initializes the in-app purchase system.
  ///
  /// Retrieves product details and sets up purchase handling.
  ///
  /// Required parameters:
  /// - `productIds`: Set of product identifiers to fetch details for.
  /// - `onProductsFetched`: Callback function called when products are fetched.
  /// - `onPurchaseSuccess`: Callback function called when a purchase is successful.
  /// - `onPurchaseError`: Callback function called when a purchase encounters an error.
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
        if (kDebugMode) {
          print('Error: $error');
        }
        onPurchaseError(error.toString());
      });
    } else {
      onPurchaseError('In-app purchases not available');
    }
  }

  /// Fetches product details for given product IDs.
  ///
  /// Calls `onProductsFetched` callback with fetched product details.
  Future<void> _getProducts(Set<String> productIds, Function(List<ProductDetails>) onProductsFetched) async {
    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

    _products = response.productDetails;
    onProductsFetched(_products);
  }

  /// Initiates a purchase for a given product.
  ///
  /// Calls `onError` callback if the purchase encounters an error.
  void buyProduct(ProductDetails productDetails, Function(String) onError) {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verifies the status of purchases.
  ///
  /// Calls `onSuccess` callback for successful purchases and `onError` for failed purchases.
  void _verifyPurchases(List<PurchaseDetails> purchases, Function(PurchaseDetails) onSuccess, Function(String) onError) {
    for (PurchaseDetails purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        onSuccess(purchase);
      } else {
        onError('Purchase failed or not purchased for product ID: ${purchase.productID}');
      }
    }
  }

  /// Cancels the subscription to purchase stream.
  void dispose() {
    _subscription.cancel();
  }
}
