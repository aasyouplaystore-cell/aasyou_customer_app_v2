import 'package:flutter/material.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import '../../../../config/helper.dart';

class DeliveryPartnerSection extends StatelessWidget {
  final String name;
  final String? phone;
  final String? deliveryBoyProfile;

  const DeliveryPartnerSection({
    super.key,
    required this.name,
    this.phone,
    this.deliveryBoyProfile,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone =
        phone != null && phone!.trim().isNotEmpty && phone != 'null';

    return Padding(
      padding: const EdgeInsets.only(
        top: 12,
        left: 12,
        right: 12,
      ),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 60,
                height: 60,
                color: Theme.of(context).colorScheme.secondary,
                child: Transform.translate(
                  offset: const Offset(0, 7), // pixels down — adjust 4–12
                  child: Image(
                    height: 45,
                    width: 45,
                    image: (deliveryBoyProfile?.isNotEmpty ?? false)
                        ? NetworkImage(deliveryBoyProfile!)
                        : const AssetImage('assets/images/delivery-man.png') as ImageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(AppLocalizations.of(context)!.deliveryPartner,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            if (hasPhone)
              Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline)),
                child: IconButton(
                  icon: const Icon(Icons.phone_in_talk,
                      color: AppTheme.primaryColor),
                  onPressed: () =>
                      makePhoneCall(phoneNumber: phone!, context: context),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.phone_disabled, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }
}
