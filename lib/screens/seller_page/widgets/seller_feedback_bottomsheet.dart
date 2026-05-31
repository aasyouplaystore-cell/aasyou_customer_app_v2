import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/seller_page/bloc/seller_feedback/seller_feedback_bloc.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:aasyou/l10n/app_localizations.dart';

class SellerFeedbackSheet extends StatefulWidget {
  final String orderSlug;
  final int orderItemId;
  final String storeName;
  final int sellerId;
  final int? feedbackId;
  final String? initialTitle;
  final String? initialDescription;
  final int? initialRating;

  const SellerFeedbackSheet({
    super.key,
    required this.orderSlug,
    required this.orderItemId,
    required this.storeName,
    required this.sellerId,
    this.feedbackId,
    this.initialTitle,
    this.initialDescription,
    this.initialRating,
  });

  @override
  State<SellerFeedbackSheet> createState() => _SellerFeedbackSheetState();
}

class _SellerFeedbackSheetState extends State<SellerFeedbackSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descController = TextEditingController(text: widget.initialDescription ?? '');
    _rating = widget.initialRating?.toDouble() ?? 0.0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ToastManager.show(
      context: context,
      message: message,
      type: ToastType.error,
    );
  }

  void _handleBlocListener(BuildContext context, SellerFeedbackState state) {
    if (state is SellerFeedbackLoaded) {
      final isUpdate = widget.feedbackId != null;
      ToastManager.show(
        context: context,
        message: isUpdate
            ? AppLocalizations.of(context)!.feedbackUpdatedSuccessfully
            : AppLocalizations.of(context)!.feedbackSubmittedSuccessfully,
        type: ToastType.success,
      );
      context.read<SellerFeedbackBloc>().add(ResetSellerFeedback());
      Navigator.pop(context, true);
    } else if (state is SellerFeedbackFailure) {
      ToastManager.show(
        context: context,
        message: state.error,
        type: ToastType.error,
      );
      context.read<SellerFeedbackBloc>().add(ResetSellerFeedback());
    }
  }

  void _submit() {
    // Validation for all 3 inputs
    if (_rating == 0) {
      return _showError(AppLocalizations.of(context)!.pleaseGiveARating);
    }
    if (_titleController.text.trim().isEmpty) {
      return _showError(AppLocalizations.of(context)!.pleaseEnterATitle);
    }
    if (_descController.text.trim().isEmpty) {
      return _showError(AppLocalizations.of(context)!.pleaseEnterADescription);
    }

    final isUpdate = widget.feedbackId != null;

    if (isUpdate) {
      context.read<SellerFeedbackBloc>().add(
        UpdateSellerFeedback(
          feedbackId: widget.feedbackId!,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          rating: _rating.toInt(),
        ),
      );
    } else {
      context.read<SellerFeedbackBloc>().add(
        AddSellerFeedback(
          orderItemId: widget.orderItemId,
          sellerId: widget.sellerId,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          rating: _rating.toInt(),
        ),
      );
    }
  }

  void _deleteFeedback() {
    if (widget.feedbackId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteFeedback),
        content: Text(AppLocalizations.of(context)!.areYouSureYouWantToDeleteThisFeedback),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SellerFeedbackBloc>().add(
                DeleteSellerFeedback(feedbackId: widget.feedbackId!),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerFeedbackBloc, SellerFeedbackState>(
      listener: _handleBlocListener,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 10.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _HeaderSection(
                  storeName: widget.storeName,
                  isEditMode: widget.feedbackId != null,
                ),
                SizedBox(height: 20.h),
                _RatingSection(
                  rating: _rating,
                  onChanged: (r) {
                    HapticFeedback.lightImpact();
                    setState(() => _rating = r);
                  },
                ),
                SizedBox(height: 20.h),
                _InputSection(
                  titleController: _titleController,
                  descController: _descController,
                ),
                SizedBox(height: 24.h),
                _ActionButtons(
                  isLoading:
                  context.watch<SellerFeedbackBloc>().state is SellerFeedbackLoading,
                  onSubmit: _submit,
                  onDelete: widget.feedbackId != null ? _deleteFeedback : null,
                  isEditMode: widget.feedbackId != null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// --- HEADER SECTION ---
class _HeaderSection extends StatelessWidget {
  final String storeName;
  final bool isEditMode;
  const _HeaderSection({required this.storeName, required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: isTablet(context) ? 18.r : 24.r,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.store_rounded,
              color: AppTheme.primaryColor, size: isTablet(context) ? 24.h : 28.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.rateStoreName(storeName),
                style: TextStyle(fontSize: isTablet(context) ? 24 : 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                isEditMode ? AppLocalizations.of(context)!.editYourFeedback : AppLocalizations.of(context)!.howWasYourExperience,
                style: TextStyle(fontSize: isTablet(context) ? 20 : 13.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// --- RATING SECTION ---
class _RatingSection extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const _RatingSection({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            itemCount: 5,
            itemSize: isTablet(context) ? 16.h : 18.w,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
            glow: false,
            itemBuilder: (_, __) =>
            const Icon(AppTheme.ratingStarIconFilled, color: AppTheme.ratingStarColor),
            onRatingUpdate: onChanged,
          ),
          SizedBox(height: 8.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              rating > 0
                  ? '${rating.toInt()} Star${rating > 1 ? 's' : ''}'
                  : AppLocalizations.of(context)!.tapToRate,
              key: ValueKey(rating),
              style: TextStyle(fontSize: isTablet(context) ? 18 : 12.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

/// --- INPUT SECTION ---
class _InputSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;

  const _InputSection({
    required this.titleController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          hintText: AppLocalizations.of(context)!.egGreatService,
        ),
        SizedBox(height: 16.h),
        CustomTextFormField(
          controller: descController,
          maxLines: 4,
          hintText: AppLocalizations.of(context)!.shareMoreDetails,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}

/// --- ACTION BUTTONS ---
class _ActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback? onDelete;
  final bool isEditMode;

  const _ActionButtons({
    required this.isLoading,
    required this.onSubmit,
    this.onDelete,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            onPressed: isLoading ? () {} : onSubmit,
            child: isLoading
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  isEditMode ? AppLocalizations.of(context)!.updating : AppLocalizations.of(context)!.submitting,
                  style: TextStyle(fontSize: isTablet(context) ? 20 : 14.sp, color: Colors.white),
                ),
              ],
            )
                : Text(
              isEditMode ? AppLocalizations.of(context)!.updateFeedback : AppLocalizations.of(context)!.submitFeedback,
              style: TextStyle(
                fontSize: isTablet(context) ? 20 : 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (onDelete != null) ...[
          SizedBox(height: 12.h),
          SizedBox(
            height: isTablet(context) ? 40.h : 48,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isLoading ? null : onDelete,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.deleteFeedback,
                style: TextStyle(
                  fontSize: isTablet(context) ? 20 : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
