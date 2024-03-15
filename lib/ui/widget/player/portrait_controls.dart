// import 'package:flutter/material.dart';
// import 'package:flick_video_player/flick_video_player.dart';
// import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import './multi_manager/flick_multi_manager.dart';
//
// class FeedPlayerPortraitControls extends StatelessWidget {
//   const FeedPlayerPortraitControls(
//       {Key? key, this.flickMultiManager, this.flickManager})
//       : super(key: key);
//
//   final FlickMultiManager? flickMultiManager;
//   final FlickManager? flickManager;
//
//   @override
//   Widget build(BuildContext context) {
//     FlickDisplayManager displayManager =
//         Provider.of<FlickDisplayManager>(context);
//     return Stack(
//       children: [
//         Container(
//           color: Colors.transparent,
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: <Widget>[
//               FlickAutoHideChild(
//                 showIfVideoNotInitialized: false,
//                 child: Align(
//                   alignment: Alignment.topRight,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: Colors.black38,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: FlickLeftDuration(),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: FlickToggleSoundAction(
//                   toggleMute: () {
//                     // flickMultiManager?.toggleMute();
//                     flickMultiManager?.togglePlay(flickManager!);
//                     displayManager.handleShowPlayerControls();
//                   },
//                   child: const FlickSeekVideoAction(
//                     child: Center(child: FlickVideoBuffer()),
//                   ),
//                 ),
//               ),
//               FlickAutoHideChild(
//                 autoHide: true,
//                 showIfVideoNotInitialized: false,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: <Widget>[
//                     Container(
//                       padding: EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.black38,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: FlickSoundToggle(
//                         toggleMute: () => flickMultiManager?.toggleMute(),
//                         color: Colors.white,
//                       ),
//                     ),
//                     // FlickFullScreenToggle(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // if(!flickManager!.flickVideoManager!.isPlaying)   Align(
//         //   alignment: Alignment.center,
//         //   child: Container(
//         //     height: 80.r,
//         //     width: 80.r,
//         //     padding: const EdgeInsets.all(2),
//         //     decoration: const BoxDecoration(
//         //       color: Colors.black38,
//         //       shape: BoxShape.circle,
//         //     ),
//         //     alignment: Alignment.center,
//         //     child: FlickTogglePlayAction(
//         //       togglePlay: () => flickMultiManager?.togglePlay(flickManager!),
//         //       child: Icon(PhosphorIcons.play_fill, color: Colors.white, size: 50),
//         //     ),
//         //   ),
//         // ),
//       ],
//     );
//   }
// }
