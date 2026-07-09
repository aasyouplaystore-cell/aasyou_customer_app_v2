// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'AasYou';

  @override
  String get appName => 'AasYou';

  @override
  String get welcome => 'مرحباً';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'تسجيل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get home => 'الصفحة الرئيسية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'الفرنسية';

  @override
  String get hindi => 'الهندية';

  @override
  String get gujarati => 'الغوجاراتية';

  @override
  String get telugu => 'التيلجو';

  @override
  String get location => 'الموقع';

  @override
  String get selectLocation => 'اختر الموقع';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get search => 'بحث';

  @override
  String get categories => 'الفئات';

  @override
  String get nearby => 'بالقرب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get ok => 'حسناً';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get networkError => 'خطأ في الشبكة';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get permissionDenied => 'تم رفض الإذن';

  @override
  String get locationPermissionRequired => 'يتطلب إذن الوصول إلى الموقع';

  @override
  String get enableLocation => 'يرجى تفعيل خدمات الموقع';

  @override
  String get appearance => 'المظهر';

  @override
  String get changeAppTheme => 'تغيير سمة التطبيق';

  @override
  String get systemMode => 'وضع النظام';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get apply => 'تطبيق';

  @override
  String get current => 'الحالي';

  @override
  String get cart => 'عربة التسوق';

  @override
  String get viewCouponOffers => 'عرض الكوبونات والعروض';

  @override
  String get placeOrder => 'إتمام الطلب';

  @override
  String get selectPaymentMethod => 'اختر طريقة الدفع';

  @override
  String get payUsing => 'الدفع باستخدام';

  @override
  String get yourCartIsEmpty => 'عربة التسوق فارغة';

  @override
  String get looksLikeYouHaventAddedAnythingYet => 'يبدو أنك لم تضف أي شيء بعد';

  @override
  String get browseProducts => 'تصفح المنتجات';

  @override
  String get addMoreItemsTapped => 'تم النقر لإضافة المزيد من العناصر!';

  @override
  String get removeItem => 'إزالة العنصر';

  @override
  String areYouSureYouWantToRemoveItemFromCart(String item) {
    return 'هل أنت متأكد أنك تريد إزالة $item من العربة؟';
  }

  @override
  String get delete => 'حذف';

  @override
  String get saveForLater => 'احفظه لوقت لاحق';

  @override
  String get billDetails => 'تفاصيل الفاتورة';

  @override
  String get itemsTotal => 'إجمالي العناصر';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get deliveryCharge => 'رسوم التوصيل';

  @override
  String get free => 'مجاناً';

  @override
  String get perStoreDropOffFees => 'رسوم التسليم لكل متجر';

  @override
  String get handlingCharge => 'رسوم المناولة';

  @override
  String get promoCode => 'رمز العرض';

  @override
  String get promoDiscount => 'خصم العرض';

  @override
  String get removeCoupon => 'إزالة الكوبون';

  @override
  String get totalPayable => 'إجمالي المستحق';

  @override
  String get grandTotal => 'المجموع الكلي';

  @override
  String get yourTotalSavings => 'إجمالي التوفير الخاص بك';

  @override
  String get downloadInvoice => 'تحميل الفاتورة';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get noOrdersYet => 'لا توجد طلبات بعد';

  @override
  String get failedToLoadOrders => 'فشل تحميل الطلبات';

  @override
  String get rateOrder => 'تقييم الطلب';

  @override
  String get howWasYourOrder => 'كيف كان طلبك؟';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get orderDetailsRefreshed => 'تم تحديث تفاصيل الطلب';

  @override
  String get rateYourExperience => 'قيّم تجربتك';

  @override
  String get failedToLoadOrderDetails => 'فشل تحميل تفاصيل الطلب';

  @override
  String get noItemsToDisplay => 'لا توجد عناصر للعرض';

  @override
  String get deleteReview => 'حذف التقييم؟';

  @override
  String get thisActionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get edit => 'تعديل';

  @override
  String get cancelItem => 'إلغاء العنصر';

  @override
  String get cancellationPeriodPassed => 'انتهت فترة الإلغاء';

  @override
  String get areYouSureYouWantToCancelThisItem =>
      'هل أنت متأكد أنك تريد إلغاء هذا العنصر؟';

  @override
  String get cancelReturnRequest => 'إلغاء طلب الإرجاع';

  @override
  String get areYouSureYouWantToCancelThisReturnRequest =>
      'هل أنت متأكد أنك تريد إلغاء طلب الإرجاع هذا؟';

  @override
  String get cancelReturnRequestButton => 'إلغاء طلب الإرجاع';

  @override
  String get cancelItemButton => 'إلغاء العنصر';

  @override
  String get howWasYourShoppingExperience => 'كيف كانت تجربتك في التسوق؟';

  @override
  String get trackDelivery => 'تتبع التوصيل';

  @override
  String get myWishlist => 'قائمة رغباتي';

  @override
  String get createNewWishlist => 'إنشاء قائمة رغبات جديدة';

  @override
  String get createNewWishlistTitle => 'إنشاء قائمة رغبات جديدة';

  @override
  String get enterWishlistName => 'أدخل اسم قائمة الرغبات';

  @override
  String get pleaseEnterAWishlistName => 'يرجى إدخال اسم قائمة الرغبات';

  @override
  String get create => 'إنشاء';

  @override
  String get update => 'تحديث';

  @override
  String get editWishlist => 'تعديل قائمة الرغبات';

  @override
  String get noWishlistsYet => 'لا توجد قوائم رغبات بعد';

  @override
  String get noOtherWishlistsAvailable => 'لا توجد قوائم رغبات أخرى';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String deleteWishlistName(String wishlistName) {
    return 'حذف $wishlistName';
  }

  @override
  String get myAddresses => 'عناويني';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get deleteAddress => 'حذف العنوان';

  @override
  String get areYouSureYouWantToDeleteThisAddress =>
      'هل أنت متأكد أنك تريد حذف هذا العنوان؟';

  @override
  String get near => 'بالقرب من';

  @override
  String get noAddressSelected => 'لم يتم اختيار عنوان';

  @override
  String get pleaseSelectAnImageAndEnterYourName =>
      'يرجى اختيار صورة وإدخال اسمك';

  @override
  String get loadingProfile => 'جارٍ تحميل الملف الشخصي...';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String labelCopiedToClipboard(String label) {
    return 'تم نسخ $label إلى الحافظة';
  }

  @override
  String get yourDeliveryAddress => 'عنوان التوصيل الخاص بك';

  @override
  String get shoppingList => 'قائمة التسوق';

  @override
  String get aboutUs => 'معلومات عنا';

  @override
  String get termsCondition => 'الشروط والأحكام';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get refundPolicy => 'سياسة الاسترجاع';

  @override
  String get shippingPolicy => 'سياسة الشحن';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get pleaseEnterYourName => 'يرجى إدخال اسمك';

  @override
  String get nameMustBeAtLeast2Characters =>
      'يجب أن يكون الاسم مكوناً من حرفين على الأقل';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get description => 'الوصف';

  @override
  String get specification => 'المواصفات';

  @override
  String get reviews => 'المراجعات';

  @override
  String get similarProducts => 'منتجات مشابهة';

  @override
  String get specifications => 'المواصفات';

  @override
  String get customerReviews => 'تقييمات العملاء';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get addYourReview => 'أضف تقييمك';

  @override
  String get rateThisProduct => 'قيّم هذا المنتج';

  @override
  String get submitReview => 'إرسال التقييم';

  @override
  String get questionAndAnswers => 'الأسئلة والأجوبة';

  @override
  String get askAQuestion => 'اسأل سؤالاً';

  @override
  String get submit => 'إرسال';

  @override
  String get questionSubmittedSuccessfully => 'تم إرسال السؤال بنجاح!';

  @override
  String get pleaseSelectVariant => 'يرجى اختيار خيار';

  @override
  String get viewProductDetails => 'عرض تفاصيل المنتج';

  @override
  String get productAddedToCartSuccessfully =>
      'تمت إضافة المنتج إلى العربة بنجاح!';

  @override
  String failedToAddProduct(String error) {
    return 'فشل إضافة المنتج: $error';
  }

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get storeClosed => 'مغلق';

  @override
  String get productVariants => 'خيارات المنتج';

  @override
  String get selectVariant => 'اختر الخيار';

  @override
  String get add => 'إضافة';

  @override
  String get noProductFound => 'لم يتم العثور على منتج';

  @override
  String get filters => 'الفلاتر';

  @override
  String get sort => 'ترتيب';

  @override
  String get popularity => 'الأكثر شهرة';

  @override
  String searchResultFor(String title) {
    return 'نتائج البحث عن \"$title\"';
  }

  @override
  String get relevanceDefault => 'الصلة (افتراضي)';

  @override
  String get priceLowToHigh => 'السعر (من الأقل للأعلى)';

  @override
  String get priceHighToLow => 'السعر (من الأعلى للأقل)';

  @override
  String get discountHighToLow => 'الخصم (من الأعلى للأقل)';

  @override
  String get items => 'عناصر';

  @override
  String get startTypingForSuggestions => 'ابدأ بالكتابة للحصول على اقتراحات';

  @override
  String get noSuggestionsFound => 'لم يتم العثور على اقتراحات';

  @override
  String get speak => 'تحدث';

  @override
  String get trySayingSomething => 'حاول قول شيء';

  @override
  String get speechStoppedTryAgain => 'توقف الصوت. حاول مرة أخرى.';

  @override
  String get close => 'إغلاق';

  @override
  String get searchProducts => 'ابحث عن المنتجات...';

  @override
  String get searchForProducts => 'ابحث عن المنتجات';

  @override
  String get typeProductNameBrandOrCategory =>
      'اكتب اسم المنتج أو العلامة التجارية أو الفئة';

  @override
  String get searching => 'جارٍ البحث...';

  @override
  String get trySearchingWithDifferentKeywords =>
      'حاول البحث باستخدام كلمات مختلفة';

  @override
  String get nearbyStores => 'المتاجر القريبة';

  @override
  String get noStoresFoundNearby => 'لم يتم العثور على متاجر قريبة.';

  @override
  String searchInStore(String storeName) {
    return 'البحث في $storeName';
  }

  @override
  String get savedForLater => 'محفوظ لوقت لاحق';

  @override
  String get moveToCart => 'انقل إلى العربة';

  @override
  String get addFirstItem => 'أضف العنصر الأول';

  @override
  String resultFor(String title) {
    return 'النتائج لـ \"$title\"';
  }

  @override
  String get addMoney => 'إضافة رصيد';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get note => 'ملاحظة:';

  @override
  String get hyperlocalWalletBalanceValidFor1Year =>
      'رصيد محفظة AasYou صالح لمدة سنة من تاريخ الإضافة';

  @override
  String get hyperlocalWalletBalanceCannotBeTransferred =>
      'لا يمكن تحويل رصيد محفظة AasYou إلى حساب بنكي وفقاً لتعليمات RBI';

  @override
  String get pleaseEnterAnAmountGreaterThanOrEqualTo1 =>
      'يرجى إدخال مبلغ أكبر من أو يساوي 1';

  @override
  String get transactions => 'المعاملات';

  @override
  String get promoCodeCoupons => 'رموز العرض والكوبونات';

  @override
  String get support => 'الدعم';

  @override
  String get callUs => 'اتصل بنا';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get emailUs => 'راسلنا عبر البريد';

  @override
  String get tapToContact => 'اضغط للاتصال';

  @override
  String rateStoreName(String storeName) {
    return 'قيّم $storeName';
  }

  @override
  String get editYourFeedback => 'تعديل ملاحظاتك';

  @override
  String get howWasYourExperience => 'كيف كانت تجربتك؟';

  @override
  String get tapToRate => 'اضغط للتقييم';

  @override
  String star(int rating) {
    return '$rating نجمة';
  }

  @override
  String stars(int rating) {
    return '$rating نجوم';
  }

  @override
  String get titleRequired => 'العنوان *';

  @override
  String get egGreatService => 'مثال: خدمة رائعة!';

  @override
  String get descriptionRequired => 'الوصف *';

  @override
  String get shareMoreDetails => 'شارك المزيد من التفاصيل...';

  @override
  String get submitFeedback => 'إرسال الملاحظات';

  @override
  String get updateFeedback => 'تحديث الملاحظات';

  @override
  String get updating => 'جارٍ التحديث...';

  @override
  String get submitting => 'جارٍ الإرسال...';

  @override
  String get deleteFeedback => 'حذف الملاحظات';

  @override
  String get areYouSureYouWantToDeleteThisFeedback =>
      'هل تريد حذف هذه الملاحظات؟';

  @override
  String get pleaseGiveARating => 'يرجى إعطاء تقييم';

  @override
  String get pleaseEnterATitle => 'يرجى إدخال عنوان';

  @override
  String get pleaseEnterADescription => 'يرجى إدخال وصف';

  @override
  String get deliveryType => 'نوع التوصيل';

  @override
  String get rushDelivery => 'توصيل سريع';

  @override
  String get fulfillmentMode => 'How would you like to receive your order?';

  @override
  String get fulfillmentDelivery => 'Delivery';

  @override
  String get selfPickup => 'Self Pickup';

  @override
  String get selfPickupSubtitle => 'Collect from the store yourself';

  @override
  String get deliverySubtitle => 'Standard delivery to your address';

  @override
  String get selfPickupUnavailable =>
      'One or more items in your cart aren\'t available for pickup';

  @override
  String get pickupCode => 'Pickup Code';

  @override
  String get pickupCodeInstructions =>
      'Show this 4-digit code at the store counter to collect your order';

  @override
  String get pickupInstructions => 'Pickup Instructions';

  @override
  String get getDirections => 'Get Directions';

  @override
  String get pickupReadyTitle => 'Your order is ready for pickup';

  @override
  String get copyPickupCode => 'Copy code';

  @override
  String get pickupCodeCopiedToClipboard => 'Code copied';

  @override
  String get prioritizedDeliveryForYourUrgentNeeds =>
      'توصيل ذو أولوية لاحتياجاتك العاجلة.';

  @override
  String get regularDelivery => 'توصيل عادي';

  @override
  String get standardDeliveryWithNoExtraCharges =>
      'توصيل قياسي بدون رسوم إضافية.';

  @override
  String get deliverTo => 'التوصيل إلى';

  @override
  String get change => 'تغيير';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get appUnderMaintenance => 'التطبيق تحت الصيانة';

  @override
  String get noOrderFound => 'لم يتم العثور على طلب';

  @override
  String get noSearchResults => 'لا توجد نتائج بحث';

  @override
  String get microphoneUnavailable => 'إذن الميكروفون أو خدمة الصوت غير متوفرة';

  @override
  String get speakNow => 'تحدث الآن';

  @override
  String get listening => 'جارٍ الاستماع...';

  @override
  String get noSpeechDetected => 'لم يتم اكتشاف صوت';

  @override
  String get locationServices => 'خدمات الموقع';

  @override
  String get appPermission => 'إذن التطبيق';

  @override
  String get continueWithGoogle => 'تابع باستخدام جوجل';

  @override
  String get continueWithApple => 'تابع باستخدام آبل';

  @override
  String get continueWithMobile => 'المتابعة باستخدام رقم الهاتف';

  @override
  String get reviewsRatings => 'المراجعات والتقييمات';

  @override
  String get frequentlyAskedQuestions => 'الأسئلة الشائعة';

  @override
  String get dialog => 'مربع الحوار';

  @override
  String get looksLikeTheStoreCatchingSomeRest =>
      'يبدو أن المتجر يأخذ قسطًا من الراحة. عد بعد قليل!';

  @override
  String get addressLine1 => 'سطر العنوان 1';

  @override
  String get addressLine2Optional => 'سطر العنوان 2 (اختياري)';

  @override
  String get country => 'البلد';

  @override
  String get state => 'الولاية';

  @override
  String get city => 'المدينة';

  @override
  String get zipcode => 'الرمز البريدي';

  @override
  String get landmark => 'معلم بارز';

  @override
  String get mobileNumber => 'رقم الجوال';

  @override
  String get soldBy => 'مباع من:';

  @override
  String get searchAnAreaOrAddress => 'ابحث عن منطقة أو عنوان';

  @override
  String get describeTheIssue => 'صف المشكلة';

  @override
  String get writeYourReviewHere => 'اكتب تقييمك هنا...';

  @override
  String get typeYourQuestionHere => 'اكتب سؤالك هنا...';

  @override
  String get enterReviewTitle => 'أدخل عنوان التقييم';

  @override
  String get shareYourThoughts => 'شارك أفكارك...';

  @override
  String get searchForAreaStreetName => 'ابحث عن منطقة أو اسم شارع...';

  @override
  String get pleaseSelectADeliveryAddressFirst =>
      'يرجى اختيار عنوان التوصيل أولاً';

  @override
  String get paymentMethodNotSelected => 'لم يتم اختيار طريقة الدفع';

  @override
  String get inclusiveOfAllTax => '(شامل جميع الضرائب)';

  @override
  String get brand => 'العلامة التجارية';

  @override
  String get packOf => 'عبوة من';

  @override
  String get category => 'الفئة';

  @override
  String get madeIn => 'صنع في';

  @override
  String get indicator => 'المؤشر';

  @override
  String get guaranteePeriod => 'مدة الضمان';

  @override
  String get warrantyPeriod => 'مدة الكفالة';

  @override
  String get returnable => 'قابل للإرجاع';

  @override
  String get na => 'غير متوفر';

  @override
  String get yes => 'نعم';

  @override
  String get noDescriptionAvailable => 'لا يوجد وصف متاح.';

  @override
  String get wallet => 'المحفظة';

  @override
  String get wishlist => 'قائمة الرغبات';

  @override
  String get stores => 'المتاجر';

  @override
  String get account => 'الحساب';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get currentLanguage => 'اللغة الحالية';

  @override
  String get promoApplied => 'تم تطبيق العرض';

  @override
  String get on => 'مفعل';

  @override
  String get rushDeliveryActive => 'التوصيل السريع مفعل';

  @override
  String get cashbackApplied => 'تم تطبيق الكاش باك';

  @override
  String get instantDiscountApplied => 'تم تطبيق الخصم الفوري';

  @override
  String get willBeAdded => 'سيتم الإضافة';

  @override
  String get areYouSure => 'هل أنت متأكد؟';

  @override
  String get clearCartConfirm => 'هل تريد فعلاً إفراغ العربة؟';

  @override
  String get no => 'لا';

  @override
  String get yesClear => 'نعم، امسح';

  @override
  String get logoutConfirmation => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get maxCartItemLimitReached => 'لقد وصلت إلى الحد الأقصى لعدد العناصر';

  @override
  String get all => 'الكل';

  @override
  String get shopByCategories => 'تسوق حسب الفئات';

  @override
  String get topBrands => 'أفضل العلامات التجارية';

  @override
  String get addItemsToGetStarted => 'أضف عناصر للبدء';

  @override
  String get yourShoppingListIsEmpty => 'قائمة التسوق الخاصة بك فارغة';

  @override
  String get listItem => 'عنصر القائمة';

  @override
  String get itemsAdded => 'تمت إضافة عناصر';

  @override
  String get startShopping => 'ابدأ التسوق';

  @override
  String get typeItemName => 'اكتب اسم العنصر...';

  @override
  String get pleaseAdd1ItemInShoppingList =>
      'الرجاء إضافة عنصر واحد (1) على الأقل في قائمة التسوق الخاصة بك';

  @override
  String get selectDeliveryLocation => 'حدد موقع التسليم';

  @override
  String get searchForAreaStreet => 'ابحث عن منطقة، اسم شارع...';

  @override
  String get useCurrentLocation => 'استخدام الموقع الحالي';

  @override
  String get addNewAddress => 'إضافة عنوان جديد';

  @override
  String get savedAddresses => 'العناوين المحفوظة';

  @override
  String get notLoggedIn => 'غير مُسجل الدخول';

  @override
  String get pleaseLoginToViewYourProfile =>
      'الرجاء تسجيل الدخول لعرض ملفك الشخصي';

  @override
  String get goToLogin => 'اذهب إلى تسجيل الدخول';

  @override
  String get trackYourDelivery => 'تتبع طلبك';

  @override
  String get returnItem => 'إرجاع العنصر';

  @override
  String get failedToLoadTrackingData => 'فشل في تحميل بيانات التتبع';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get onTheWay => 'في الطريق';

  @override
  String get trackingLiveLocation => 'تتبع الموقع المباشر';

  @override
  String get arrivingIn => 'سيصل في غضون';

  @override
  String get mins => 'دقيقة';

  @override
  String get deliveryPartner => 'شريك التوصيل';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get orderId => 'رقم الطلب';

  @override
  String get payment => 'الدفع';

  @override
  String get orderPlaced => 'تم وضع الطلب';

  @override
  String get deliveryDetails => 'تفاصيل التوصيل';

  @override
  String copiedToClipboard(String label) {
    return 'تم نسخ $label إلى الحافظة';
  }

  @override
  String get orderIdCopied => 'تم نسخ رقم الطلب!';

  @override
  String get reasonForReturn => 'سبب الإرجاع';

  @override
  String get submitReturn => 'إرسال طلب الإرجاع';

  @override
  String get thisProductIsNotCancelable => 'لا يمكن إلغاء هذا المنتج';

  @override
  String get productCanNoLongerBeCancelled =>
      'لا يمكن إلغاء هذا المنتج بعد الآن';

  @override
  String get thisProductIsNotReturnable => 'لا يمكن إرجاع هذا المنتج';

  @override
  String get returnButton => 'إرجاع';

  @override
  String get qty => 'الكمية';

  @override
  String get moveToEllipsis => 'نقل إلى...';

  @override
  String get addToEllipsis => 'إضافة إلى...';

  @override
  String get locationAccessNeeded => 'مطلوب إذن الوصول إلى الموقع';

  @override
  String get later => 'لاحقًا';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get appPermissions => 'أذونات التطبيق';

  @override
  String get checkingEmail => 'جارٍ التحقق من البريد الإلكتروني...';

  @override
  String searchInStoreName(String storeName) {
    return 'البحث في $storeName';
  }

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get greatService => 'على سبيل المثال، خدمة رائعة!';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get enterYourFullName => 'أدخل اسمك الكامل';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get enterYourPhoneNumber => 'أدخل رقم هاتفك';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور الخاصة بك';

  @override
  String get confirmYourPassword => 'تأكيد كلمة المرور الخاصة بك';

  @override
  String get emailOrPhoneNumber => 'البريد الإلكتروني أو رقم الهاتف';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get uploadImages => 'تحميل الصور';

  @override
  String get tapToUploadPhotos => 'اضغط لتحميل الصور';

  @override
  String get helpUsUnderstandYourExperience => 'ساعدنا على فهم تجربتك';

  @override
  String youCanUploadUpToMaxImages(int max) {
    return 'يمكنك تحميل ما يصل إلى $max صور فقط.';
  }

  @override
  String onlyRemainingMoreImagesAdded(int remaining, int max) {
    return 'تمت إضافة $remaining صور أخرى فقط. الحد الأقصى: $max.';
  }

  @override
  String maxImagesAllowedExtensions(int max, String extensions, String size) {
    return '• الحد الأقصى $max صورة • $extensions • $size لكل صورة';
  }

  @override
  String get product => 'المنتج';

  @override
  String get quantity => 'الكمية';

  @override
  String get price => 'السعر';

  @override
  String get clearCart => 'مسح سلة التسوق';

  @override
  String get clearAllItems => 'مسح جميع العناصر؟';

  @override
  String get allItemsWillBeRemovedCannotBeUndone =>
      'ستتم إزالة جميع العناصر ولا يمكن التراجع عن هذا الإجراء';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح!';

  @override
  String get paymentFailedOrCancelled => 'فشل أو إلغاء الدفع';

  @override
  String get failedToDeleteAddress => 'فشل في حذف العنوان';

  @override
  String get pressAgainToExitTheApp => 'اضغط مرة أخرى للخروج من التطبيق';

  @override
  String get youHaveReachedMaximumLimitOfCart =>
      'لقد وصلت إلى الحد الأقصى لسلة التسوق';

  @override
  String get sellerInformationNotAvailable => 'معلومات البائع غير متوفرة';

  @override
  String get failedToRefreshOrderDetails => 'فشل في تحديث تفاصيل الطلب';

  @override
  String productSavedForLater(String productName) {
    return 'تم حفظ $productName لوقت لاحق';
  }

  @override
  String get promoCodeAppliedOnYourCart =>
      'تم تطبيق الرمز الترويجي على سلة التسوق الخاصة بك';

  @override
  String get youHaveCrossedMaximumCartAmountLimit =>
      'لقد تجاوزت الحد الأقصى لمبلغ سلة التسوق. الرجاء إزالة بعض المنتجات من السلة';

  @override
  String get feedbackSubmittedSuccessfully => 'تم إرسال الملاحظات بنجاح!';

  @override
  String get feedbackUpdatedSuccessfully => 'تم تحديث الملاحظات بنجاح!';

  @override
  String get paymentFailed => 'فشل الدفع';

  @override
  String copiedToClipboardWithLabel(String label) {
    return 'تم نسخ $label إلى الحافظة!';
  }

  @override
  String get pleaseEnterCompleteOTP => 'الرجاء إدخال رمز OTP كاملاً';

  @override
  String get verificationIdNotFound =>
      'لم يتم العثور على معرّف التحقق. الرجاء المحاولة مرة أخرى.';

  @override
  String otpSentTo(String phoneNumber) {
    return 'تم إرسال رمز OTP إلى $phoneNumber';
  }

  @override
  String get registrationDataNotFound =>
      'لم يتم العثور على بيانات التسجيل. الرجاء المحاولة مرة أخرى.';

  @override
  String get noAccountFoundWithEmailOrPhone =>
      'لم يتم العثور على حساب بهذا البريد الإلكتروني أو رقم الهاتف';

  @override
  String get pleaseEnterValidPhoneNumber => 'الرجاء إدخال رقم هاتف صالح';

  @override
  String get emailAlreadyRegistered =>
      'البريد الإلكتروني مسجل بالفعل. الرجاء استخدام بريد إلكتروني مختلف.';

  @override
  String get pleaseEnterYourFullName => 'الرجاء إدخال اسمك الكامل';

  @override
  String get pleaseEnterYourEmail => 'الرجاء إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterAValidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get pleaseEnterYourPhoneNumber => 'الرجاء إدخال رقم هاتفك';

  @override
  String get pleaseEnterYourPassword => 'الرجاء إدخال كلمة المرور الخاصة بك';

  @override
  String get passwordMustBeAtLeast8Characters =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get pleaseConfirmYourPassword => 'الرجاء تأكيد كلمة المرور الخاصة بك';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get otpVerified => 'تم التحقق من رمز OTP';

  @override
  String get pleaseSelectAPaymentMethodFirst => 'الرجاء تحديد طريقة دفع أولاً';

  @override
  String get fetchingAddress => 'جاري جلب العنوان...';

  @override
  String get selectedLocation => 'الموقع المحدد';

  @override
  String get gettingAddress => 'جاري جلب العنوان...';

  @override
  String get unknownLocation => 'موقع غير معروف';

  @override
  String get deliveryNotAvailableAtThisLocation =>
      'التوصيل غير متاح في هذا الموقع';

  @override
  String get sorryWeDontDeliverHereYet => 'عذراً! لا نقوم بالتوصيل هنا بعد';

  @override
  String get thisLocationIsOutsideOurDeliveryZone =>
      'هذا الموقع خارج منطقة التوصيل حالياً. جرب البحث عن منطقة قريبة أو تحقق لاحقاً.';

  @override
  String get addressDetails => 'تفاصيل العنوان';

  @override
  String get pleaseEnterAddressLine1 => 'الرجاء إدخال سطر العنوان 1';

  @override
  String get pleaseEnterCountry => 'الرجاء إدخال الدولة';

  @override
  String get pleaseEnterState => 'الرجاء إدخال الولاية';

  @override
  String get pleaseEnterCity => 'الرجاء إدخال المدينة';

  @override
  String get pleaseEnterZipcode => 'الرجاء إدخال الرمز البريدي';

  @override
  String get contactDetails => 'تفاصيل الاتصال';

  @override
  String get pleaseEnterMobileNumber => 'الرجاء إدخال رقم الجوال';

  @override
  String get saveAddressAs => 'حفظ العنوان باسم';

  @override
  String get work => 'العمل';

  @override
  String get other => 'أخرى';

  @override
  String get enterCompleteAddress => 'أدخل العنوان الكامل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get checkingDelivery => 'جاري التحقق من التوصيل...';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get confirmAddressToProceed => 'أكد العنوان للمتابعة';

  @override
  String get addAddressToProceed => 'أضف عنواناً للمتابعة';

  @override
  String get deliveryNotAvailable => 'التوصيل غير متاح';

  @override
  String get skip => 'تخطي';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInToYourAccount => 'سجل الدخول إلى حسابك للمتابعة';

  @override
  String get verifying => 'جاري التحقق...';

  @override
  String get or => 'أو';

  @override
  String get dontHaveAnAccount => 'ليس لديك حساب؟ ';

  @override
  String get emailVerifiedSuccessfully =>
      'تم التحقق من البريد الإلكتروني بنجاح';

  @override
  String get phoneNumberVerifiedSuccessfully => 'تم التحقق من رقم الهاتف بنجاح';

  @override
  String get thisEmailIsNotRegistered =>
      'هذا البريد الإلكتروني غير مسجل. يرجى التسجيل أولاً.';

  @override
  String get thisPhoneNumberIsNotRegistered =>
      'هذا رقم الهاتف غير مسجل. يرجى التسجيل أولاً.';

  @override
  String get unableToVerifyUser =>
      'تعذر التحقق من المستخدم. يرجى المحاولة مرة أخرى.';

  @override
  String get emailOrPhoneNumberIsRequired =>
      'البريد الإلكتروني أو رقم الهاتف مطلوب';

  @override
  String get enterValidEmailOrPhone =>
      'أدخل بريداً إلكترونياً أو هاتفاً صالحاً';

  @override
  String get passwordIsRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get alreadyHaveAnAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get emailAlreadyRegisteredUseDifferent =>
      'البريد الإلكتروني مسجل بالفعل. يرجى استخدام بريد آخر.';

  @override
  String get changeLocation => 'تغيير الموقع';

  @override
  String get chooseAddressForDelivery => 'اختر عنواناً للتوصيل';

  @override
  String get balance => 'الرصيد';

  @override
  String get tapCoinToRefresh => 'اضغط على العملة للتحديث';

  @override
  String get viewTransactions => 'عرض المعاملات';

  @override
  String get verifyOtp => 'التحقق من رمز OTP';

  @override
  String get pleaseFillDetailsCreateYourAccount =>
      'يرجى ملء التفاصيل لإنشاء حسابك';

  @override
  String get emailAvailable => 'البريد الإلكتروني متاح';

  @override
  String get errorVerifyingEmail => 'خطأ في التحقق من البريد الإلكتروني';

  @override
  String get pleaseAddYourDeliveryAddress =>
      'يرجى إضافة عنوان التوصيل الخاص بك';

  @override
  String get areYouSureDeleteFeedback => 'هل أنت متأكد من حذف التقييم';

  @override
  String get addTo => 'إضافة إلى…';

  @override
  String get moveTo => 'نقل إلى…';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get mobile => 'الجوال';

  @override
  String get rewardPoints => 'نقاط المكافآت';

  @override
  String get referralCode => 'كود الإحالة';

  @override
  String get notProvided => 'غير مقدم';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get failedToLoadProfile => 'فشل تحميل الملف الشخصي';

  @override
  String get pleaseCheckConnection => 'يرجى التحقق من الاتصال وإعادة المحاولة';

  @override
  String get noProfileDataAvailable => 'لا توجد بيانات ملف شخصي متاحة';

  @override
  String get giveYourDeliveryHeroFeedback =>
      'أعطِ تقييماً لسائق التوصيل الخاص بك!';

  @override
  String editYourFeedbackFor(String name) {
    return 'عدل تقييمك لـ $name';
  }

  @override
  String get leaveFeedback => 'ترك تقييم';

  @override
  String get editFeedback => 'تعديل التقييم';

  @override
  String get editSellerFeedback => 'تعديل تقييم البائع';

  @override
  String get leaveSellerFeedback => 'ترك تقييم للبائع';

  @override
  String get productNotApprovedBySeller => 'هذا المنتج غير معتمد من البائع';

  @override
  String get leaveItemFeedback => 'ترك تقييم للعنصر';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get paidOnline => 'مدفوع عبر الإنترنت';

  @override
  String orderPlacedOn(String date) {
    return 'تم تقديم الطلب في $date';
  }

  @override
  String get locationAccessDescription =>
      'تطبيق هذا يقدم خدمات محلية فائقة. يرجى تفعيل الموقع للحصول على توصيات شخصية ونتائج دقيقة.';

  @override
  String get turnOnLocationServicesDescription =>
      'فعّل خدمات الموقع وامنح التطبيق إذن الموقع للمتابعة.';

  @override
  String get loadingPaymentPage => 'جاري تحميل صفحة الدفع...';

  @override
  String youCanUploadUpToImagesOnly(int count) {
    return 'يمكنك رفع حتى $count صور فقط.';
  }

  @override
  String onlyMoreImagesAddedMaxLimit(int remaining, int max) {
    return 'تم إضافة $remaining صورة(صور) إضافية فقط. الحد الأقصى: $max.';
  }

  @override
  String get onlinePaymentMethods => 'طرق الدفع عبر الإنترنت';

  @override
  String get noCategoryFound => 'لم يتم العثور على فئة';

  @override
  String get noStoreFound => 'لم يتم العثور على متجر';

  @override
  String get wereNotHereYet => 'لم نصل هنا بعد';

  @override
  String get weCouldntFindAnyCategories => 'لم نتمكن من العثور على أي فئات.';

  @override
  String get weCouldntFindAnyStoreInYourSelectLocation =>
      'لم نتمكن من العثور على أي متجر في الموقع المحدد.';

  @override
  String get phoneNumberCopied => 'تم نسخ رقم الهاتف إلى الحافظة!';

  @override
  String get emailCopied => 'تم نسخ البريد الإلكتروني إلى الحافظة!';

  @override
  String get pleaseWaitBeforeResending => 'يرجى الانتظار قبل إعادة الإرسال.';

  @override
  String get toPay => 'المبلغ المستحق:';

  @override
  String get currentlyUnavailable => 'غير متاح حالياً';

  @override
  String get noStoresOrProductsAreAvailableInThisAreaRightNow =>
      'لا توجد متاجر أو منتجات متاحة في هذه المنطقة الآن.';

  @override
  String get checkConnectionAndTryAgain =>
      'يرجى التحقق من الاتصال وإعادة المحاولة.';

  @override
  String get weWillBeBackSoon => 'سنعود قريباً. انتظر قليلاً!';

  @override
  String get noOrdersYetDescription => 'يبدو أنه ليس لديك أي طلبات بعد.';

  @override
  String get tryAdjustingSearchTerms => 'جرب تعديل مصطلحات البحث.';

  @override
  String get noProductMatchingSearch =>
      'لم نتمكن من العثور على أي منتجات تطابق بحثك.';

  @override
  String get feedbackDeletedSuccessfully => 'تم حذف التقييم بنجاح!';

  @override
  String get rateDeliveryHero => 'قيّم سائق التوصيل';

  @override
  String get howWasTheDelivery => 'كيف كان التوصيل؟';

  @override
  String get egSuperFastDelivery => 'مثال: توصيل فائق السرعة!';

  @override
  String get youMightAlsoLike => 'قد يعجبك أيضاً';

  @override
  String get storeCurrentlyClosed => 'المتجر مغلق حالياً';

  @override
  String minimumQuantityRequired(Object minQty) {
    return 'الحد الأدنى للكمية المطلوبة هو $minQty';
  }

  @override
  String maximumQuantityAllowed(Object maxQty) {
    return 'الحد الأقصى المسموح به هو $maxQty قطع';
  }

  @override
  String onlyXItemsInStock(Object stock) {
    return 'يوجد $stock قطع فقط متوفرة في المخزون';
  }

  @override
  String minimumCartAmountRequired(
      Object minAmount, Object miniCheckoutAmount) {
    return 'أضف $minAmount إضافية لتصل إلى الحد الأدنى للدفع $miniCheckoutAmount.';
  }

  @override
  String get youHaveReachedMaximumLimitOfTheCart =>
      'لقد وصلت إلى الحد الأقصى للسلة';

  @override
  String get onlyOneStoreAtATime => 'يمكنك الطلب من متجر واحد فقط في كل مرة';

  @override
  String onlyFewLeft(Object stock) {
    return 'تبقت $stock قطع فقط!';
  }

  @override
  String get inStock => 'متوفر';

  @override
  String get noTransactionYet => 'لا توجد معاملات بعد';

  @override
  String get noTransactionDescriptionMsg => 'ستظهر أنشطة محفظتك هنا بمجرد';

  @override
  String get noTransactionDescriptionSecondaryMsg => 'إجراء معاملتك الأولى.';

  @override
  String cannotAddMoreThanXItems(Object remaining) {
    return 'يمكنك إضافة $remaining قطعة إضافية فقط إلى سلتك.';
  }

  @override
  String youCanAddOnlyXMoreItems(Object count) {
    return 'يمكنك إضافة $count قطعة إضافية فقط.';
  }

  @override
  String cartIsAlreadyAtMaximumLimit(Object maxAllowed) {
    return 'وصلت سلتك إلى الحد الأقصى للأصناف ($maxAllowed).';
  }

  @override
  String get cannotAddFromDifferentStore =>
      'يمكنك إضافة أصناف من نفس المتجر فقط. يرجى إفراغ سلتك أو اختيار أصناف من هذا المتجر.';

  @override
  String get cartAlreadyContainsMultipleStores =>
      'تحتوي سلتك بالفعل على أصناف من متاجر متعددة. يرجى إكمال الطلب الحالي أو إفراغ السلة أولاً.';

  @override
  String get inCart => 'في السلة';

  @override
  String get thisActionIsPermanent => 'هذا الإجراء دائم.';

  @override
  String get allYourDataWillBeLostForever => 'ستفقد جميع بياناتك للأبد.';

  @override
  String get addYourFirstAddressToStart => 'أضف عنوانك الأول للبدء';

  @override
  String get noAddressFound => 'لم يتم العثور على عنوان';

  @override
  String get includingAllTax => '(شامل الضريبة)';

  @override
  String get dataPlaceholder => 'بيانات';

  @override
  String get writeYourNoteHere => 'اكتب ملاحظتك هنا...';

  @override
  String get clearingYourCart => 'جاري إفراغ السلة...';

  @override
  String get imagesLabel => 'الصور';

  @override
  String get imagesSubtitle => 'JPG, PNG (بحد أقصى 5 ميجابايت)';

  @override
  String get pdfDocumentLabel => 'ملف PDF';

  @override
  String get pdfDocumentSubtitle => 'ملفات PDF (بحد أقصى 10 ميجابايت)';

  @override
  String get wordDocumentLabel => 'ملف Word';

  @override
  String get wordDocumentSubtitle => 'ملفات DOCX (بحد أقصى 10 ميجابايت)';

  @override
  String cannotOpenFile(String url) {
    return 'لا يمكن فتح الملف: $url';
  }

  @override
  String errorOpeningAttachment(String error) {
    return 'خطأ في فتح المرفق: $error';
  }

  @override
  String get paystackPaymentTitle => 'الدفع عبر Paystack';

  @override
  String get enableLocationTitle => 'تفعيل الموقع';

  @override
  String get failed => 'فشل';

  @override
  String get youWillBeResponsible => 'ستكون مسؤولاً';

  @override
  String get deleteWishlistConfirmation =>
      'هل أنت متأكد أنك تريد حذف قائمة الأمنيات هذه؟';

  @override
  String get noReviewsAvailable => 'لا توجد تقييمات متاحة';

  @override
  String get searchForStore => 'البحث عن متجر';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get next => 'التالي';

  @override
  String get introPage1Title => 'تسوق بثقة';

  @override
  String get introPage1Description =>
      'اكتشف آلاف المنتجات من بائعين موثوقين مع دفع آمن وتوصيل سريع.';

  @override
  String get introPage2Title => 'تتبع طلباتك';

  @override
  String get introPage2Description =>
      'ابقَ على اطلاع من خلال التتبع المباشر واحصل على تنبيهات حول حالة طلبك.';

  @override
  String get introPage3Title => 'إرجاع سهل';

  @override
  String get introPage3Description =>
      'غير راضٍ؟ قم بإرجاع مشترياتك بكل سهولة مع سياسة الإرجاع لمدة 30 يوماً.';

  @override
  String get pleaseEnterAtleast2Letters => 'يرجى إدخال حرفين على الأقل';

  @override
  String get atleast1ItemIsRequired => 'مطلوب صنف واحد على الأقل';

  @override
  String get enterYourPhoneNumberToReceiveOtp =>
      'أدخل رقم هاتفك وسنرسل لك رمز التحقق (OTP).';

  @override
  String get sendOtp => 'إرسال رمز التحقق';

  @override
  String get phoneNumberTooShort => 'يرجى إدخال رقم هاتف صحيح';

  @override
  String get deliveryZones => 'مناطق التوصيل';

  @override
  String get searchDeliveryZone => 'البحث عن منطقة التوصيل';

  @override
  String get zoneDetails => 'تفاصيل المنطقة';

  @override
  String get viewDetailsAboutDeliveryZone => 'عرض تفاصيل منطقة التوصيل';

  @override
  String get zoneInformation => 'معلومات المنطقة';

  @override
  String get zoneId => 'معرف المنطقة';

  @override
  String get zoneName => 'اسم المنطقة';

  @override
  String get status => 'الحالة';

  @override
  String get deliveryFees => 'رسوم التوصيل';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get freeDeliveryAbove => 'توصيل مجاني فوق';

  @override
  String get perKMCharge => 'رسوم لكل كم';

  @override
  String get perStoreFee => 'رسوم لكل متجر';

  @override
  String get deliveryTimes => 'أوقات التوصيل';

  @override
  String get regularTimePerKM => 'الوقت العادي لكل كم';

  @override
  String get bufferTime => 'وقت الاحتياطي';

  @override
  String get coverageDetails => 'تفاصيل التغطية';

  @override
  String get radius => 'نصف القطر';

  @override
  String get centerCoordinates => 'إحداثيات المركز';

  @override
  String get boundaryPoints => 'نقاط الحدود';

  @override
  String get handlingFee => 'رسوم المعالجة';

  @override
  String get coverageRadius => 'نصف قطر التغطية';

  @override
  String get noteThisStoreIsNOtAvailableInYourLocation =>
      'ملاحظة: هذا المتجر غير متوفر في موقعك.';

  @override
  String get rush => 'عاجل';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get applyFilters => 'تطبيق الفلاتر';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAllAsRead => 'تحديد الكل كمقروء';

  @override
  String get yourWishlistIsEmpty => 'قائمة الرغبات فارغة';

  @override
  String get createYourFirstWishlistToOrganizeAndSaveItemsYouHave =>
      'أنشئ قائمة رغباتك الأولى لتنظيم وحفظ العناصر التي تحبها';

  @override
  String get viewOrderDetails => 'عرض تفاصيل الطلب';

  @override
  String get phoneNumberAlreadyRegistered => 'رقم الهاتف مسجل بالفعل';

  @override
  String get pleaseSelectAValidCountryCode => 'يرجى اختيار رمز دولة صالح';

  @override
  String get phoneNumberAvailable => 'رقم الهاتف متاح';

  @override
  String get totalItems => 'إجمالي العناصر';

  @override
  String get noPromoCodesAvailable => 'لا توجد رموز ترويجية متاحة';

  @override
  String get thereAreNoActivePromoCodeOrCouponsAvailableRightNow =>
      'لا توجد رموز ترويجية أو قسائم نشطة متاحة حاليًا';

  @override
  String get phoneNumberTooLong => 'رقم الهاتف طويل جدًا';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get forceUpdateDialogMessage =>
      'A new version is available. Please update to continue using the app.';

  @override
  String get doItLater => 'Do it later';

  @override
  String get updateNow => 'Update Now';

  @override
  String get comingSoonTitle => 'Coming Soon';

  @override
  String get comingSoonMessage =>
      'A newer version of the app is being prepared. It will be available on the store shortly.\n\nThank you for your patience!';

  @override
  String get referralCodeHintText => 'Referral Code (Optional)';

  @override
  String get referAndEarn => 'Refer and Earn';

  @override
  String get failedToLoadReferralData => 'Failed to load referral data';

  @override
  String get yourReferralCode => 'Your Referral Code';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get appLink => 'App Link';

  @override
  String get linkCopied => 'Link copied!';

  @override
  String get howItWorks => 'How It Works';

  @override
  String get shareYourCode => 'Share Your Code';

  @override
  String get sendYourReferralCodeOrAppLinkToFriends =>
      'Send your referral code or app link to friends.';

  @override
  String get friendSignsUp => 'Friend Signs Up';

  @override
  String get theyRegisterUsingYourReferralCode =>
      'They register using your referral code.';

  @override
  String get youEarn => 'You Earn';

  @override
  String get whenTheyCompleteTheirFirstOrderYouEarn =>
      'When they complete their first order, you earn';

  @override
  String get upTo => 'up to';

  @override
  String get shareNow => 'Share Now';

  @override
  String get referAndEarnTitle => 'Refer your friends & earn rewards';

  @override
  String get referAndEarnDescription =>
      'Invite your friends using your referral code and earn rewards when they sign up and place their first order';

  @override
  String get share => 'Share';

  @override
  String get subCategories => 'Sub Categories';

  @override
  String get addonGroupRequiredError => 'يرجى اختيار خيار واحد على الأقل';

  @override
  String get editAddOnsTitle => 'تعديل الإضافات';

  @override
  String get noAddOnsAvailable => 'لا توجد إضافات متاحة لهذا العنصر';

  @override
  String get addOnsLoadError => 'تعذّر تحميل الإضافات';

  @override
  String get addonsTitle => 'الإضافات';

  @override
  String get addonHintSelectOneRequired => 'اختر 1 (مطلوب)';

  @override
  String get addonHintSelectOne => 'اختر أي واحد';

  @override
  String get addonHintSelectAtLeastOneRequired => 'اختر 1 على الأقل (مطلوب)';

  @override
  String get addonHintSelectAny => 'اختر أي منها';

  @override
  String get addonRequiredBadge => 'مطلوب';

  @override
  String get addonUnavailable => 'غير متاح';

  @override
  String get yourCustomisations => 'تخصيصاتك';

  @override
  String get addNewCustomisation => 'إضافة تخصيص جديد';

  @override
  String get verify => 'Verify';

  @override
  String get verified => 'Verified';

  @override
  String get pleaseVerifyEmailAndMobileBeforePlacingOrder =>
      'Please verify your email and mobile number before placing the order.';

  @override
  String get pleaseVerifyMobileBeforePlacingOrder =>
      'Please verify your mobile number before placing the order.';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String get mobileVerification => 'Mobile Verification';

  @override
  String get sendVerificationEmail => 'Send Verification Email';

  @override
  String get resendEmail => 'Resend Email';

  @override
  String get checkVerificationStatus => 'Check Verification Status';

  @override
  String get verificationLinkSentMessage =>
      'We\'ve sent a verification link to your email address. Open it in your browser to finish verifying.';

  @override
  String get verificationEmailSentSuccessfully => 'Verification email sent';

  @override
  String get emailIsNowVerified => 'Your email is now verified';

  @override
  String get emailStillNotVerified =>
      'Email is not verified yet. Please check your inbox and open the link.';

  @override
  String get addEmail => 'Add Email';

  @override
  String get addMobile => 'Add Mobile';

  @override
  String get customisable => 'Customisable';

  @override
  String get onlyNumbersAllowed => 'Only numbers allowed';

  @override
  String get verifyYourPhone => 'Verify Your Phone';

  @override
  String get weSentVerificationCodeTo => 'We sent a verification code to';

  @override
  String get didntReceiveCode => 'Didn\'t receive code?';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendInSeconds(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String get recommended => 'موصى به';

  @override
  String get sponsored => 'مُموَّل';

  @override
  String get repeatOrder => 'تكرار الطلب';

  @override
  String get orderNote => 'ملاحظة الطلب';

  @override
  String get noteForDeliveryPartner => 'ملاحظة لشريك التوصيل';

  @override
  String get needHelpWithOrder => 'هل تحتاج مساعدة في هذا الطلب؟';

  @override
  String get statusPlaced => 'تم الإنشاء';

  @override
  String get statusPartiallyAccepted => 'مقبول جزئياً';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusPreparing => 'قيد التحضير';

  @override
  String get statusShipped => 'تم الشحن';

  @override
  String get statusOutForDelivery => 'في طريق التوصيل';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusCancelled => 'مُلغى';

  @override
  String get statusReturned => 'تم الإرجاع';

  @override
  String get statusFailed => 'فشل';

  @override
  String get statusReadyForPickup => 'جاهز للاستلام';

  @override
  String get statusAssigned => 'تم التعيين';

  @override
  String get heroAwaitingConfirmation => 'في انتظار التأكيد';

  @override
  String get heroReadyForPickup => 'طلبك جاهز للاستلام';

  @override
  String get heroAssigned => 'تم تعيين شريك التوصيل';

  @override
  String get secondaryAssigned => 'شريك التوصيل في طريقه لاستلام طلبك';

  @override
  String get heroPartiallyAccepted => 'تم قبول الطلب جزئياً';

  @override
  String get heroStorePreparing => 'المتجر يحضّر طلبك';

  @override
  String heroArrivingBy(String time) {
    return 'يصل بحلول $time';
  }

  @override
  String get heroOnTheWay => 'في الطريق';

  @override
  String get secondaryReadyForPickup => 'توجه إلى المتجر لاستلام طلبك';

  @override
  String get heroDeliveredOnTime => 'تم التوصيل في الوقت المحدد';

  @override
  String get heroDelivered => 'تم التوصيل';

  @override
  String get heroOrderCancelled => 'تم إلغاء الطلب';

  @override
  String get heroReturnedAndRefunded => 'تم الإرجاع والاسترداد';

  @override
  String get heroPaymentFailed => 'فشل الدفع';

  @override
  String get heroRunningLate => 'متأخر قليلاً';

  @override
  String secondaryPlacedAndEta(String placed, String eta) {
    return 'تم الإنشاء $placed · الوصول المتوقع $eta';
  }

  @override
  String get secondaryUsuallyAccepted => 'يُقبل عادةً في غضون دقيقتين';

  @override
  String secondaryPartialItems(int count) {
    return '$count عناصر غير متوفرة';
  }

  @override
  String itemCountAccepted(int count) {
    return '$count مقبول';
  }

  @override
  String itemCountPreparing(int count) {
    return '$count قيد التحضير';
  }

  @override
  String itemCountRejected(int count) {
    return '$count مرفوض';
  }

  @override
  String itemCountPending(int count) {
    return '$count قيد الانتظار';
  }

  @override
  String secondaryDistanceAway(String name, String distance, int minutes) {
    return '$name على بُعد $distance · ~$minutes دقيقة';
  }

  @override
  String secondaryDeliveredOn(String date, String time) {
    return '$date · $time';
  }

  @override
  String secondaryCancelledByYou(String date) {
    return 'تم الإلغاء بواسطتك · $date';
  }

  @override
  String secondaryCancelledByStore(String date) {
    return 'تم الإلغاء من المتجر · $date';
  }

  @override
  String secondaryItemsReturned(int count, String date) {
    return 'تم إرجاع $count عناصر · $date';
  }

  @override
  String secondaryExpectedBy(String time) {
    return 'متوقع بحلول $time';
  }

  @override
  String get actionTrackDelivery => 'تتبع التوصيل';

  @override
  String get actionTrackOrder => 'تتبع الطلب';

  @override
  String get actionCancelOrder => 'إلغاء الطلب';

  @override
  String get actionReorder => 'إعادة الطلب';

  @override
  String get actionReturn => 'إرجاع';

  @override
  String get actionRetryPayment => 'إعادة محاولة الدفع';

  @override
  String get refundProcessing => 'قيد المعالجة';

  @override
  String get refundCredited => 'تم الإيداع';

  @override
  String refundProcessingNote(String amount) {
    return 'سيتم إيداع $amount في محفظتك خلال 1–3 أيام';
  }

  @override
  String refundCreditedNote(String amount, String date) {
    return 'تمت إضافة $amount إلى محفظتك في $date';
  }

  @override
  String get refundStatusLabel => 'حالة الاسترداد';

  @override
  String get refundLabel => 'استرداد';

  @override
  String itemsCount(int count) {
    return '$count عناصر';
  }

  @override
  String viewMoreItems(int count) {
    return 'عرض $count عناصر إضافية';
  }

  @override
  String get subtotalLabel => 'المجموع الفرعي';

  @override
  String qtyShort(int count) {
    return 'الكمية $count';
  }

  @override
  String get otpChip => 'رمز التحقق';

  @override
  String get ratingExperience => 'قيّم تجربتك';

  @override
  String get totalPaid => 'المبلغ المدفوع';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get deliveredTo => 'تم التوصيل إلى';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get placedOn => 'تم إنشاؤه في';

  @override
  String get invoiceLabel => 'الفاتورة';

  @override
  String get downloadLabel => 'تحميل';

  @override
  String get addressTypeHome => 'المنزل';

  @override
  String get addressTypeWork => 'العمل';

  @override
  String get addressTypeOther => 'أخرى';

  @override
  String get errorLoadingOrder => 'تعذر تحميل تفاصيل الطلب';

  @override
  String get retryLabel => 'إعادة المحاولة';

  @override
  String get waitingForStoreToAccept => 'في انتظار قبول المتجر لطلبك';

  @override
  String get partialOrderAccepted => 'بعض العناصر غير متوفرة. يرجى مراجعة طلبك';

  @override
  String get trackingOrder => 'تتبع الطلب';

  @override
  String get orderDelivered => 'تم توصيل الطلب';

  @override
  String get successfullyDelivered => 'تم التوصيل بنجاح';

  @override
  String get orderDeliveredSuccessfully => 'تم توصيل طلبك بنجاح';

  @override
  String get shortly => 'قريبًا';

  @override
  String get minutesLabel => 'دقائق';

  @override
  String get destinationLabel => 'الوجهة';

  @override
  String get paidLabel => 'مدفوع';

  @override
  String hurryOnlyLeft(int count) {
    return 'أسرع! بقي $count فقط';
  }

  @override
  String nReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييمات',
      one: 'تقييم واحد',
    );
    return '$_temp0';
  }

  @override
  String get checkOutThisProduct => 'ألقِ نظرة على هذا المنتج!';

  @override
  String get information => 'معلومات';

  @override
  String get rewards => 'المكافآت';

  @override
  String get orderTransaction => 'معاملات الطلب';

  @override
  String get authMessage =>
      'يرجى تسجيل الدخول للمتابعة. يساعدنا ذلك في حفظ تفضيلاتك والحفاظ على تجربة تسوق سلسة.';

  @override
  String get referralCodeTitle => 'هل لديك رمز دعوة؟';

  @override
  String get referralCodeSubtitle =>
      'طبّق رمز دعوة صديق لفتح المكافآت. يمكنك تخطي هذه الخطوة أيضاً.';

  @override
  String get referralCodeHint => 'أدخل رمز الإحالة';

  @override
  String get referralCodePrefilledHint => 'تمت إضافة الرمز من رابط دعوتك';

  @override
  String get applyReferralCode => 'تطبيق';

  @override
  String get skipReferral => 'تخطي';

  @override
  String get referralAppliedSuccess => 'تم تطبيق رمز الإحالة';

  @override
  String get referralFailedRetry =>
      'تعذر تحديث الإحالة. يرجى المحاولة مرة أخرى.';

  @override
  String get marketCategories => 'فئات السوق';

  @override
  String get marketCategoriesDescription => 'تصفح الأسواق القريبة منك';

  @override
  String get shopByMarketCategory => 'تسوق حسب السوق';

  @override
  String get browseMarkets => 'تصفح الأسواق';

  @override
  String get storesInThisMarket => 'المتاجر في هذا السوق';

  @override
  String get noMarketCategoriesFound => 'لم نتمكن من العثور على أي فئة سوق.';

  @override
  String get noStoresInMarket => 'لا توجد متاجر في هذا السوق حتى الآن.';

  @override
  String storeCountOne(int count) {
    return '$count متجر';
  }

  @override
  String storeCountOther(int count) {
    return '$count متاجر';
  }

  @override
  String get addressCopied => 'Address copied';

  @override
  String get copyAddress => 'Copy address';

  @override
  String get pickupAddressNotAvailable => 'Pickup address not available';

  @override
  String get pickupOtpLoading => 'Loading pickup code...';

  @override
  String get pickupOtpFetchFailed => 'Could not load pickup code';

  @override
  String get pickupCallStore => 'Call Store';

  @override
  String get pickupCallFailed => 'Unable to start call';

  @override
  String get pickupMapsFailed => 'Unable to open maps';

  @override
  String get fulfillmentSelfPickup => 'Self Pickup';

  @override
  String get fulfillmentSelfPickupSubtitle => 'Collect from the store yourself';

  @override
  String get fulfillmentSelfPickupUnavailable =>
      'Self pickup is not available right now';

  @override
  String get fulfillmentDeliverySubtitle => 'Standard delivery to your address';

  @override
  String get pickupOtpTitle => 'Pickup Code';

  @override
  String get pickupOtpCopy => 'Copy';

  @override
  String get pickupOtpCopied => 'Code copied to clipboard';

  @override
  String get pickupAddressCopied => 'Address copied';

  @override
  String get pickupOpenMaps => 'Get Directions';

  @override
  String get store => 'Store';

  @override
  String get pickup => 'Pickup';
}
