import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/address_list_page/bloc/get_address_list_bloc/get_address_list_bloc.dart';
import 'package:aasyou/utils/widgets/animated_button.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_shimmer.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';
import 'package:geocoding/geocoding.dart';
import 'package:aasyou/model/user_location/user_location_model.dart';
import 'package:remixicon/remixicon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../router/app_routes.dart';
import '../screens/address_list_page/bloc/check_delivery_zone_bloc/check_delivery_zone_bloc.dart';
import '../screens/delivery_zone_list/bloc/delivery_zone/delivery_zone_bloc.dart';
import '../screens/delivery_zone_list/model/delivery_zone_model.dart';
import '../screens/home_page/widgets/location_bottom_sheet.dart';
import '../screens/near_by_stores/bloc/find_stores/find_stores_bloc.dart';
import '../screens/near_by_stores/model/near_by_store_model.dart';
import '../services/auth_guard.dart';
import '../services/location/location_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/widgets/store_card_in_map.dart';
import 'constant.dart';

class LocationPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final bool isFromAddressPage;
  final bool isEdit;
  final int? addressId;
  final String? addressType;
  final bool? isFromCartPage;
  final int? deliveryZoneId;

  const LocationPickerWidget(
      {super.key,
      this.initialLatitude,
      this.initialLongitude,
      this.initialAddress,
      required this.isFromAddressPage,
      required this.isEdit,
      this.addressId,
      this.addressType,
      this.isFromCartPage,
      this.deliveryZoneId});

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget>
    with TickerProviderStateMixin {
  final ScrollController _formScrollController = ScrollController();
  final FocusNode _mobileFocusNode = FocusNode();
  GoogleMapController? mapController;
  LatLng? _currentUserLocation;
  LatLng _centerLocation = LatLng(double.parse(AppHelpers.defaultLat),
      double.parse(AppHelpers.defaultLng));
  bool _isLoading = true;
  bool _isMoving = false;
  StoreData? _selectedStore;
  Offset? _cardOffset;
  String _currentAddress = "Fetching address...";
  bool _showForm = false;
  String selectedAddressType = 'home';
  List<bool> isSelected = [true, false, false];
  List<String> addressTypes = ['home', 'office', 'other'];

  // Add delivery zone check variables
  bool _isCheckingDelivery = false;
  bool _isDeliveryAvailable = false;
  String _deliveryMessage = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _pinAnimationController;
  late CheckDeliveryZoneBloc _checkDeliveryZoneBloc;

  final TextEditingController _searchController = TextEditingController();

  // Form controllers
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  String countryCode = 'IN';

  /// Flags
  bool isLoading = false;

  final Set<Marker> _markers = {};
  final Set<Polygon> _deliveryZonePolygons = {};
  BitmapDescriptor? _storeMarkerIcon;

  List<LocationSuggestion> _placeSuggestions = [];
  bool _isSearchingPlaces = false;


  @override
  void initState() {
    super.initState();

    _mobileFocusNode.addListener(() {
      if (_mobileFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 400), () {
          _formScrollController.animateTo(
            _formScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        });
      }
    });

    // Initialize BLoC
    _checkDeliveryZoneBloc = CheckDeliveryZoneBloc();
    selectedAddressType = widget.addressType ?? 'home';
    // Initialize pin animation
    _pinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initializeLocation();
    _loadCustomMarkerIcon();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<DeliveryZoneBloc>()
          .add(FetchDeliveryZones(perPage: 100, searchQuery: ''));
    });
  }

  void _buildDeliveryZonePolygons(List<DeliveryZoneData> zones) {
    final Set<Polygon> polygons = {};
    for (final zone in zones) {
      final boundary = zone.boundaryJson;
      if (boundary == null || boundary.isEmpty) continue;

      final List<LatLng> points = [];
      for (final point in boundary) {
        final lat = point.lat;
        final lng = point.lng;
        if (lat == null || lng == null) continue;
        points.add(LatLng(lat, lng));
      }
      if (points.isEmpty) continue;

      polygons.add(
        Polygon(
          polygonId: PolygonId('delivery_zone_${zone.id ?? zone.slug ?? points.first}'),
          points: points,
          fillColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          strokeColor: AppTheme.primaryColor,
          strokeWidth: 2,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _deliveryZonePolygons
        ..clear()
        ..addAll(polygons);
    });
  }

  Future<bool> checkUserLoggedIn() async {
    final isLoggedIn = await AuthGuard.ensureLoggedIn(context);
    return isLoggedIn;
  }

  Future<void> _loadCustomMarkerIcon() async {
    try {
      const imageConfig = ImageConfiguration(
        size: Size(38, 42),
        devicePixelRatio: null,
      );

      _storeMarkerIcon = await BitmapDescriptor.asset(
        imageConfig,
        'assets/images/icons/store-marker.png',
      );
    } catch (e) {
      debugPrint('Failed to load marker icon: $e');
      // fallback to default if needed
    }
  }

  @override
  void dispose() {
    _formScrollController.dispose();
    _mobileFocusNode.dispose();
    _searchController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _zipcodeController.dispose();
    _landmarkController.dispose();
    _pinAnimationController.dispose();
    _checkDeliveryZoneBloc.close();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // Set initial location if provided
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _centerLocation =
          LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _currentAddress =
          widget.initialAddress ?? "Selected location"; // Will use l10n
    }
    if (Global.userData?.mobile != null) {
      _mobileController.text = Global.userData!.mobile;
    }
    await _getCurrentUserLocation();

    setState(() {
      _isLoading = false;
    });

    _updateAddressFromCenter();
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentUserLocation = LatLng(double.parse(AppHelpers.defaultLat),
              double.parse(AppHelpers.defaultLng));
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _currentUserLocation = LatLng(double.parse(AppHelpers.defaultLat),
              double.parse(AppHelpers.defaultLng));
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            timeLimit: Duration(seconds: 15)),
      );

      setState(() {
        _currentUserLocation = LatLng(position.latitude, position.longitude);
        // If no initial location provided, use current location
        if (widget.initialLatitude == null || widget.initialLongitude == null) {
          _centerLocation = _currentUserLocation!;
        }
      });
    } catch (e) {
      log('Error getting location: $e');
      setState(() {
        _currentUserLocation = LatLng(double.parse(AppHelpers.defaultLat),
            double.parse(AppHelpers.defaultLng));
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      // _selectedStore = null;
      _cardOffset = null;
      _isMoving = true;
      _centerLocation = position.target;
    });

    // Animate pin when moving
    _pinAnimationController.forward();
  }

  Future<void> _updateAddressFromCenter() async {
    setState(() {
      _currentAddress = "Getting address...";
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _centerLocation.latitude,
        _centerLocation.longitude,
      );

      log('Center Latitude ${_centerLocation.latitude}');
      log('Center Longitude ${_centerLocation.longitude}');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        if (mounted) {
          setState(() {
            _currentAddress = address.isNotEmpty
                ? address
                : "Unknown location"; // Will use l10n
          });
          _prefillFormFields(place);
        }
      } else {
        if (mounted) {
          setState(() {
            _currentAddress = "Unknown location"; // Will use l10n
          });
        }
      }
    } catch (e) {
      log('Error getting address: $e');
      if (mounted) {
        setState(() {
          _currentAddress =
              "Sample Address, ${_centerLocation.latitude.toStringAsFixed(4)}, ${_centerLocation.longitude.toStringAsFixed(4)}";
        });
      }
    }
  }

  void _prefillFormFields(Placemark place) {
    _addressLine1Controller.text = _currentAddress;
    _stateController.text = place.administrativeArea ?? '';
    _cityController.text = place.locality ?? '';
    _zipcodeController.text = place.postalCode ?? '';
    _landmarkController.text = place.name ?? '';
    _countryController.text = place.country ?? '';
    _areaController.text = place.subLocality ?? '';
    countryCode = place.isoCountryCode ?? '';
  }
  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  // ── Places Autocomplete ────────────────────────────────────────────────

  Future<void> _fetchPlaceSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      setState(() => _placeSuggestions.clear());
      return;
    }

    setState(() {
      _isSearchingPlaces = true;
      _placeSuggestions.clear();
    });

    try {
      final dio = Dio();

      final response = await dio.post(
        'https://places.googleapis.com/v1/places:autocomplete',
        data: {
          'input': trimmed,
          'includeQueryPredictions': false,
          'languageCode': Localizations.localeOf(context).languageCode,
        },
        options: Options(
          headers: {
            'X-Goog-Api-Key': Platform.isAndroid
                ? AppConstant.androidMapKey
                : AppConstant.iosMapKey,
            'X-Goog-FieldMask': 'suggestions.placePrediction.place,suggestions.placePrediction.text,suggestions.placePrediction.structuredFormat',
            'Content-Type': 'application/json',
            if (Platform.isIOS)
              'X-IOS-Bundle-Identifier': AppConstant.packageName,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rawSuggestions = data['suggestions'] as List<dynamic>? ?? [];

        final List<LocationSuggestion> parsed = rawSuggestions
            .map((item) {
          final pred = item['placePrediction'] as Map<String, dynamic>?;
          if (pred == null) return null;

          final placeIdRaw = pred['place'] as String?; // e.g. "places/ChIJ..."
          final placeId = placeIdRaw?.replaceFirst('places/', ''); // normalize to short form if needed

          final textMap = pred['text'] as Map<String, dynamic>?;
          final fullText = textMap?['text'] as String? ?? '';

          final structured = pred['structuredFormat'] as Map<String, dynamic>?;
          final main = structured?['mainText']?['text'] as String? ?? '';
          final secondary = structured?['secondaryText']?['text'] as String? ?? '';

          return LocationSuggestion(
            placeId: placeId ?? placeIdRaw, // use short or full — test what works in your details call
            displayName: main.isNotEmpty ? main : fullText.split(',').first.trim(),
            address: secondary.isNotEmpty ? '$main, $secondary' : fullText,
          );
        })
            .whereType<LocationSuggestion>()
            .toList();

        setState(() {
          _placeSuggestions = parsed;
        });
      }
    } catch (e) {
      log('Places autocomplete (New) error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSearchingPlaces = false);
      }
    }
  }

  Future<void> _selectSuggestion(LocationSuggestion suggestion) async {
    final placeId = suggestion.placeId;
    if (placeId == null || placeId.isEmpty) return;

    setState(() => _isSearchingPlaces = true);

    try {
      final dio = Dio();

      // Normalize place ID format (new API often expects "places/..." prefix)
      final normalizedPlace = placeId.startsWith('places/') ? placeId : 'places/$placeId';

      final response = await dio.get(
        'https://places.googleapis.com/v1/$normalizedPlace',
        options: Options(
          headers: {
            'X-Goog-Api-Key': Platform.isAndroid
                ? AppConstant.androidMapKey
                : AppConstant.iosMapKey,
            'X-Goog-FieldMask': 'location,formattedAddress',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        final loc = data['location'] as Map<String, dynamic>?;
        if (loc == null) {
          log('No location data in response');
          return;
        }

        final lat = (loc['latitude'] as num?)?.toDouble() ?? 0.0;
        final lng = (loc['longitude'] as num?)?.toDouble() ?? 0.0;
        final formatted = data['formattedAddress'] as String? ?? suggestion.address;

        final newLatLng = LatLng(lat, lng);

        setState(() {
          _centerLocation = newLatLng;
          _currentAddress = formatted;
        });

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLatLng, 16.0),
        );

        _searchController.clear();
        setState(() => _placeSuggestions.clear());

        _checkDeliveryZone();
      } else {
        log('Place details failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      log('Place details (New) error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSearchingPlaces = false);
      }
    }
  }

  void _onCameraIdle() async {
    setState(() {
      _isMoving = false;
    });

    _pinAnimationController.reverse();
    await _updateAddressFromCenter();

    // ────────────────────────────────────────────────
    if (mapController != null) {
      try {
        final bounds = await mapController!.getVisibleRegion();

        if(AppHelpers.systemVendorTypeIsSingle == false){
          if (mounted) {
            context.read<FindStoresBloc>().add(FindStoresRequest(
              neLat: bounds.northeast.latitude,
              neLng: bounds.northeast.longitude,
              swLat: bounds.southwest.latitude,
              swLng: bounds.southwest.longitude,
              userLat: _currentUserLocation!.latitude,
              userLng: _currentUserLocation!.longitude,
            ));

            log('North-East Lat - ${bounds.northeast.latitude}, Long - ${bounds.northeast.longitude}');
            log('South-West Lat - ${bounds.southwest.latitude}, Long - ${bounds.southwest.longitude}');
          }
        }

      } catch (e) {
        log('Failed to get visible region: $e');
      }
    }

    // Your existing delivery zone check (based on center)
    _checkDeliveryZone();
  }

  void addStoreMarkers(List<StoreData> storeList) async {
    setState(() {
      _markers.clear();
      for (var store in storeList) {
        final lat = double.tryParse(store.latitude?.toString() ?? '') ?? 0.0;
        final lng = double.tryParse(store.longitude?.toString() ?? '') ?? 0.0;
        if (lat == 0.0 && lng == 0.0) continue;
        log('Marker Tapped! Store: ${store.id}');
        _markers.add(
          Marker(
            markerId: MarkerId(
                'store_${store.id ?? store.name ?? UniqueKey().toString()}'),
            position: LatLng(lat, lng),
            icon: _storeMarkerIcon ?? BitmapDescriptor.defaultMarker,
            consumeTapEvents: true,
            onTap: () async {
              // log('Marker Tapped! Store: ${store.name}');
              if (mapController != null) {
                if(mounted){
                  final devicePixelRatio =
                      MediaQuery.of(context).devicePixelRatio;
                  final screenCoordinate =
                  await mapController!.getScreenCoordinate(LatLng(lat, lng));

                  // Convert physical pixels to logical pixels
                  final logicalOffset = Offset(
                    screenCoordinate.x / devicePixelRatio,
                    screenCoordinate.y / devicePixelRatio,
                  );

                  log('Store Tap Physical: $screenCoordinate');
                  log('Store Tap Logical: $logicalOffset');

                  setState(() {
                    _selectedStore = store;
                    _cardOffset = logicalOffset;
                    _isMoving = false;
                  });
                }
              } else {
                log('MapController is NULL');
              }
            },
          ),
        );
      }
    });
  }

  // New method to check delivery zone
  void _checkDeliveryZone() {
    setState(() {
      _isCheckingDelivery = true;
      _isDeliveryAvailable = false;
      _deliveryMessage = '';
    });

    _checkDeliveryZoneBloc.add(CheckDeliveryZoneRequest(
      latitude: _centerLocation.latitude.toString(),
      longitude: _centerLocation.longitude.toString(),
    ));
  }

  void _confirmLocation() async {
    // Out-of-zone handling splits by intent:
    //  - Delivery ADDRESS (isFromAddressPage): still block — an address that
    //    can't receive delivery is pointless and order-create would reject it.
    //  - Browse LOCATION (home): ALLOW saving with a heads-up. The customer
    //    can then browse stores/products anywhere; ordering is gated at
    //    checkout. Previously this was a hard dead-end (couldn't even set
    //    their real location to look around).
    if (!_isDeliveryAvailable && !_showForm) {
      final l10n = AppLocalizations.of(context)!;
      if (widget.isFromAddressPage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_deliveryMessage.isEmpty
                ? l10n.deliveryNotAvailableAtThisLocation
                : _deliveryMessage),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Browse mode: inform, then fall through to save the location.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sorryWeDontDeliverHereYet),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    }

    if (!widget.isFromAddressPage) {
      // Create UserLocation with form data
      UserLocation userLocation = UserLocation(
        latitude: _centerLocation.latitude,
        longitude: _centerLocation.longitude,
        fullAddress: _addressLine1Controller.text.trim(),
        area: _areaController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        pincode: _zipcodeController.text.trim(),
        landmark: _landmarkController.text.trim(),
      );

      await LocationService.storeLocation(userLocation);

      if (mounted) {
        GoRouter.of(context).pop({
          'location': _centerLocation,
          'address': _addressLine1Controller.text,
        });
      }
    } else {
      // Show form only if delivery is available
      if (_isDeliveryAvailable) {
        _toggleForm();
      }
    }
  }

  // Updated method to build delivery status indicator
  Widget _buildDeliveryStatusIndicator() {
    if (!_isDeliveryAvailable && _deliveryMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // height: 30.h,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: isTablet(context) ? 18.r : 20.sp,
                color: Colors.red,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.sorryWeDontDeliverHereYet,
                        style: TextStyle(
                          fontSize: isTablet(context) ? 20 : 14.sp,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                      );
                    },
                  ),
                  SizedBox(height: 4.h),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.thisLocationIsOutsideOurDeliveryZone,
                        style: TextStyle(
                          fontSize: isTablet(context) ? 18 : 12.sp,
                          color: Colors.red.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 5,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFormFields() {
    return Expanded(
      child: SingleChildScrollView(
        controller: _formScrollController,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Header Label
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.addressDetails,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: isTablet(context) ? 20 : 14.sp,
                          fontWeight: FontWeight.w500),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                // Full Address Field
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return CustomTextFormField(
                      controller: _addressLine1Controller,
                      labelText: l10n.addressLine1,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return l10n.pleaseEnterAddressLine1;
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 10.h),

                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return CustomTextFormField(
                      controller: _addressLine2Controller,
                      labelText: l10n.addressLine2Optional,
                    );
                  },
                ),
                SizedBox(height: 10.h),

                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return CustomTextFormField(
                      controller: _countryController,
                      labelText: l10n.country,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return l10n.pleaseEnterCountry;
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 10.h),

                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return CustomTextFormField(
                      controller: _stateController,
                      labelText: l10n.state,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return l10n.pleaseEnterState;
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 10.h),

                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return CustomTextFormField(
                      controller: _cityController,
                      labelText: l10n.city,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return l10n.pleaseEnterCity;
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 10.h),

                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return CustomTextFormField(
                      controller: _zipcodeController,
                      labelText: l10n.zipcode,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return l10n.pleaseEnterZipcode;
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 10.h),

                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return CustomTextFormField(
                      controller: _landmarkController,
                      labelText: l10n.landmark,
                    );
                  },
                ),
                SizedBox(height: 16.h),

                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.contactDetails,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: isTablet(context) ? 20 : 14.sp,
                          fontWeight: FontWeight.w500),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return CustomTextFormField(
                      controller: _mobileController,
                      focusNode: _mobileFocusNode,
                      labelText: l10n.mobileNumber,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return l10n.pleaseEnterMobileNumber;
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 10.h),

                // Address Type
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.saveAddressAs,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: isTablet(context) ? 20 : 14.sp,
                          fontWeight: FontWeight.w500),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                // Address type toggle buttons
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return _buildAddressTypeButton(
                            l10n.home,
                            TablerIcons.home,
                            selectedAddressType == 'home',
                            () {
                              setState(() {
                                selectedAddressType = 'home';
                              });
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return _buildAddressTypeButton(
                            l10n.work,
                            TablerIcons.building_skyscraper,
                            selectedAddressType == 'work',
                            () {
                              setState(() {
                                selectedAddressType = 'work';
                              });
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return _buildAddressTypeButton(
                            l10n.other,
                            TablerIcons.map_pin,
                            selectedAddressType == 'other',
                            () {
                              setState(() {
                                selectedAddressType = 'other';
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 16.h),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTypeButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.8)
                : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : null,
              size: isTablet(context) ? 25 : 20.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet(context) ? 18 : 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addAddressApi() async {
    if (await checkUserLoggedIn()) {
      if (mounted) {
        context.read<GetAddressListBloc>().add(AddAddressRequest(
          addressLine1: _addressLine1Controller.text,
          addressLine2: _addressLine2Controller.text,
          city: _cityController.text,
          landmark: _landmarkController.text,
          state: _stateController.text,
          zipcode: _zipcodeController.text,
          mobile: _mobileController.text,
          addressType: selectedAddressType,
          country: _countryController.text,
          countryCode: countryCode,
          latitude: _centerLocation.latitude.toString(),
          longitude: _centerLocation.longitude.toString(),
          deliveryZoneId: widget.deliveryZoneId));
      }
    } else {
      if (mounted) {
        GoRouter.of(context).pop();
      }
    }
  }

  void updateAddressApi() {
    context.read<GetAddressListBloc>().add(UpdateAddressRequest(
        addressId: widget.addressId!,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text,
        city: _cityController.text,
        landmark: _landmarkController.text,
        state: _stateController.text,
        zipcode: _zipcodeController.text,
        mobile: _mobileController.text,
        addressType: selectedAddressType,
        country: _countryController.text,
        countryCode: countryCode,
        latitude: _centerLocation.latitude.toString(),
        longitude: _centerLocation.longitude.toString()));
  }

  void _moveToCurrentLocation() async {
    if (_currentUserLocation == null) return;

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        _currentUserLocation!,
        16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CustomCircularProgressIndicator(),
        ),
      );
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double mapHeight =
        _showForm ? MediaQuery.of(context).size.height * 0.35 : screenHeight;

    log('Build Map: Store: ${_selectedStore?.name}, Offset: $_cardOffset, Moving: $_isMoving');

    return MultiBlocListener(
      listeners: [
        BlocListener<GetAddressListBloc, GetAddressListState>(
          listener: (BuildContext context, GetAddressListState state) {
            if (state is GetAddressListLoaded) {
              if (state.isRemoved || state.isUpdated || state.isAdded) {
                setState(() {
                  isLoading = false;
                });
                GoRouter.of(context).pop();
              } else if (state.isRemoving ||
                  state.isUpdating ||
                  state.isAdding) {
                setState(() {
                  isLoading = true;
                });
              }
            }
          },
        ),
        BlocListener<FindStoresBloc, FindStoresState>(
          listener: (context, state) {
            if (state is FindStoresLoaded) {
              if(AppHelpers.systemVendorTypeIsSingle == false){
                addStoreMarkers(state.storeList);
              }
            }
          },
        ),
        BlocListener<DeliveryZoneBloc, DeliveryZoneState>(
          listener: (context, state) {
            if (state is DeliveryZoneLoaded) {
              _buildDeliveryZonePolygons(state.deliveryZoneData);
            }
          },
        ),
      ],
      child: BlocProvider<CheckDeliveryZoneBloc>(
        create: (context) => _checkDeliveryZoneBloc,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: BlocListener<CheckDeliveryZoneBloc, CheckDeliveryZoneState>(
            listener: (context, state) {
              if (state is CheckDeliveryZoneSuccess) {
                setState(() {
                  _isDeliveryAvailable = true;
                  _deliveryMessage = state.message;
                  _isCheckingDelivery = false;
                });
              } else if (state is CheckDeliveryZoneFailure) {
                setState(() {
                  _isDeliveryAvailable = false;
                  _deliveryMessage = state.error;
                  _isCheckingDelivery = false;
                });
              } else if (state is CheckDeliveryZoneFailure) {
                setState(() {
                  _isCheckingDelivery = false;
                });
              }
            },
            child: Stack(
              children: [
                const SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                ),
                // Google Map with animated height
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: mapHeight,
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                        },
                        initialCameraPosition: CameraPosition(
                          target: _centerLocation,
                          zoom: 17.0,
                        ),
                        onCameraMove: _onCameraMove,
                        onCameraIdle: _onCameraIdle,
                        scrollGesturesEnabled: _showForm ? false : true,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        rotateGesturesEnabled: _showForm ? false : false,
                        zoomGesturesEnabled: _showForm ? false : true,
                        zoomControlsEnabled: _showForm ? false : true,
                        tiltGesturesEnabled: false,
                        mapToolbarEnabled: false,
                        markers: _markers,
                        polygons: _deliveryZonePolygons,
                        style: isDarkMode(context) ? darkMapStyle : null,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.bottomCenter,
                              child: const Icon(
                                Remix.map_pin_range_fill,
                                color: AppTheme.primaryColor,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          // Back button
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Search field
                          if (!_showForm)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _fetchPlaceSuggestions,
                                  cursorColor: Theme.of(context).colorScheme.tertiary,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.searchAnAreaOrAddress,
                                    hintStyle: TextStyle(color: Colors.grey[500]),
                                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                                    suffixIcon: _isSearchingPlaces
                                        ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      ),
                                    )
                                        : _searchController.text.isNotEmpty
                                        ? IconButton(
                                      icon: Icon(Icons.clear, color: Colors.grey[700]),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _placeSuggestions.clear());
                                      },
                                    )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 10.h,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Suggestions dropdown
                      if (!_showForm && _placeSuggestions.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 8.h),
                          constraints: BoxConstraints(maxHeight: 320.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _placeSuggestions.length,
                            itemBuilder: (context, index) {
                              final sug = _placeSuggestions[index];
                              return ListTile(
                                leading: Icon(
                                  TablerIcons.map_pin,
                                  color: Colors.grey[700],
                                ),
                                title: Text(
                                  sug.displayName.isNotEmpty ? sug.displayName : sug.address,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: sug.displayName.isNotEmpty
                                    ? Text(
                                  sug.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                                    : null,
                                onTap: () => _selectSuggestion(sug),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Bottom address card/form with animation
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      if (!_showForm) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedButton(
                              onTap: () {
                                _moveToCurrentLocation();
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: _showForm ? 0 : 20,
                                  bottom: _showForm ? 0 : 5,
                                  left: _showForm ? 0 : 20,
                                  right: _showForm ? 0 : 20,
                                ),
                                height: 60,
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  TablerIcons.current_location,
                                  size: isTablet(context) ? 24.r : 24.r,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      Container(
                        margin: EdgeInsets.only(
                            top: _showForm ? 0 : 5,
                            bottom: _showForm ? 0 : 16,
                            left: _showForm ? 0 : 16,
                            right: _showForm ? 0 : 16,
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(_showForm ? 0 : 20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Content wrapper
                                SizedBox(
                                  height: _showForm
                                      ? MediaQuery.of(context).size.height *
                                          0.65
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 18),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header with back button for form
                                        if (_showForm)
                                          Builder(
                                            builder: (context) {
                                              final l10n =
                                                  AppLocalizations.of(context)!;
                                              return Row(
                                                children: [
                                                  Text(
                                                    l10n.enterCompleteAddress,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),

                                        if (_showForm)
                                          const SizedBox(height: 20),

                                        // Form fields or address display
                                        if (_showForm)
                                          Expanded(
                                            child: Column(
                                              children: [
                                                _buildFormFields(),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height:
                                                            isTablet(context)
                                                                ? 40.h
                                                                : 48,
                                                        child: OutlinedButton(
                                                          onPressed:
                                                              _toggleForm,
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            side: const BorderSide(
                                                                color: AppTheme
                                                                    .primaryColor),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        14),
                                                          ),
                                                          child: Builder(
                                                            builder: (context) {
                                                              final l10n =
                                                                  AppLocalizations.of(
                                                                      context)!;
                                                              return Text(
                                                                l10n.cancel,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppTheme
                                                                      .primaryColor,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: CustomButton(
                                                        onPressed: () {
                                                          log('Form state ${_formKey.currentState!.validate()}');
                                                          log('Form state ${widget.isEdit}');
                                                          if (_formKey
                                                              .currentState!
                                                              .validate()) {
                                                            if (widget.isEdit) {
                                                              updateAddressApi();
                                                            } else {
                                                              addAddressApi();
                                                            }
                                                          }
                                                        },
                                                        child: isLoading
                                                            ? const SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  valueColor: AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                                ),
                                                              )
                                                            : Builder(
                                                                builder:
                                                                    (context) {
                                                                  final l10n =
                                                                      AppLocalizations.of(
                                                                          context)!;
                                                                  return Text(
                                                                    widget.isEdit
                                                                        ? l10n
                                                                            .update
                                                                        : l10n
                                                                            .confirm,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          Column(
                                            children: [
                                              // Delivery status indicator
                                              _buildDeliveryStatusIndicator(),
                                              if (_isCheckingDelivery ||
                                                  _deliveryMessage.isNotEmpty)
                                                const SizedBox(height: 12),

                                              // Address section
                                              if (!_isMoving)
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      TablerIcons
                                                          .map_pin_filled,
                                                      color:
                                                          AppTheme.primaryColor,
                                                      size: 35,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            _currentAddress
                                                                .split(',')
                                                                .first,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            _currentAddress,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ShimmerWidget.rectangular(
                                                      isBorder: true,
                                                      height: 15,
                                                      width: 150,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 50),
                                                      child: ShimmerWidget
                                                          .rectangular(
                                                        isBorder: true,
                                                        height: 15,
                                                      ),
                                                    )
                                                  ],
                                                ),

                                              const SizedBox(height: 20),

                                              // Proceed button
                                              SizedBox(
                                                width: double.infinity,
                                                height: 50,
                                                child: ElevatedButton(
                                                  onPressed: (_isMoving ||
                                                          _isCheckingDelivery ||
                                                          (!_isDeliveryAvailable &&
                                                              _deliveryMessage
                                                                  .isNotEmpty))
                                                      ? null
                                                      : _confirmLocation,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        _isDeliveryAvailable
                                                            ? AppTheme
                                                                .primaryColor
                                                            : Colors.red,
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  child: _isCheckingDelivery
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const SizedBox(
                                                              width: 20,
                                                              height: 20,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Colors
                                                                            .white),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                            Builder(
                                                              builder:
                                                                  (context) {
                                                                final l10n =
                                                                    AppLocalizations.of(
                                                                        context)!;
                                                                return Text(
                                                                  l10n.checkingDelivery,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        )
                                                      : Builder(
                                                          builder: (context) {
                                                            final l10n =
                                                                AppLocalizations
                                                                    .of(context)!;
                                                            return Text(
                                                              !widget
                                                                      .isFromAddressPage
                                                                  ? l10n
                                                                      .confirmLocation
                                                                  : (_isDeliveryAvailable
                                                                      ? widget
                                                                              .isEdit
                                                                          ? l10n
                                                                              .confirmAddressToProceed
                                                                          : l10n
                                                                              .addAddressToProceed
                                                                      : l10n
                                                                          .deliveryNotAvailable),
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom Store Card
                if(AppHelpers.systemVendorTypeIsSingle == false)
                  if (_selectedStore != null && _cardOffset != null && !_isMoving)
                    Builder(
                      builder: (context) {
                        final double cardWidth = 280.w;
                        final double screenWidth = MediaQuery.of(context).size.width;
                        // Calculate left position to center card on marker
                        double left = _cardOffset!.dx - (cardWidth / 2);

                        // Clamp to screen edges with 16px padding
                        left = math.max(16.0, math.min(left, screenWidth - cardWidth - 16.0));

                        return Positioned(
                          top: _cardOffset!.dy + 10,
                          left: left,
                          child: SizedBox(
                            width: cardWidth,
                            child: StoreCardInMap(
                              key: Key(_selectedStore!.slug ?? _selectedStore!.id.toString()),
                              store: _selectedStore!,
                              onTap: () {
                                if(_selectedStore!.sameLocation != false){
                                  GoRouter.of(context).push(
                                    AppRoutes.nearbyStoreDetails,
                                    extra: {
                                      'store-slug': _selectedStore!.slug,
                                      'store-name': _selectedStore!.name,
                                    },
                                  );
                                }
                              },
                            ),
                          ));
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
