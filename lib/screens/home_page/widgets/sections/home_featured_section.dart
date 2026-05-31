import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_state.dart';
import 'package:aasyou/screens/home_page/model/featured_section_product_model.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';

class HomeFeaturedSection extends StatelessWidget {
  final Widget Function(FeaturedSectionData section) buildFeatureSection;
  final Widget loadingPlaceholder;

  const HomeFeaturedSection({
    super.key,
    required this.buildFeatureSection,
    required this.loadingPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureSectionProductBloc, FeatureSectionProductState>(
      builder: (context, state) {
        if (state is FeatureSectionProductLoaded) {
          final validSections = state.featureSectionProductData
              .where((section) => section.products.isNotEmpty)
              .toList();

          if (validSections.isEmpty) {
            return const SizedBox.shrink();
          }

          final List<Widget> sectionWidgets =
              validSections.map(buildFeatureSection).toList();

          return ListView(
            padding: EdgeInsets.only(top: 5.h),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...sectionWidgets,
              if (!state.hasReachedMax)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CustomCircularProgressIndicator(),
                  ),
                ),
            ],
          );
        }

        if (state is FeatureSectionProductLoading) {
          return loadingPlaceholder;
        }

        return const SizedBox.shrink();
      },
    );
  }
}
