part of 'find_stores_bloc.dart';

abstract class FindStoresEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FindStoresRequest extends FindStoresEvent {
  final double neLat;
  final double neLng;
  final double swLat;
  final double swLng;
  final double userLat;
  final double userLng;

  FindStoresRequest({
    required this.neLat,
    required this.neLng,
    required this.swLat,
    required this.swLng,
    required this.userLat,
    required this.userLng,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [neLat, neLng, swLat, swLng, userLat, userLng];
}
