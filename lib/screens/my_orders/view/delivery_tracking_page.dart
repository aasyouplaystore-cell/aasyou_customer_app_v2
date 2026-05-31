import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/my_orders/bloc/delivery_tracking/delivery_tracking_bloc.dart';
import 'package:aasyou/screens/my_orders/model/delivery_tracking_model.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_shimmer.dart';
import '../utils/tracking_route_manager.dart';
import '../widgets/delivery_details_section.dart';
import '../widgets/delivery_partner_not_assigned.dart';
import '../widgets/delivery_partner_section.dart';
import '../widgets/delivery_success_card.dart';
import '../widgets/order_details_section.dart';
import '../widgets/order_summary_widget.dart';
import '../widgets/tracking_map_widget.dart';

class DeliveryTrackingPage extends StatefulWidget {
  final String orderSlug;
  const DeliveryTrackingPage({super.key, required this.orderSlug});

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  Timer? _refreshTimer;
  final TrackingRouteManager _routeManager = TrackingRouteManager();
  final GlobalKey<TrackingMapWidgetState> _mapKey = GlobalKey();

  DeliveryBoyTrackingModel? _currentTracking;
  bool _isDelivered = false;
  bool _trackingUpdateInProgress = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 8));

    context.read<DeliveryTrackingBloc>().add(
      FetchDeliveryTracking(orderSlug: widget.orderSlug),
    );

    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        context.read<DeliveryTrackingBloc>().add(
          FetchDeliveryTracking(orderSlug: widget.orderSlug),
        );
      }
    });
  }

  void _onRefreshTap() {
    context.read<DeliveryTrackingBloc>().add(
      FetchDeliveryTracking(orderSlug: widget.orderSlug),
    );
  }

  Future<void> _onTrackingLoaded(DeliveryTrackingLoaded state) async {
    if (!mounted || _trackingUpdateInProgress) return;
    _trackingUpdateInProgress = true;
    try {
      setState(() => _currentTracking = state.tracking);
      await _mapKey.currentState?.processTrackingUpdate(state.tracking);
    } finally {
      _trackingUpdateInProgress = false;
    }
  }

  String _getStatusText(String? status) {
    final l10n = AppLocalizations.of(context)!;
    if (status == null || status.isEmpty) return l10n.trackingOrder;
    final result = status.replaceAll('_', ' ').replaceAll('-', ' ');
    if (result.isEmpty) return l10n.trackingOrder;
    return result[0].toUpperCase() + result.substring(1).toLowerCase();
  }

  String _getETAText() {
    final l10n = AppLocalizations.of(context)!;
    final eta = _currentTracking?.data?.order?.estimatedDeliveryTime;
    if (eta == null || eta == 0) return l10n.shortly;
    return '$eta ${l10n.minutesLabel}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDeliveredStatus =
        _isDelivered || _currentTracking?.data?.order?.status == 'delivered';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          isDeliveredStatus
              ? l10n.orderDelivered
              : _getStatusText(_currentTracking?.data?.order?.status),
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            TablerIcons.arrow_narrow_left,
            size: 30,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isDeliveredStatus
                    ? l10n.successfullyDelivered
                    : _currentTracking == null
                        ? l10n.loading
                        : '${l10n.arrivingIn} ${_getETAText()}',
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Material(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: isDeliveredStatus
                      ? _SuccessAnimation(
                          confettiController: _confettiController,
                        )
                      : TrackingMapWidget(
                          key: _mapKey,
                          routeManager: _routeManager,
                          tracking: _currentTracking,
                          onRefreshTap: _onRefreshTap,
                        ),
                ),
              ),
            ),
            BlocConsumer<DeliveryTrackingBloc, DeliveryTrackingState>(
              listener: (context, state) {
                if (state is DeliveryTrackingLoaded) {
                  if (state.tracking.data?.order?.status == 'delivered') {
                    if (!_isDelivered) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _isDelivered = true);
                          _confettiController.play();
                          _refreshTimer?.cancel();
                        }
                      });
                    }
                  }
                  if (!_trackingUpdateInProgress) _onTrackingLoaded(state);
                }
              },
              builder: (context, state) {
                final isFirstLoad =
                    _currentTracking == null && state is DeliveryTrackingLoading;
                if (isFirstLoad) return _buildLoadingShimmer();
                if (state is DeliveryTrackingFailed &&
                    _currentTracking == null) {
                  return _buildErrorView(state.error);
                }
                return _buildContentSections(state);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        for (final h in [100.0, 180.0, 120.0, 100.0])
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
            child: ShimmerWidget.rectangular(isBorder: true, height: h),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildErrorView(String errorMsg) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(TablerIcons.shopping_bag,
              size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(errorMsg,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          CustomButton(
            onPressed: _onRefreshTap,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSections(DeliveryTrackingState state) {
    final l10n = AppLocalizations.of(context)!;
    final tracking =
        (state is DeliveryTrackingLoaded) ? state.tracking : _currentTracking;

    if (tracking == null || tracking.data?.order == null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShimmerWidget.rectangular(
                height: 60, borderRadius: 12, isBorder: true),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShimmerWidget.rectangular(
                    height: [80, 140, 100, 120][index % 4].toDouble(),
                    isBorder: true,
                    borderRadius: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      );
    }

    final order = tracking.data!.order;
    final routeDetails = tracking.data?.route?.routeDetails ?? [];
    final deliveryBoys = tracking.data?.deliveryBoys ?? const [];

    final partnerName = order?.deliveryBoyName ??
        (deliveryBoys.isNotEmpty
            ? deliveryBoys.first.data?.deliveryBoy?.fullName
            : null) ??
        l10n.deliveryPartner;
    final partnerPhone = order?.deliveryBoyPhone?.toString();
    final deliveryPartnerProfile = order?.deliveryBoyProfile ?? '';

    final destTitle = order?.shippingAddressType ?? l10n.destinationLabel;
    final destSubtitle = [
      order?.shippingAddress1,
      order?.shippingLandmark,
      order?.shippingCity,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');

    final orderIdText = order?.id?.toString() ?? '';
    final paymentText = (order?.paymentStatus?.toLowerCase() == 'paid')
        ? '${l10n.paidLabel} ${order?.paymentMethod ?? ''}'.trim()
        : (order?.paymentMethod ?? '');
    final placedAtText = order?.createdAt ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isDelivered)
          const DeliverySuccessCard()
        else if (deliveryBoys.isEmpty)
          const DeliveryPartnerNotAssigned()
        else
          DeliveryPartnerSection(
            name: partnerName,
            phone: partnerPhone,
            deliveryBoyProfile: deliveryPartnerProfile,
          ),
        DeliveryDetailsSection(
          stops: routeDetails,
          destTitle: destTitle,
          destSubtitle: destSubtitle,
          isDelivered: _isDelivered,
        ),
        OrderSummaryWidget(orderData: order ?? TrackedOrder()),
        OrderDetailsSection(
          orderId: orderIdText,
          payment: paymentText,
          orderPlaced: paymentText,
          placedAt: placedAtText,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
}

class _SuccessAnimation extends StatelessWidget {
  final ConfettiController confettiController;
  const _SuccessAnimation({required this.confettiController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            createParticlePath: _drawStar,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.delivered,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.orderDeliveredSuccessfully,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ui.Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (math.pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = ui.Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(
          halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
