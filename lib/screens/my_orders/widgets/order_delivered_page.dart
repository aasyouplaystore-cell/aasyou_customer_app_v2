import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/my_orders/bloc/order_detail/order_detail_bloc.dart';

class OrderDeliveredPage extends StatefulWidget {
  final String address;
  final String addressType;
  final String orderSlug;
  const OrderDeliveredPage({super.key, required this.address, required this.addressType, required this.orderSlug});

  @override
  State<OrderDeliveredPage> createState() => _OrderDeliveredPageState();
}

class _OrderDeliveredPageState extends State<OrderDeliveredPage> {
  final confettiController = ConfettiController();
  bool isPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    confettiController.play();

    stopAnimation();
    navigateBack();
    context.read<CartBloc>().add(ClearCart(context: context));
    super.initState();
  }

  Future<void> stopAnimation () async {
    Future.delayed(const Duration(seconds: 5),(){
      confettiController.stop();
    });
  }

  Future<void> navigateBack() async {
    Future.delayed(const Duration(seconds: 6),(){
      if(mounted) {
        GoRouter.of(context).pop();
        context.read<OrderDetailBloc>().add(FetchOrderDetail(orderSlug: widget.orderSlug));
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    confettiController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          alignment: Alignment.center,
          child: Material(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  TablerIcons.circle_check_filled,
                  color: AppTheme.primaryColor,
                  size: 150.r,
                ),
                SizedBox(height: 10.h,),
                Text(
                  'Order Delivered',
                  style: TextStyle(
                      fontSize: 18.sp
                  ),
                ),
                SizedBox(height: 8.h,),
                Padding(
                  padding:  EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 00
                  ),
                  child: Text(
                    'Delivery to ${widget.addressType.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.sp
                    ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 0.0
                  ),
                  child: Text(
                    widget.address,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.sp
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: 80,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirection: pi/2,
            numberOfParticles: 30,
            gravity: 0.03,
            emissionFrequency: 0.03,
            maxBlastForce: 20,
          ),
        ),
        Positioned(
          top: -100,
          right: 80,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirection: pi/2,
            numberOfParticles: 30,
            gravity: 0.03,
            emissionFrequency: 0.03,
            maxBlastForce: 20,
          ),
        ),
      ],
    );
  }
}