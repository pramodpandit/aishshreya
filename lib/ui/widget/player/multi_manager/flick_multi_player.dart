//
// import '../portrait_controls.dart';
// import './flick_multi_manager.dart';
// import 'package:flick_video_player/flick_video_player.dart';
//
// import 'package:flutter/material.dart';
// import 'package:visibility_detector/visibility_detector.dart';
// import 'package:video_player/video_player.dart';
//
// class FlickMultiPlayer extends StatefulWidget {
//   const FlickMultiPlayer(
//       {Key? key,
//       required this.url,
//       this.image,
//       required this.flickMultiManager})
//       : super(key: key);
//
//   final String url;
//   final String? image;
//   final FlickMultiManager flickMultiManager;
//
//   @override
//   _FlickMultiPlayerState createState() => _FlickMultiPlayerState();
// }
//
// class _FlickMultiPlayerState extends State<FlickMultiPlayer> {
//   late FlickManager flickManager;
//
//   @override
//   void initState() {
//     flickManager = FlickManager(
//       videoPlayerController: VideoPlayerController.network(widget.url)
//         ..setLooping(true),
//         // ..initialize().then((value) => {setState(() {})}),
//       autoPlay: false,
//     );
//     widget.flickMultiManager.init(flickManager);
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     widget.flickMultiManager.remove(flickManager);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return VisibilityDetector(
//       key: ObjectKey(flickManager),
//       onVisibilityChanged: (visiblityInfo) {
//         print('===');
//         print('visible ${visiblityInfo.visibleFraction*100}');
//         if (visiblityInfo.visibleFraction > 0.9) {
//           widget.flickMultiManager.play(flickManager);
//         } else {
//           if (visiblityInfo.visibleFraction == 0 && mounted) {
//             flickManager.flickControlManager?.pause();
//           }
//         }
//       },
//       child: ClipRRect(
//         child: AspectRatio(
//           aspectRatio: 16/9,//flickManager.flickVideoManager?.videoPlayerValue?.aspectRatio ?? 16/9,
//           child: FlickVideoPlayer(
//             flickManager: flickManager,
//             flickVideoWithControls: FlickVideoWithControls(
//               playerLoadingFallback: Positioned.fill(
//                 child: Stack(
//                   children: <Widget>[
//                     // Positioned.fill(
//                     //   child: Image.asset(
//                     //     widget.image!,
//                     //     fit: BoxFit.cover,
//                     //   ),
//                     // ),
//                     Positioned.fill(
//                       child: Image.network(
//                         widget.image!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_,__, ___) {
//                           return Image.asset(
//                             widget.image!,
//                             fit: BoxFit.cover,
//                           );
//                         },
//                       ),
//                     ),
//                     Positioned(
//                       right: 10,
//                       top: 10,
//                       child: SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: const CircularProgressIndicator(
//                           // backgroundColor: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               controls: FeedPlayerPortraitControls(
//                 flickMultiManager: widget.flickMultiManager,
//                 flickManager: flickManager,
//               ),
//             ),
//             flickVideoWithControlsFullscreen: FlickVideoWithControls(
//               playerLoadingFallback: Center(
//                   child: Image.network(
//                 widget.image!,
//                 fit: BoxFit.fitWidth,
//               )),
//               controls: FlickLandscapeControls(),
//               iconThemeData: IconThemeData(
//                 size: 40,
//                 color: Colors.white,
//               ),
//               textStyle: TextStyle(fontSize: 16, color: Colors.white),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
