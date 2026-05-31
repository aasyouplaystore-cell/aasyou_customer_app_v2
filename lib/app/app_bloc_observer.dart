import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  // Triggered when a Bloc is loaded into memory
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('🟢 BLOC CREATED: ${bloc.runtimeType}');
  }

  // Triggered when a Bloc updates its state
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // Uncomment this if you want to trace state changes!
  }

  // Triggered when an error happens inside a Bloc
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('🔴 BLOC ERROR: ${bloc.runtimeType} -> $error');
    super.onError(bloc, error, stackTrace);
  }

  // Triggered when a Bloc is destroyed and removed from RAM
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('❌ BLOC CLOSED: ${bloc.runtimeType}');
  }
}