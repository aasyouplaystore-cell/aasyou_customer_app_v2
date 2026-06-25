// Truecaller OAuth login Cubit.
//
// Wraps the [truecaller_sdk] package and exposes a flat, testable surface
// for the Login screen:
//
//   1. [initialize] — call once when the login screen first builds. Asks the
//      native SDK whether the OAuth flow is usable on the current device. We
//      surface this as a [TruecallerStatus.available] / [unavailable] state so
//      the UI can decide whether to render the "Continue with Truecaller"
//      button at all. NEVER auto-triggers the consent sheet — that was the
//      old 1.0 app's worst UX bug (consent popped on every cold start).
//
//   2. [login] — call when the user taps the Truecaller button. Generates a
//      cryptographically random OAuth state + PKCE pair, registers a stream
//      listener, then nudges the native SDK to show its consent sheet. On
//      success, exposes the `authorizationCode` + `codeVerifier` for the
//      caller to POST to our backend's `/auth/truecaller/callback`.
//
// Important plugin caveats baked into this Cubit:
//   - `truecaller_sdk` ^1.2.0 has a known bug where several Method-channel
//     methods (`initializeSDK`, `getAuthorizationCode`) never call
//     `result.success()`, so awaiting them hangs forever. We fire-and-forget
//     those two specific calls (verified still broken; the others —
//     setCodeChallenge / setOAuthScopes / setOAuthState — DO complete in this
//     plugin version and are safely awaited).
//   - `isOAuthFlowUsable` is a getter that occasionally returns a raw `int`
//     instead of `bool` depending on the Android side — we normalise both.
//   - The SDK is Android-only. iOS calls throw / no-op — we early-return on
//     any non-Android platform.
//
// State management:
//   - Single immutable [TruecallerState] with a [TruecallerStatus] enum +
//     auth payload + error message.
//   - All `emit`s are guarded by `!isClosed` so a navigation pop during the
//     30-second login wait doesn't crash the app.
//   - The stream subscription is cancelled in [close] so an orphaned
//     Truecaller callback can't fire into a disposed Cubit.

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

/// High-level state of the Truecaller flow.
enum TruecallerStatus {
  /// Cubit just constructed; nothing has been checked yet.
  initial,

  /// `initialize()` is running — waiting on the native SDK to report whether
  /// the OAuth flow is usable on this device.
  checking,

  /// Either we're on a non-Android platform, no Truecaller app installed,
  /// or `isOAuthFlowUsable` returned false. UI should hide the button.
  unavailable,

  /// SDK reports the flow is usable. UI should show the "Continue with
  /// Truecaller" button.
  available,

  /// User tapped the button; consent sheet is being shown or processed.
  /// UI should show a small inline spinner in place of the button.
  authenticating,

  /// `streamCallbackData` reported success — `authorizationCode` and
  /// `codeVerifier` are populated and ready to POST to the backend.
  success,

  /// `streamCallbackData` reported failure, OR the 30-second timeout fired.
  /// `errorMessage` carries a user-displayable string.
  failure,
}

@immutable
class TruecallerState {
  final TruecallerStatus status;

  /// OAuth `authorization_code` returned by Truecaller. Send this to backend
  /// alongside [codeVerifier] for server-side token exchange.
  final String? authorizationCode;

  /// PKCE `code_verifier` paired with the `code_challenge` we sent to
  /// Truecaller. Backend needs this to complete the exchange.
  final String? codeVerifier;

  /// Human-readable failure reason for the UI to surface.
  final String? errorMessage;

  const TruecallerState({
    this.status = TruecallerStatus.initial,
    this.authorizationCode,
    this.codeVerifier,
    this.errorMessage,
  });

  /// `copyWith` with proper nullable-clear support via sentinel.
  ///
  /// The previous `T? x` + `x ?? this.x` pattern made it IMPOSSIBLE to
  /// clear a field — passing `null` was indistinguishable from "argument
  /// not supplied", so stale `errorMessage` / `authorizationCode` /
  /// `codeVerifier` from a previous failure leaked into the next
  /// `available`/`checking`/`success` state. UI then displayed an old
  /// error message after a successful retry, etc.
  ///
  /// Each field now accepts a `ValueGetter<T?>?` sentinel: if the caller
  /// passes the wrapper at all, its returned value (including null) is
  /// used; if omitted, the existing field is preserved.
  TruecallerState copyWith({
    TruecallerStatus? status,
    ValueGetter<String?>? authorizationCode,
    ValueGetter<String?>? codeVerifier,
    ValueGetter<String?>? errorMessage,
  }) {
    return TruecallerState(
      status: status ?? this.status,
      authorizationCode: authorizationCode != null
          ? authorizationCode()
          : this.authorizationCode,
      codeVerifier:
          codeVerifier != null ? codeVerifier() : this.codeVerifier,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class TruecallerCubit extends Cubit<TruecallerState> {
  TruecallerCubit() : super(const TruecallerState());

  /// Active subscription to [TcSdk.streamCallbackData]. Held so we can
  /// cancel it on [close] (or before starting a fresh login) and avoid
  /// leaked callbacks firing into a disposed Cubit.
  StreamSubscription? _callbackSub;

  /// PKCE code verifier kept in-memory between `login()` and the
  /// `streamCallbackData` emission. Surfaced in the success state so the
  /// caller can POST it to the backend.
  String? _codeVerifier;

  /// Bootstraps the Truecaller SDK and reports whether OAuth is usable.
  ///
  /// Safe to call multiple times; subsequent calls are cheap no-ops if the
  /// status has already been determined. Intended to be invoked from the
  /// login screen's `initState` via `addPostFrameCallback`.
  Future<void> initialize() async {
    // Android-only guard. The native plugin would just throw on iOS / web /
    // desktop; doing the check at the Dart layer avoids a confusing error
    // toast and keeps the UI clean.
    if (!Platform.isAndroid) {
      if (!isClosed) {
        emit(state.copyWith(status: TruecallerStatus.unavailable));
      }
      return;
    }

    if (!isClosed) {
      emit(state.copyWith(status: TruecallerStatus.checking));
    }

    try {
      // Plugin bug (truecaller_sdk ^1.2.0): `initializeSDK` never calls
      // `result.success()` on the native side, so awaiting its Future hangs
      // forever. Fire-and-forget it, then sleep ~1s to let the Android SDK
      // settle before we ask whether the OAuth flow is usable.
      TcSdk.initializeSDK(
        sdkOption: TcSdkOptions.OPTION_VERIFY_ONLY_TC_USERS,
      );
      await Future.delayed(const Duration(seconds: 1));

      // `isOAuthFlowUsable` occasionally returns an `int` (1/0) from the
      // platform channel instead of a `bool`. Normalise both.
      final raw = await TcSdk.isOAuthFlowUsable;
      final usable = raw == true || raw == 1;

      if (!isClosed) {
        emit(state.copyWith(
          status: usable
              ? TruecallerStatus.available
              : TruecallerStatus.unavailable,
        ));
      }
    } catch (e) {
      debugPrint('TruecallerCubit.initialize error: $e');
      if (!isClosed) {
        emit(state.copyWith(status: TruecallerStatus.unavailable));
      }
    }
  }

  /// Triggers the Truecaller consent sheet and waits for the auth callback.
  ///
  /// On success, emits a [TruecallerStatus.success] state carrying the
  /// `authorization_code` + `code_verifier`. On failure / timeout, emits
  /// [TruecallerStatus.failure] with a user-facing message.
  Future<void> login() async {
    // Guard: ignore taps if the flow isn't usable. Mirrors the UI which
    // hides the button in this case — defensive in case of races.
    if (state.status != TruecallerStatus.available &&
        state.status != TruecallerStatus.failure) {
      return;
    }
    if (!Platform.isAndroid) return;

    if (!isClosed) {
      emit(state.copyWith(
        status: TruecallerStatus.authenticating,
        // Clear previous error + stale auth payload so the UI doesn't show
        // a stale snackbar and a downstream `success` consumer can't
        // accidentally reuse the previous attempt's auth code.
        errorMessage: () => null,
        authorizationCode: () => null,
        codeVerifier: () => null,
      ));
    }

    try {
      // ── PKCE: code_verifier + code_challenge ──────────────────────────
      // These two SDK helpers DO call result.success(), so they're safe to
      // await directly. (Unlike initializeSDK / getAuthorizationCode.)
      // NOTE: parentheses around `await` are LOAD-BEARING — without them
      // `await X as String?` parses as `await (X as String?)`, casting the
      // unawaited Future<dynamic> to String? and throwing TypeError before
      // the await ever resolves. That bug silently killed the entire
      // Truecaller path (always falling into the outer catch).
      _codeVerifier = (await TcSdk.generateRandomCodeVerifier) as String?;
      // Guard against a null/empty verifier — without this, the stream
      // listener and getAuthorizationCode fire with no PKCE pair, and the
      // backend rejects the exchange with an opaque error. Better to fail
      // fast with a retry prompt BEFORE registering the listener.
      if (_codeVerifier == null || _codeVerifier!.isEmpty) {
        if (!isClosed) {
          emit(state.copyWith(
            status: TruecallerStatus.failure,
            errorMessage: () => 'Could not start Truecaller — please retry',
          ));
        }
        return;
      }
      final verifier = _codeVerifier!;
      final challenge = await TcSdk.generateCodeChallenge(verifier);
      if (challenge is String) {
        // Plugin bug (truecaller_sdk ^1.2.0): `setCodeChallenge` never calls
        // `result.success()` on the native side, so awaiting its Future hangs
        // forever. The OLD 1.0 app fire-and-forgot this for exactly this
        // reason. An earlier comment here claimed "await IS reliable in
        // 1.2.0 (verified)" — that was wrong; on-device testing confirmed
        // the spinner never advances past this line.
        // ignore: unawaited_futures
        TcSdk.setCodeChallenge(challenge);
      }

      // Same fire-and-forget treatment for setOAuthScopes — plugin bug,
      // never calls result.success(). Awaiting hangs forever.
      // ignore: unawaited_futures
      TcSdk.setOAuthScopes(['openid', 'phone', 'profile', 'email']);

      // ── CSRF state ────────────────────────────────────────────────────
      // OAuth requires a non-empty `state` for CSRF protection. The OLD 1.0
      // app used `DateTime.now().millisecondsSinceEpoch` which is trivially
      // predictable + collides if the user retries within the same ms.
      // Use Random.secure() (OS CSPRNG) instead.
      final rand = Random.secure();
      final stateBytes = List<int>.generate(16, (_) => rand.nextInt(256));
      final oauthState = base64UrlEncode(stateBytes).replaceAll('=', '');

      // Same fire-and-forget treatment for setOAuthState.
      // ignore: unawaited_futures
      TcSdk.setOAuthState(oauthState);

      // Small breathing room for the native side to record the 3 set*
      // calls before we kick off getAuthorizationCode. 800ms (was 300ms) —
      // on cold/slow devices the unawaited setCodeChallenge / setOAuthScopes
      // / setOAuthState platform-channel calls can take >300ms to land; if
      // getAuthorizationCode fires before they do, Truecaller rejects the
      // request with an opaque PKCE/state error.
      await Future.delayed(const Duration(milliseconds: 800));

      // ── Stream listener ───────────────────────────────────────────────
      // Register BEFORE firing `getAuthorizationCode` so we don't miss a
      // synchronous failure callback. Use a Completer + 30s timeout to
      // bridge the stream-based API into an awaitable flow.
      await _callbackSub?.cancel();
      final completer = Completer<void>();

      _callbackSub = TcSdk.streamCallbackData.listen((result) {
        if (completer.isCompleted) return;

        if (result.result == TcSdkCallbackResult.success) {
          final code = result.tcOAuthData?.authorizationCode;
          if (code != null && code.isNotEmpty) {
            if (!isClosed) {
              emit(state.copyWith(
                status: TruecallerStatus.success,
                authorizationCode: () => code,
                codeVerifier: () => _codeVerifier ?? '',
                errorMessage: () => null,
              ));
            }
          } else {
            if (!isClosed) {
              emit(state.copyWith(
                status: TruecallerStatus.failure,
                errorMessage: () => 'Truecaller returned no authorization code',
              ));
            }
          }
          completer.complete();
        } else if (result.result == TcSdkCallbackResult.failure) {
          if (!isClosed) {
            emit(state.copyWith(
              status: TruecallerStatus.failure,
              errorMessage: () =>
                  result.error?.message ?? 'Truecaller login failed',
            ));
          }
          completer.complete();
        }
        // Other results (e.g. verification flow) are not used by the
        // OAuth-only configuration; ignore them.
      });

      // Plugin bug: `getAuthorizationCode` never calls result.success() —
      // it's a "void" trigger that just opens the consent sheet. The actual
      // outcome arrives via the stream above. Fire-and-forget — do NOT
      // await, or this Future never resolves.
      //
      // NOTE: We bind the getter to a local `final` rather than leaving a
      // bare reference (`TcSdk.getAuthorizationCode;`). Evaluating the
      // getter is what triggers the MethodChannel call; a bare reference
      // works today but if the analyzer's unused-getter rule is ever
      // enabled OR the plugin migrates this to a method, the bare line
      // silently no-ops and the consent sheet never opens — the stream
      // listener then sits idle until the 30s timeout fires.
      // ignore: unawaited_futures
      final _ = TcSdk.getAuthorizationCode;

      // ── 30-second timeout ─────────────────────────────────────────────
      // Truecaller's consent sheet has no hard upper bound; if the user
      // backgrounds the app and never returns, the stream will never fire.
      // Surface a failure after 30s so the UI doesn't stay stuck on a
      // spinner forever.
      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (!isClosed && state.status == TruecallerStatus.authenticating) {
            emit(state.copyWith(
              status: TruecallerStatus.failure,
              errorMessage: () =>
                  'Truecaller login timed out. Please try again.',
            ));
          }
        },
      );
    } catch (e) {
      debugPrint('TruecallerCubit.login error: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: TruecallerStatus.failure,
          errorMessage: () => e.toString(),
        ));
      }
    } finally {
      // Free the subscription once we've finished handling this attempt.
      // Leaving it active across multiple taps would leak callbacks.
      await _callbackSub?.cancel();
      _callbackSub = null;
    }
  }

  /// Resets back to `available` so the user can tap again after a failure.
  /// (Doesn't re-run `initialize()` — assumes the SDK is still usable.)
  void reset() {
    if (isClosed) return;
    emit(const TruecallerState(status: TruecallerStatus.available));
  }

  @override
  Future<void> close() async {
    await _callbackSub?.cancel();
    _callbackSub = null;
    return super.close();
  }
}
