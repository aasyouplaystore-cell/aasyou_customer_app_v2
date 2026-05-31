import 'package:flutter/widgets.dart';
import 'package:aasyou/config/notification_service.dart';

class AppStartupListener extends StatefulWidget {
  const AppStartupListener({super.key, required this.child});

  final Widget child;

  @override
  State<AppStartupListener> createState() => _AppStartupListenerState();
}

class _AppStartupListenerState extends State<AppStartupListener> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStartupServices();
    });
  }

  Future<void> _initializeStartupServices() async {
    if (_initialized || !mounted) return;
    _initialized = true;
    await NotificationService().initFirebaseMessaging(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
