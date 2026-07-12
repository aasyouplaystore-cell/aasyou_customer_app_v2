
import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:aasyou/bloc/theme_bloc/theme_bloc.dart';
import 'package:aasyou/bloc/language_bloc/language_bloc.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/widgets/cart_state_listener.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'utils/theme_switcher_provider.dart';
import 'app/app_bloc_observer.dart';
import 'app/app_bootstrap.dart';
import 'app/app_startup_listener.dart';
import 'config/dependency_injection_container.dart';
import 'config/global_bloc_providers.dart';
import 'config/theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  await runZonedGuarded(() async {
    await AppBootstrap.initialize();
    setupLocator();
    Bloc.observer = AppBlocObserver();
    runApp(const MyApp());
  }, (error, stackTrace) {
    debugPrintStack(stackTrace: stackTrace);
    // Uncaught async errors land in the zone handler, not
    // PlatformDispatcher.onError — forward them to Crashlytics too. Guarded:
    // an error BEFORE Firebase.initializeApp completes must not crash the
    // crash-reporter.
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStartupListener(
      child: MultiBlocProvider(
        providers: globalBlocProviders(),
        child: const CartStateListener(
          child: _AnimatedThemeWrapper(),
        ),
      ),
    );
  }
}

class _AnimatedThemeWrapper extends StatelessWidget {
  const _AnimatedThemeWrapper();

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher.switcher(
      builder: (context, switcher) {
        return ThemeSwitcherProvider(
          changeTheme: (theme) => switcher.changeTheme(theme: theme),
          child: BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, languageState) {
                  return GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: ScreenUtilInit(
                      child: SafeArea(
                        top: false,
                        bottom: Platform.isIOS ? false : true,
                        left: false,
                        right: false,
                        child: MaterialApp.router(
                          debugShowCheckedModeBanner: false,
                          theme: AppTheme.lightTheme,
                          darkTheme: AppTheme.darkTheme,
                          themeMode: themeMode,
                          builder: FToastBuilder(),
                          routerConfig: MyAppRoute.router,
                          localizationsDelegates:
                              AppLocalizations.localizationsDelegates,
                          supportedLocales: AppLocalizations.supportedLocales,
                          locale: languageState is LanguageLoaded
                              ? languageState.locale
                              : const Locale('en'),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}