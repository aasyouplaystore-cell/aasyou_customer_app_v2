import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repo/order_repo.dart';

// ---------------------------------------------------------------------------
// JSON helpers (file-private, top-level so the
// `no_leading_underscores_for_local_identifiers` lint does not apply).
//
// Prefixed with `_pickupOtp` so that other DTOs in this directory subtree
// can add their own helpers later without collision.
// ---------------------------------------------------------------------------

double? _pickupOtpToDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

String? _pickupOtpToStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

// ---------------------------------------------------------------------------
// DTO
// ---------------------------------------------------------------------------

/// Payload returned by GET /api/user/orders/{slug}/pickup-otp.
///
/// The widget (pickup_otp_card.dart) reads only the fields below — there is
/// no `mapsUrl` (the widget builds the maps deep-link inline at its line 243
/// from storeLatitude/storeLongitude) and no `pickupReadyAt`.
///
/// IMPORTANT: pickup_otp_card.dart currently declares its OWN local copy of
/// this class at lines 37-72. The companion widget patch in this series
/// MUST remove that duplicate (and the sibling `toDouble`/`toStr` helpers
/// at lines 76-86) so the widget picks up this canonical type via its
/// existing `import '.../pickup_otp/pickup_otp_bloc.dart';` at line 30.
/// Until that companion patch lands, the widget library will fail to
/// compile with a `name defined in two libraries` diagnostic.
class PickupOtpData extends Equatable {
  const PickupOtpData({
    required this.otp,
    this.storeName,
    this.storeAddress,
    this.storePhone,
    this.storeLatitude,
    this.storeLongitude,
    this.pickupInstructions,
  });

  final String otp;
  final String? storeName;
  final String? storeAddress;
  final String? storePhone;
  final double? storeLatitude;
  final double? storeLongitude;
  final String? pickupInstructions;

  factory PickupOtpData.fromJson(Map<String, dynamic> json) {
    // Tolerate a `{ data: {...} }` envelope as well as a flat root.
    final Map<String, dynamic> src =
        (json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    // Mirror pickup_otp_card.dart's own fromJson (line 63) exactly:
    //  * EMPTY `pickup_otp` falls through to `otp` (because _pickupOtpToStr
    //    collapses empty strings to null).
    //  * Whitespace is trimmed (via _pickupOtpToStr's inner .trim() AND the
    //    outer .trim() — the outer one matters only if backend returns
    //    e.g. " 1234 " as `otp`; the helper already trims that, but the
    //    explicit outer trim documents intent and matches widget code).
    return PickupOtpData(
      otp: (_pickupOtpToStr(src['pickup_otp']) ??
              _pickupOtpToStr(src['otp']) ??
              '')
          .trim(),
      storeName: _pickupOtpToStr(src['store_name']),
      storeAddress: _pickupOtpToStr(src['store_address']),
      storePhone: _pickupOtpToStr(src['store_phone']),
      storeLatitude: _pickupOtpToDouble(src['store_latitude']),
      storeLongitude: _pickupOtpToDouble(src['store_longitude']),
      pickupInstructions: _pickupOtpToStr(src['pickup_instructions']),
    );
  }

  @override
  List<Object?> get props => [
        otp,
        storeName,
        storeAddress,
        storePhone,
        storeLatitude,
        storeLongitude,
        pickupInstructions,
      ];
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class PickupOtpEvent extends Equatable {
  const PickupOtpEvent();

  @override
  List<Object?> get props => const [];
}

class FetchPickupOtp extends PickupOtpEvent {
  const FetchPickupOtp({required this.orderSlug});

  final String orderSlug;

  @override
  List<Object?> get props => [orderSlug];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class PickupOtpState extends Equatable {
  const PickupOtpState();

  @override
  List<Object?> get props => const [];
}

class PickupOtpInitial extends PickupOtpState {
  const PickupOtpInitial();
}

class PickupOtpLoading extends PickupOtpState {
  const PickupOtpLoading();
}

class PickupOtpLoaded extends PickupOtpState {
  const PickupOtpLoaded({required this.data});

  final PickupOtpData data;

  @override
  List<Object?> get props => [data];
}

class PickupOtpFailed extends PickupOtpState {
  const PickupOtpFailed({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

class PickupOtpBloc extends Bloc<PickupOtpEvent, PickupOtpState> {
  PickupOtpBloc({OrderRepository? repository})
      : _repository = repository ?? OrderRepository(),
        super(const PickupOtpInitial()) {
    on<FetchPickupOtp>(_onFetchPickupOtp);
  }

  final OrderRepository _repository;

  Future<void> _onFetchPickupOtp(
    FetchPickupOtp event,
    Emitter<PickupOtpState> emit,
  ) async {
    emit(const PickupOtpLoading());
    try {
      // OrderRepository.fetchPickupOtp returns Map<String,dynamic> (the
      // backend's JSON envelope). Parse into the canonical DTO here so
      // PickupOtpLoaded carries a typed object.
      final json = await _repository.fetchPickupOtp(event.orderSlug);
      if (json.isEmpty) {
        emit(const PickupOtpFailed(message: 'Pickup OTP unavailable'));
        return;
      }
      emit(PickupOtpLoaded(data: PickupOtpData.fromJson(json)));
    } catch (e) {
      emit(PickupOtpFailed(message: e.toString()));
    }
  }
}
