import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/home_page/widgets/saved_address_list_widget.dart';
import 'package:remixicon/remixicon.dart';
import '../../../config/constant.dart';
import '../../../utils/widgets/custom_toast.dart';
import '../../address_list_page/bloc/get_address_list_bloc/get_address_list_bloc.dart';

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({super.key});

  @override
  State<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<dynamic> _locationSuggestions = [];
  bool _isSearching = false;
  bool _isLoadingCurrentLocation = false;
  String? _currentLocationAddress;
  LatLng? _currentLocation;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure latest addresses are available for quick access section
      context.read<GetAddressListBloc>().add(FetchUserAddressList());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
        if(mounted) {
          _showErrorSnackBar(AppLocalizations.of(context)!.enableLocation);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
        if(mounted) {
          _showErrorSnackBar(AppLocalizations.of(context)!.permissionDenied);
        }
        return;
      }

      // Resilient fetch: try fresh GPS first with a generous timeout, and
      // fall back to the last-known position if the GPS cold-start times out
      // (common indoors / weak signal). Either way we return SOMETHING so the
      // user isn't left staring at a broken button.
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            timeLimit: Duration(seconds: 25),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
        if (position == null) rethrow;
      }

      _currentLocation = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentLocationAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      } else {
        _currentLocationAddress = "Current Location";
      }

      setState(() {
        _isLoadingCurrentLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
      _showErrorSnackBar('Failed to get current location');
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _locationSuggestions.clear();
    });

    try {
      final dio = Dio();

      final response = await dio.post(
        'https://places.googleapis.com/v1/places:autocomplete',
        data: {
          'input': query,
          "includeQueryPredictions": true,
          if(AppHelpers.countryValidationEnable)
            "locationRestriction": {
              "includedRegionCodes": AppHelpers.allowedCountries
            }
        },
        options: Options(
          headers: {
            'X-Goog-Api-Key': Platform.isAndroid
                ? AppConstant.androidMapKey
                : AppConstant.iosMapKey,
            'X-Goog-FieldMask': 'suggestions.placePrediction.text,suggestions.placePrediction.placeId,suggestions.placePrediction.structuredFormat',
            'Content-Type': 'application/json',
            if (Platform.isIOS)
              'X-IOS-Bundle-Identifier': AppConstant.packageName,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        final rawSuggestions = data['suggestions'] as List<dynamic>? ?? [];

        final List<LocationSuggestion> parsedSuggestions = [];

        for (final item in rawSuggestions) {
          final pred = item['placePrediction'] as Map<String, dynamic>?;
          if (pred == null) continue;

          final textMap = pred['text'] as Map<String, dynamic>?;
          final fullText = textMap?['text'] as String? ?? '';

          // Better: use structuredFormat when available (more reliable for main + secondary)
          final structured = pred['structuredFormat'] as Map<String, dynamic>?;
          final mainText = structured?['mainText']?['text'] as String? ?? '';
          final secondaryText = structured?['secondaryText']?['text'] as String? ?? '';

          final display = mainText.isNotEmpty ? mainText : fullText;
          final address = secondaryText.isNotEmpty
              ? '$mainText, $secondaryText'
              : fullText;

          parsedSuggestions.add(LocationSuggestion(
            placeId: pred['placeId'] as String?,
            displayName: display,
            address: address,
            latLng: const LatLng(0, 0),
          ));
        }

        setState(() {
          _locationSuggestions = parsedSuggestions;
          _isSearching = false;
        });
      }
    } catch (e) {
      log('No Result Found ${e.toString()}');
      setState(() {
        _isSearching = false;
      });
      _showErrorSnackBar('No result found');
    }
  }

  Future<void> _getPlaceDetails(String placeId, String fallbackAddress) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final dio = Dio();

      final response = await dio.get(
        'https://places.googleapis.com/v1/places/$placeId',  // ← modern endpoint + placeId in path
        options: Options(
          headers: {
            'X-Goog-Api-Key': Platform.isAndroid
                ? AppConstant.androidMapKey
                : AppConstant.iosMapKey,
            'X-Goog-FieldMask': 'location,formattedAddress',  // only request what you need
            'Content-Type': 'application/json',
            // Optional: 'Referer': 'com.aasyou.user',  // usually not required for server-side calls
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // In Places API (New), there's no "status" field like legacy → success = 200 + data present
        final locationMap = data['location'] as Map<String, dynamic>?;
        final formattedAddress = data['formattedAddress'] as String? ?? fallbackAddress;

        if (locationMap != null) {
          final double latitude = (locationMap['latitude'] as num?)?.toDouble() ?? 0.0;
          final double longitude = (locationMap['longitude'] as num?)?.toDouble() ?? 0.0;

          setState(() {
            _isSearching = false;
          });

          _selectLocation(latitude, longitude, formattedAddress);
        } else {
          setState(() {
            _isSearching = false;
          });
          _showErrorSnackBar('Location data not available');
        }
      } else {
        setState(() {
          _isSearching = false;
        });
        _showErrorSnackBar('Failed to fetch location details (HTTP ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      log('Place details error: $e');
      _showErrorSnackBar('Error fetching details: $e');
    }
  }

  void _selectLocation(double latitude, double longitude, String address) {
    Navigator.of(context).pop();

    GoRouter.of(context).push(
      AppRoutes.locationPicker,
      extra: {
        'lat': latitude,
        'lng': longitude,
        'address': address,
        'isFromAddressPage': false,
        'isEdit': false
      },
    );
  }

  void _useCurrentLocation() {
    if (_currentLocation != null && _currentLocationAddress != null) {
      _selectLocation(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _currentLocationAddress!,
      );
    }
  }

  /// User-tap handler — always fetch fresh location (the init-time fetch
  /// may have timed out / been denied / not yet completed). After fetch
  /// succeeds, use the resolved address.
  Future<void> _handleUseCurrentLocationTap() async {
    if (_isLoadingCurrentLocation) return; // prevent double-fire while fetching
    await _getCurrentLocation();
    if (!mounted) return;
    if (_currentLocation != null && _currentLocationAddress != null) {
      _useCurrentLocation();
    }
  }

  void _showErrorSnackBar(String message) {
    ToastManager.show(
        context: context,
        message: message,
        type: ToastType.error
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 300),
          child: Container(
            decoration: BoxDecoration(
              // color: Color(0XFFedf4fa),
              color: isDarkMode(context) ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchSection(),
                const SizedBox(height: 12,),

                if(AppHelpers.isDemo)
                  demoModeLocationNote(),
                const SizedBox(height: 12,),

                // Scrollable content:
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_searchController.text.isNotEmpty && _locationSuggestions.isNotEmpty)
                          _buildSearchResults()
                        else
                          _buildCurrentLocationSection(),

                        const SizedBox(height: 12),
                        const SavedAddressListWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context)!.selectDeliveryLocation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDarkMode(context) ? Theme.of(context).colorScheme.onSecondary : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            cursorColor: Theme.of(context).colorScheme.tertiary,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchForAreaStreet,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
              fillColor: Colors.white,
              prefixIcon: Container(
                padding: const EdgeInsets.all(14),
                child: const Icon(
                  RemixIcons.search_line,
                  size: 22,
                ),
              ),
              suffixIcon: _isSearching
                  ? const Padding(
                padding: EdgeInsets.all(14.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              )
                  : _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[700],
                    size: 16,
                  ),
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _locationSuggestions.clear();
                  });
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none
              ),
            ),
            onChanged: (value) {
              if (value.length > 2) {
                _searchPlaces(value);
              } else {
                setState(() {
                  _locationSuggestions.clear();
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget demoModeLocationNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Container(
        width: double.infinity,
        color: Colors.red.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
        child: Text(
          AppHelpers.demoModeLocationMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.red
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 15
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode(context) ? Theme.of(context).colorScheme.onSecondary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _locationSuggestions.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey[100],
          ),
          itemBuilder: (context, index) {
            final suggestion = _locationSuggestions[index];
            return InkWell(
              onTap: () {
                if (suggestion.placeId != null) {
                  _getPlaceDetails(suggestion.placeId!, suggestion.address);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        TablerIcons.map_pin,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentLocationSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 2
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _isLoadingCurrentLocation
                  ? null
                  : _handleUseCurrentLocationTap,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  color: isDarkMode(context) ? Theme.of(context).colorScheme.onSecondary : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      TablerIcons.focus_2,
                      color: AppTheme.primaryColor,
                      size: 25,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.useCurrentLocation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _isLoadingCurrentLocation
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor),
                            ),
                          )
                        : const Icon(
                            TablerIcons.chevron_right,
                            size: 22,
                            color: Colors.grey,
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: double.infinity,
              height: 2,
            ),
            if(Global.userData != null)
              InkWell(
              onTap: (){
                GoRouter.of(context).push(
                  AppRoutes.locationPicker,
                  extra: {
                    'isFromAddressPage': true,
                    'isEdit': false
                  },
                );
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  color: isDarkMode(context) ? Theme.of(context).colorScheme.onSecondary : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      TablerIcons.plus,
                      color: AppTheme.primaryColor,
                      size: 25,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.addNewAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      TablerIcons.chevron_right,
                      size: 22,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationSuggestion {
  final LatLng? latLng;
  final String address;
  final String displayName;
  final String? placeId;

  LocationSuggestion({
    this.latLng,
    required this.address,
    required this.displayName,
    this.placeId,
  });
}