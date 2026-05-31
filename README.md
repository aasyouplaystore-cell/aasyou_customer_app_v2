# AasYou - Customer App

A comprehensive, state-of-the-art Flutter application for AasYou multivendor e-commerce. This app provides a seamless shopping experience for customers to browse nearby stores, manage carts, make secure payments, and track orders in real-time.

---

## 🚀 Project Overview (Deep Dive)

The **AasYou Customer App** is designed to bridge the gap between local vendors and customers. It supports a complex multivendor ecosystem with the following core modules:

### 1. **Vendor & Catalog Management**
- **Multivendor Ecosystem**: Customers can browse products from multiple nearby stores.
- **Dynamic Categories & Brands**: Supports nested categories and brand-based filtering.
- **Product Details**: Rich product pages with variant selection, FAQs, reviews, and high-quality image carousels.

### 2. **Advanced Shopping Cart**
- **Hybrid Cart Sync**: Manages a local cart using **Hive** for offline access and syncs with the remote server once the user is authenticated.
- **Attachment Support**: Users can upload attachments (e.g., prescriptions or notes) during the checkout process.
- **Promo Codes**: Real-time validation and application of discount coupons.

### 3. **Secure Checkout & Payments**
- **Multi-Gateway Integration**: Built-in support for **Stripe, Razorpay, Paystack, PayPal, and Flutterwave**.
- **Wallet System**: A dedicated virtual wallet for recharging and direct payments, enhancing transaction speed.
- **Cash on Delivery (COD)**: Legacy payment support for traditional users.

### 4. **User Engagement & Trust**
- **Triple Feedback System**: Allows customers to rate **Products, Sellers, and Delivery Boys** separately.
- **Real-time Tracking**: Live order status tracking with interactive maps.
- **Wishlist & Save for Later**: Tools for users to manage their future purchases.

### 5. **Robust Infrastructure**
- **Localization**: Full support for internationalization (i18n) via ARB files.
- **Theme Engine**: Dynamic Light and Dark mode support.
- **Location Intelligence**: Geocoding and map integration for precise delivery address management and delivery zone validation.

---

## 🏗️ Architecture & Technical Flow

### **State Management**
The project exclusively uses **Flutter BLoC** for predictable state management across 40+ modules. This ensures a clear separation of business logic from the UI.

### **Navigation**
Powered by **GoRouter**, providing a declarative routing system with support for nested navigation (StatefulShellRoute) and deep linking.

### **Data Layer**
- **Networking**: Handled by **Dio** with a centralized `ApiBaseHelper` for error handling and header management.
- **Persistence**: Uses **Hive** for fast, local storage of user preferences, cart status, and location data.
- **Authentication**: Integrated with **Firebase Auth** for phone/OTP and social logins.

---

## ⚙️ Configuration Guide

Key configurations are centralized to make the project easy to customize:

- **Global Constants**: `lib/config/constant.dart`
  - Change `baseUrl`, `googleMapsKey`, and `appName` here.
- **API Routes**: `lib/config/api_routes.dart`
  - Manage all endpoint paths in one place.
- **Payment Setup**: `lib/config/payment_config.dart`
  - Enable/Disable specific payment gateways.
- **App Settings**: `lib/config/settings_data_instance.dart`
  - A singleton that holds dynamic settings fetched from the server-side admin panel.

---

## 🛠️ Developer Instructions

### **1. Setup**
```bash
# Install dependencies
flutter pub get

# Run code generator (for Hive and Freezed models)
flutter pub run build_runner build --delete-conflicting-outputs
```

### **2. Firebase Setup**
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are properly placed.
- Run `flutterfire configure` to update `lib/firebase_options.dart`.

### **3. Important Notes**
- **Single Store Logic**: The app can be configured to restrict orders to a single store per transaction (check `single_store` in settings).
- **Delivery Zones**: Orders are only allowed if the user's address falls within a vendor's delivery zone.
- **Permissions**: Ensure `location` and `notification` permissions are handled in `AndroidManifest.xml` and `Info.plist`.

---

## 📂 Project Structure Highlights
- `/lib/bloc/`: Global state management.
- `/lib/config/`: Core configurations and services.
- `/lib/screens/`: Feature-specific UI modules (each with its own BLoC).
- `/lib/services/`: Local persistence and external service wrappers.
- `/lib/utils/`: Shared widgets and utility functions.
