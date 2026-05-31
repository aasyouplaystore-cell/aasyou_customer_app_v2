import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/l10n/app_localizations.dart';

import '../bloc/get_user_wishlist_bloc/get_user_wishlist_bloc.dart';
import 'create_wishlist_dialog.dart';

class EmptyWishlistWidget extends StatelessWidget {
  const EmptyWishlistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.grey[200]!, width: 2),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            l10n?.yourWishlistIsEmpty ?? 'Your Wishlist is Empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n?.createYourFirstWishlistToOrganizeAndSaveItemsYouHave ?? 'Create your first wishlist to organize and save items you love',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Create New Wishlist button
          SizedBox(
            width: 230,
            child: CustomButton(
              onPressed: () {
                _showCreateWishlistDialog(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 5,),
                  Text(AppLocalizations.of(context)!.createNewWishlist),
                ],
              ),

            ),
          ),
          const SizedBox(height: 16),

          // Secondary action
          SizedBox(
            width: 230,
            child: CustomButton(
              onPressed: () {
                context.read<UserWishlistBloc>().add(GetUserWishlistRequest());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh,),
                  const SizedBox(width: 5,),
                  Text(
                    l10n?.retry ?? 'Retry',
                    style: TextStyle(
                      fontSize: 14.sp
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateWishlistDialog(BuildContext context) async {
    final result = await CreateWishlistDialog.show(context);

    if (result != null && result.isNotEmpty) {
      if (context.mounted) {
        context.read<UserWishlistBloc>().add(CreateNewWishlist(title: result));
      }
    }
  }
}
