import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  ProfileImagePicker({
    Key? key,
    this.path,
    required this.onImageSelect,
  }) : super(key: key);

  String? path;
  final Function(String) onImageSelect;

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  @override
  Widget build(BuildContext context) {
    bool fileType = true;

    if (widget.path != null &&
        (widget.path!.startsWith('http://') ||
            widget.path!.startsWith('https://') ||
            widget.path!.startsWith('www'))) {
      fileType = false;
    }

    if (widget.path == 'null') {
      widget.path = null;
    }

    Widget child = CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[100],
      child: const Icon(
        Icons.person_outlined,
        color: K.themeColorPrimary,
        size: 30,
      ),
    );
    if (fileType) {
      if (widget.path != null) {
        print('widget.path ${widget.path}');
        child = ClipOval(
          child: Image.file(
            File(widget.path!),
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => CircleAvatar(
              radius: 50,
              backgroundColor: K.themeColorSecondary.withOpacity(0.1),
              child: const Icon(PhosphorIcons.user, color: K.themeColorPrimary, size: 50,),
            ),
          ),
        );
      }
    } else {
      if (widget.path != null) {
        print('widget.here ${widget.path}');
        child = ClipOval(
          child: FadeInImage.assetNetwork(
            image: widget.path!,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            placeholder: "assets/images/loading_shimmer.gif",
            imageErrorBuilder: (context, error, stack) => CircleAvatar(
              radius: 50,
              backgroundColor: K.themeColorSecondary.withOpacity(0.1),
              child: const Icon(PhosphorIcons.user, color: K.themeColorPrimary, size: 50,),
            ),
            placeholderErrorBuilder: (context, error, stack) => CircleAvatar(
              radius: 50,
              backgroundColor: K.themeColorSecondary.withOpacity(0.1),
              child: const Icon(PhosphorIcons.user, color: K.themeColorPrimary, size: 50,),
            ),
          ),
        );
      }
    }
    return InkWell(
      onTap: () async {
        final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            widget.path = image.path;
          });
          widget.onImageSelect(image.path);
        }
        // FilePickerResult? result = await FilePicker.platform.pickFiles(
        //   type: FileType.custom,
        //   allowCompression: true,
        //   allowedExtensions: ['jpg', 'png', 'jpeg'],
        // );
        // if(result!=null) {
        //   PlatformFile file = result.files.single;
        //   setState(() {
        //     widget.path = file.path;
        //   });
        //   widget.onImageSelect(file.path ?? '');
        // }
      },
      radius: 50,
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            child,
            /*const Positioned(
                top: 5,
                right: 5,
                child: Icon(FontAwesome5Regular.edit, color: K.primaryColor)),*/
          ],
        ),
      ),
    );
  }
}
