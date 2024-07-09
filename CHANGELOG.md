# 0.0.5
# Flutter In-App Purchase Helper

## Overview

Flutter In-App Purchase Helper provides a streamlined solution for integrating in-app purchases into Flutter applications. This document outlines how to set up and use the helper effectively.

### Features

1. Initialize in-app purchases with dynamic product IDs.
2. Fetch available products from the app store.
3. Handle purchase flows and verify transactions.
4. Easy-to-use interface for integrating in-app purchases into any Flutter widget.

## How to Use

- **Initialization (`initState`)**: Initializes FlutterInAppPurchaseHelper with context and sets up product IDs and callbacks for success and error handling.

  ![Initialization Example](https://raw.githubusercontent.com/sooryx/flutter_in_app_purchase_helper/main/image5.png)
  ![Initialization Example](https://raw.githubusercontent.com/sooryx/flutter_in_app_purchase_helper/main/image4.png)

- **Plan Selection (`_togglePlanSelection`)**: Handles selection/deselection of plans.

  ![Plan Selection Example](https://raw.githubusercontent.com/sooryx/flutter_in_app_purchase_helper/main/image2.png)

- **Fetching and Showing Products (`fetchAndShowProducts`)**: Retrieves product information from the store using FlutterInAppPurchaseHelper and displays them in the UI, ensuring accurate pricing and details.

  ![Fetching Products Example](https://raw.githubusercontent.com/sooryx/flutter_in_app_purchase_helper/main/image3.png)

- **Purchase Button**: Triggers purchase through `_inAppPurchaseHelper.buyProduct` function when a plan is selected and handles errors based on the purchase.

  ![Purchase Button Example](https://raw.githubusercontent.com/sooryx/flutter_in_app_purchase_helper/main/image1.png)
