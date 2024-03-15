
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:aishshreya/utils/image_icons.dart';

class EmptyView extends StatelessWidget {
  final String? errorMsg;
  final String? asset;
  final double? height, width;
  final VoidCallback? onTap;
  const EmptyView({Key? key, this.errorMsg, this.onTap, this.asset, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(asset ?? AppIcons.empty2Lottie, frameRate: FrameRate(60), height: height, width: width, fit: BoxFit.cover),
          const SizedBox(height: 20),
          Text(errorMsg ?? "Couldn't find anything!"),
          const SizedBox(height: 20),
          if(onTap!=null) TextButton(onPressed: onTap, child: const Text("Tap To Try Again!")),

        ],
      ),
    );
  }
}


class ErrorView extends StatelessWidget {
  final String? errorMsg, lottieAsset;
  final VoidCallback? onTap;
  final bool isEdanshError, networkError;
  const ErrorView({Key? key, this.errorMsg, this.onTap, this.isEdanshError = false, this.lottieAsset, this.networkError = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(lottieAsset!=null ? lottieAsset! : isEdanshError ? AppIcons.edanshErrorLottie : AppIcons.occupediaErrorLottie, frameRate: FrameRate(60),),
          const SizedBox(height: 20),
          Text(networkError ? "No Internet Connection!" : errorMsg ?? "Some Error Occurred!"),
          const SizedBox(height: 20),
          if(onTap!=null) TextButton(onPressed: onTap, child: const Text("Tap To Try Again!")),

        ],
      ),
    );
  }
}


