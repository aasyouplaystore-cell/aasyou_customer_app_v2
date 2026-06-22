import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/settings/web_settings/bloc/web_settings_bloc.dart';
import 'package:aasyou/screens/settings/web_settings/bloc/web_settings_state.dart';

/// Conditionally renders [child] based on a backend-driven visibility flag
/// from `WebSettingsBloc` (the `data.value` payload of `/api/settings/web`).
///
/// - When the flag is enabled (or unknown / not yet loaded), the [child]
///   is shown. This matches the backend contract: every flag defaults to
///   `true`, and a missing key is treated as `true`.
/// - When the flag is explicitly `false`, an empty [SizedBox.shrink] is
///   returned so the section collapses cleanly in any layout.
class WebSettingsGate extends StatelessWidget {
  const WebSettingsGate({
    super.key,
    required this.flagKey,
    required this.child,
  });

  /// The camelCase flag key from `WebSettings` (e.g.
  /// `WebSettings.kHomeTopRatedSection`).
  final String flagKey;

  /// Widget to render when the flag resolves to `true`.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSettingsBloc, WebSettingsState>(
      builder: (context, state) {
        final enabled = state.settings.isEnabled(flagKey);
        if (!enabled) return const SizedBox.shrink();
        return child;
      },
    );
  }
}
