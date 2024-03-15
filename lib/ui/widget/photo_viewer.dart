import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatelessWidget {
  final File? filePhoto;
  final String? networkPhoto;
  final bool online;
  final String tag;
  const PhotoViewer({Key? key, this.filePhoto, this.networkPhoto, required this.online, this.tag='photo'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Material(
        child: Stack(
          children: [
            Container(
              height: size.height,
              width: size.width,
              child: Hero(
                  tag: tag,
                  child: online ? PhotoView(
                    imageProvider: NetworkImage(networkPhoto!),
                  ) : PhotoView(
                    imageProvider: FileImage(filePhoto!),
                  )
              ),
            ),
            Positioned(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
                decoration: BoxDecoration(
                  color: Colors.black26,
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white,),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

