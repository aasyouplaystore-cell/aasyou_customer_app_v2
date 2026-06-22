import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/router/app_routes.dart';

/// Thin shell route used by deep-links and the legacy `/login` path.
///
/// The 2.0 redesign collapsed "show a Continue-with-Phone CTA on /login
/// then push /mobile-otp-login" into a single step — the actual OTP entry
/// lives in [AppRoutes.mobileOtpLoginPage]. This widget just forwards
/// callers there in `initState`, preserving every old GoRouter.push(login)
/// without changing the routing graph.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      GoRouter.of(context).pushReplacement(
        AppRoutes.mobileOtpLoginPage,
        extra: {
          'isDirectLogin': true,
          'isUpdate': false,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Brief blank frame while the post-frame callback above fires the
    // replacement push. Keeping it the brand orange so the transition
    // matches the OTP page's header colour and looks intentional.
    return const Scaffold(
      backgroundColor: Color(0xFFFF6A1F),
      body: SizedBox.shrink(),
    );
  }
}
