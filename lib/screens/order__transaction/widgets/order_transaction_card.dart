
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:intl/intl.dart';
import '../model/order_transaction_model.dart';

class OrderTransactionCard extends StatelessWidget {
  final OrderTransactionsDetail transaction;

  const OrderTransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCredit = _isCreditTransaction();
    final status = transaction.paymentStatus?.toLowerCase() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDarkMode(context) ? AppTheme.darkProductCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Section ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(isCredit, status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTransactionIcon(isCredit, status),
                    color: _getIconColor(isCredit, status),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 14),

                // Label + Order context
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTransactionLabel(isCredit, status),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _buildSubtitle(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount + Status badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_amountPrefix(isCredit, status)}${_formatAmount(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _getAmountColor(isCredit, status),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (transaction.paymentStatus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusBackgroundColor(status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatStatus(transaction.paymentStatus),
                          style: TextStyle(
                            color: _getStatusTextColor(status),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Divider ──
          Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),

          // ── Details Grid ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    label: 'Date & time',
                    value: _formatDate(transaction.createdAt),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    label: 'Payment method',
                    value: _formatPaymentMethod(transaction.paymentMethod),
                  ),
                ),
              ],
            ),
          ),

          // ── IDs Section ──
          if (transaction.transactionId != null && transaction.transactionId!.isNotEmpty ||
              transaction.orderId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  if (transaction.transactionId != null && transaction.transactionId!.isNotEmpty)
                    _buildIdRow(
                      context,
                      label: 'Payment ID',
                      value: transaction.transactionId!,
                    ),
                  if (transaction.transactionId != null &&
                      transaction.transactionId!.isNotEmpty &&
                      transaction.orderId != null)
                    const SizedBox(height: 6),
                  if (transaction.orderId != null)
                    _buildIdRow(
                      context,
                      label: 'Order ID',
                      value: transaction.orderId.toString(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Detail Item (label + value) ──
  Widget _buildDetailItem(BuildContext context, {required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ── Copyable ID Row ──
  Widget _buildIdRow(BuildContext context, {required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode(context)
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Copy',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────── Helpers ──────────────────────────────

  bool _isCreditTransaction() {
    final status = transaction.paymentStatus?.toLowerCase() ?? '';
    final method = transaction.paymentMethod?.toLowerCase() ?? '';
    if (['captured', 'completed', 'success'].contains(status)) return true;
    if (method.contains('refund')) return true;
    return false;
  }

  String _getTransactionLabel(bool isCredit, String status) {
    if (status == 'pending') return 'Payment pending';
    if (status == 'failed' || status == 'cancelled') return 'Payment failed';
    if (isCredit) return 'Payment received';
    return 'Payment attempted';
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (transaction.orderId != null) parts.add('Order #${transaction.orderId}');
    final method = _formatPaymentMethod(transaction.paymentMethod);
    if (method != 'Unknown') parts.add(method);
    return parts.join(' · ');
  }

  String _amountPrefix(bool isCredit, String status) {
    if (status == 'pending') return '';
    return isCredit ? '+' : '-';
  }

  IconData _getTransactionIcon(bool isCredit, String status) {
    if (status == 'pending') return TablerIcons.clock;
    if (status == 'failed' || status == 'cancelled') return TablerIcons.arrow_up_circle;
    return isCredit ? TablerIcons.arrow_down_circle : TablerIcons.arrow_up_circle;
  }

  Color _getIconColor(bool isCredit, String status) {
    if (status == 'pending') return const Color(0xFF854F0B);
    if (status == 'failed' || status == 'cancelled') return const Color(0xFFA32D2D);
    return isCredit ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D);
  }

  Color _getIconBackgroundColor(bool isCredit, String status) {
    if (status == 'pending') return const Color(0xFFFAEEDA);
    if (status == 'failed' || status == 'cancelled') return const Color(0xFFFCEBEB);
    return isCredit ? const Color(0xFFEAF3DE) : const Color(0xFFFCEBEB);
  }

  Color _getAmountColor(bool isCredit, String status) {
    if (status == 'pending') return const Color(0xFF854F0B);
    if (status == 'failed' || status == 'cancelled') return const Color(0xFFA32D2D);
    return isCredit ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D);
  }

  String _formatAmount(String? amount) {
    if (amount == null) return '0.00';
    final value = double.tryParse(amount) ?? 0;
    return '${AppHelpers.currency}${value.toStringAsFixed(2)}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);

      if (diff.inDays == 0) {
        final time = DateFormat('h:mm a').format(date);
        return 'Today, $time';
      } else if (diff.inDays == 1) {
        final time = DateFormat('h:mm a').format(date);
        return 'Yesterday, $time';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      }
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatPaymentMethod(String? method) {
    if (method == null || method.isEmpty) return 'Unknown';
    final lower = method.toLowerCase();
    if (lower.contains('razorpay')) return 'Razorpay';
    if (lower.contains('upi')) return 'UPI';
    if (lower.contains('card')) return 'Card';
    if (lower.contains('wallet')) return 'Wallet';
    if (lower.contains('stripe')) return 'Stripe';
    return method
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .split(RegExp(r'[_\s]+'))
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '')
        .join(' ')
        .trim();
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'captured':
      case 'completed':
      case 'success':
        return const Color(0xFFEAF3DE);
      case 'pending':
        return const Color(0xFFFAEEDA);
      case 'failed':
      case 'cancelled':
        return const Color(0xFFFCEBEB);
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'captured':
      case 'completed':
      case 'success':
        return const Color(0xFF27500A);
      case 'pending':
        return const Color(0xFF633806);
      case 'failed':
      case 'cancelled':
        return const Color(0xFF791F1F);
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatStatus(String? status) {
    if (status == null) return 'N/A';
    final s = status.toLowerCase();
    if (s == 'captured') return 'Success';
    return s[0].toUpperCase() + s.substring(1);
  }
}