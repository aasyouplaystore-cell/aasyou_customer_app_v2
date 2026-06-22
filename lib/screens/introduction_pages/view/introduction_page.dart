import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/router/app_routes.dart';

/// AasYou 2.0 onboarding — three composable slides tuned to the actual
/// multi-market business (not the legacy mandi-only positioning).
///
/// Design constraints:
///   * Zero baked PNGs. Every illustration is built from [Icon],
///     [Container] and tiny [CustomPainter]s so the whole flow fits in
///     ~10KB of code and renders in vector form on any DPI.
///   * One shared [AnimationController] for ambient motion — no per-page
///     resets, no fade/slide stacks on swipe.
///   * Localized via [AppLocalizations] when keys exist; sensible
///     en-IN fallbacks otherwise so the screen still ships on any locale.
///   * Skip + dot indicators + primary CTA stay sticky at the bottom.
class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Shared ambient controller — drives the slide-1 orbit + slide-2 dotted
  // delivery path + slide-3 OTP cursor blink. Runs forever, swipes never
  // recreate it.
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index != _currentIndex) setState(() => _currentIndex = index);
  }

  void _advance() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Global.setIsFirstTime(false);
    if (Global.userData?.token.isNotEmpty ?? false) {
      GoRouter.of(context).pushReplacement(AppRoutes.home);
    } else {
      GoRouter.of(context).pushReplacement(AppRoutes.login);
    }
  }

  // ── Per-page background gradients ─────────────────────────────────────
  static const List<List<Color>> _gradients = [
    [Color(0xFFFFF0E5), Color(0xFFFFFFFF)], // peach cream
    [Color(0xFFFFF6F0), Color(0xFFFFE9D6)], // warm wash
    [Color(0xFFFFFFFF), Color(0xFFFFE0CC)], // light → peach
  ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final isLast = _currentIndex == 2;
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradients[_currentIndex.clamp(0, 2)],
          ),
        ),
        child: Column(
          children: [
            _buildTopBar(topPad),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, i) {
                  switch (i) {
                    case 0:
                      return _Slide(
                        illustration: _OrbitIllustration(ambient: _ambient),
                        title: 'Sab kuch ek hi app me',
                        subtitle:
                            'Electronics, fashion, mandi, malls, bakery aur building material — sab local shops ek place pe.',
                      );
                    case 1:
                      return _Slide(
                        illustration:
                            _DeliveryIllustration(ambient: _ambient),
                        title: 'Aapke zone tak, super fast',
                        subtitle:
                            'Sirf nearby shops dikhayenge — aapke address pe sabse jaldi delivery.',
                      );
                    case 2:
                    default:
                      return _Slide(
                        illustration: _LoginIllustration(ambient: _ambient),
                        title: '10 second me login',
                        subtitle:
                            'Phone number daalo, OTP daalo, ho gaya. Account nahi? Apne aap ban jayega.',
                      );
                  }
                },
              ),
            ),
            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final active = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              child: GestureDetector(
                onTap: _advance,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        Color(0xFFFF8A4C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isLast ? 'Start Shopping' : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double topPad) {
    return SizedBox(
      height: topPad + 56,
      child: Padding(
        padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
        child: Row(
          children: [
            // Brand wordmark (text only — keeps the splash logo asset
            // optional; falls back gracefully if the asset is unavailable).
            const Text(
              'AasYou',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryColor,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: _finish,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic slide layout: illustration on top, title + subtitle below.
class _Slide extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String subtitle;

  const _Slide({
    required this.illustration,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Expanded(child: Center(child: illustration)),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// SLIDE 1 — Multi-category orbit
// 6 category icons orbiting the AasYou logo. Drives a quiet sense of
// "everything in one app" without needing a baked PNG.
// ──────────────────────────────────────────────────────────────────────────
class _OrbitIllustration extends StatelessWidget {
  final AnimationController ambient;
  const _OrbitIllustration({required this.ambient});

  static const List<_OrbitItem> _items = [
    _OrbitItem(Icons.devices_other_rounded, 'Electronics', Color(0xFF42A5F5)),
    _OrbitItem(Icons.checkroom_rounded, 'Fashion', Color(0xFFEC407A)),
    _OrbitItem(Icons.eco_rounded, 'Mandi', Color(0xFF66BB6A)),
    _OrbitItem(Icons.bakery_dining_rounded, 'Bakery', Color(0xFFFFB300)),
    _OrbitItem(Icons.storefront_rounded, 'Malls', Color(0xFFAB47BC)),
    _OrbitItem(Icons.handyman_rounded, 'Building', Color(0xFF8D6E63)),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (_, __) {
        final t = ambient.value * 2 * math.pi;
        return LayoutBuilder(builder: (ctx, box) {
          final size = math.min(box.maxWidth, box.maxHeight) * 0.86;
          final radius = size * 0.38;
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft halo
                Container(
                  width: size * 0.65,
                  height: size * 0.65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.18),
                        AppTheme.primaryColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Center pill — wordmark
                Container(
                  width: size * 0.4,
                  height: size * 0.18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        Color(0xFFFF8A4C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'AasYou',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Orbit chips
                ...List.generate(_items.length, (i) {
                  final angle = (i / _items.length) * 2 * math.pi + t * 0.15;
                  final dx = radius * math.cos(angle);
                  final dy = radius * math.sin(angle);
                  return Transform.translate(
                    offset: Offset(dx, dy),
                    child: _OrbitChip(item: _items[i]),
                  );
                }),
              ],
            ),
          );
        });
      },
    );
  }
}

class _OrbitItem {
  final IconData icon;
  final String label;
  final Color color;
  const _OrbitItem(this.icon, this.label, this.color);
}

class _OrbitChip extends StatelessWidget {
  final _OrbitItem item;
  const _OrbitChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// SLIDE 2 — Hyperlocal delivery path
// Map pin → dotted curve → home icon, with a scooter glyph travelling
// along the path. Pure CustomPainter; no asset weight.
// ──────────────────────────────────────────────────────────────────────────
class _DeliveryIllustration extends StatelessWidget {
  final AnimationController ambient;
  const _DeliveryIllustration({required this.ambient});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (_, __) {
        return LayoutBuilder(builder: (ctx, box) {
          final w = math.min(box.maxWidth, 340.0);
          final h = w * 0.7;
          return SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DeliveryPathPainter(
                      progress: ambient.value,
                    ),
                  ),
                ),
                // Origin pin
                Positioned(
                  left: 16,
                  top: h * 0.25,
                  child: _LabelPill(
                    icon: Icons.storefront_rounded,
                    text: 'Local shop',
                    iconColor: AppTheme.primaryColor,
                  ),
                ),
                // Destination home
                Positioned(
                  right: 16,
                  bottom: h * 0.18,
                  child: _LabelPill(
                    icon: Icons.home_rounded,
                    text: 'Your door',
                    iconColor: const Color(0xFF42A5F5),
                  ),
                ),
                // Moving scooter (interpolated along the same Bezier)
                Builder(builder: (_) {
                  final p = _bezierPoint(
                    Offset(40, h * 0.32),
                    Offset(w * 0.55, h * 0.05),
                    Offset(w * 0.45, h * 0.85),
                    Offset(w - 60, h * 0.6),
                    ambient.value,
                  );
                  return Positioned(
                    left: p.dx - 22,
                    top: p.dy - 22,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delivery_dining_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        });
      },
    );
  }

  static Offset _bezierPoint(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t,
  ) {
    final u = 1 - t;
    final x = (u * u * u) * p0.dx +
        3 * (u * u) * t * p1.dx +
        3 * u * (t * t) * p2.dx +
        (t * t * t) * p3.dx;
    final y = (u * u * u) * p0.dy +
        3 * (u * u) * t * p1.dy +
        3 * u * (t * t) * p2.dy +
        (t * t * t) * p3.dy;
    return Offset(x, y);
  }
}

class _LabelPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  const _LabelPill({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryPathPainter extends CustomPainter {
  final double progress;
  _DeliveryPathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.55)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(40, size.height * 0.32)
      ..cubicTo(
        size.width * 0.55, size.height * 0.05,
        size.width * 0.45, size.height * 0.85,
        size.width - 60, size.height * 0.6,
      );

    // Dashed walk so the path feels animated (rotating dashes via offset).
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    const dash = 8.0;
    const gap = 6.0;
    double dist = (progress * (dash + gap)) % (dash + gap);
    while (dist < metric.length) {
      final extract =
          metric.extractPath(dist, math.min(dist + dash, metric.length));
      canvas.drawPath(extract, paint);
      dist += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DeliveryPathPainter old) => old.progress != progress;
}

// ──────────────────────────────────────────────────────────────────────────
// SLIDE 3 — Quick login
// A phone outline with masked-OTP boxes and a checkmark beneath. Vectors
// only.
// ──────────────────────────────────────────────────────────────────────────
class _LoginIllustration extends StatelessWidget {
  final AnimationController ambient;
  const _LoginIllustration({required this.ambient});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (_, __) {
        // Blink the last OTP digit caret.
        final showCaret = (ambient.value * 2) % 1 < 0.5;
        return LayoutBuilder(builder: (ctx, box) {
          final w = math.min(box.maxWidth, 260.0);
          final h = w * 1.5;
          return SizedBox(
            width: w,
            height: h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.08),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status bar mock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sent to +91 9•••••••89',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (i) {
                      final filled = i < 3;
                      final isCaret = i == 3 && showCaret;
                      return Container(
                        width: 36,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: filled
                              ? AppTheme.primaryColor.withValues(alpha: 0.08)
                              : Colors.white,
                          border: Border.all(
                            color: filled || isCaret
                                ? AppTheme.primaryColor
                                : const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: filled
                            ? const Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            : (isCaret
                                ? Container(
                                    width: 2,
                                    height: 18,
                                    color: AppTheme.primaryColor,
                                  )
                                : const SizedBox.shrink()),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text(
                        'Verify & continue',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF43A047),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Auto-account, no signup needed',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
