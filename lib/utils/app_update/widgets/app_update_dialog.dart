import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/update_config.dart';

class AppUpdateDialog extends StatelessWidget {
  final UpdateConfig config;
  final bool isForced;
  final VoidCallback onLater;

  const AppUpdateDialog({
    super.key,
    required this.config,
    required this.isForced,
    required this.onLater,
  });

  Future<void> _launchStore() async {
    final url = Platform.isAndroid ? config.androidStoreUrl : config.iosStoreUrl;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.system_update,
                size: 72,
                color: isForced ? AppTheme.primaryColor : Colors.blueAccent,
              ),
              const SizedBox(height: 20),
              Text(
                config.title.isNotEmpty
                    ? config.title
                    : localizations.updateAvailable,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                config.message.isNotEmpty
                    ? config.message
                    : localizations.forceUpdateDialogMessage,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  if (!isForced) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onLater,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          localizations.doItLater,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: CustomButton(
                      onPressed: _launchStore,
                      child: Text(
                        localizations.update,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
