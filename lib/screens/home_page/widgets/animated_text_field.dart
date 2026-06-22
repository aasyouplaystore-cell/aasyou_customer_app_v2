import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/router/app_routes.dart';

class CustomAnimatedTextField extends StatelessWidget {
  final List<String>? searchHintTextList;
  const CustomAnimatedTextField({
    super.key,
    this.searchHintTextList
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
      ),
      child: SizedBox(
        height: 50,
        child: GestureDetector(
          onTap: () {
            GoRouter.of(context).push(AppRoutes.search);
          },
          child: Stack(
            children: [
              Directionality(
                textDirection: Localizations.localeOf(context).languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
                child: AnimatedTextField(
                  animationDuration: const Duration(milliseconds: 500),
                  animationType: Animationtype.typer,
                  showCursor: false,
                  readOnly: true,
                  enabled: false,
                  hintTextStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.75),
                  ),
                  hintTexts: removeUnderscoresFromStringList(searchHintTextList ?? [
                    'Search for stores or products...',
                    'Search "ice cream"',
                    'Search "milk"',
                    'Search "rice"',
                    'Search "shampoo"',
                    'Search "namkeen"',
                  ]),
                  minLines: 1,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    hintText: 'Search for stores or products...',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withValues(alpha: 0.75),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none
                    ),
                    fillColor: isDarkMode(context) ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary,
                    filled: true,
                    prefixIcon: Icon(
                      HeroiconsOutline.magnifyingGlass,
                      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.75),
                      size: 22,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                end: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push(
                        AppRoutes.search,
                        extra: {'startVoice': true},
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        HeroiconsOutline.microphone,
                        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}