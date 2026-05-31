import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class ConnectivityService with WidgetsBindingObserver {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            headers: {
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
            },
          ),
        );

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final Dio _dio;

  bool _isConnected = true;
  bool _isInitialized = false;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<bool> get onConnectionChanged =>
      _connectionController.stream.distinct();

  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    log('INITIALIZING CONNECTIVITY SERVICE');
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    // Register as observer for lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Listen to real-time changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      log('Connectivity changed triggered: $results');
      final normalized = _normalizeResults(results);

      // If we see a connection, we emit immediately for responsiveness
      if (normalized.any((r) => r != ConnectivityResult.none)) {
        await refreshStatus();
      } else {
        // If it's a "none" result, we wait a bit to avoid transient false positives (like on app resume)
        Future.delayed(const Duration(milliseconds: 1000), () async {
          await refreshStatus();
        });
      }
    });

    final initialResults = await _connectivity.checkConnectivity();
    _isConnected = await _hasInternetAccess(_normalizeResults(initialResults));
    _connectionController.add(_isConnected);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log('APP RESUMED: Refreshing connectivity with stabilization delay');
      // Give the OS a moment to stabilize the network interface after unlock/resume
      Future.delayed(const Duration(milliseconds: 500), () {
        refreshStatus();
      });
    }
  }

  Future<bool> refreshStatus({bool emitChanges = true}) async {
    if (!_isInitialized) {
      await initialize();
    }

    final currentResults = await _connectivity.checkConnectivity();
    final hasAccess =
        await _hasInternetAccess(_normalizeResults(currentResults));

    if (emitChanges && _isConnected != hasAccess) {
      _isConnected = hasAccess;
      _connectionController.add(_isConnected);
    } else {
      _isConnected = hasAccess;
    }

    return hasAccess;
  }

  List<ConnectivityResult> _normalizeResults(dynamic value) {
    if (value is ConnectivityResult) {
      return [value];
    }
    if (value is List<ConnectivityResult>) {
      return value;
    }
    return const [];
  }

  Future<bool> _hasInternetAccess(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return false;
    }

    // List of reliable endpoints to check
    final endpoints = [
      'https://www.google.com/generate_204',
      'https://www.cloudflare.com/cdn-cgi/trace',
      'https://www.apple.com/library/test/success.html',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await _dio.get(
          endpoint,
          options: Options(
            followRedirects: false,
            responseType: ResponseType.plain,
            receiveDataWhenStatusError: false,
            validateStatus: (status) => status != null && status < 599,
          ),
        );
        if (response.statusCode == 204 || response.statusCode == 200) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _connectionController.close();
  }
}
