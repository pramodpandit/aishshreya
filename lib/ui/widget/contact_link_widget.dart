import 'package:flutter/material.dart';
import 'package:aishshreya/utils/image_icons.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactLinkWidget extends StatelessWidget {
  final String phone, whatsapp, mail;
  const ContactLinkWidget({Key? key, required this.phone, required this.whatsapp, required this.mail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if(phone.isNotEmpty) InkWell(
          onTap: () async {
            final url = "tel:$phone";
            if(await canLaunchUrlString(url)) {
              await launchUrlString(url);
            }
          },
          child: SvgPicture.asset(AppIcons.call, height: 20.r, width: 20.r,),
        ),
        if(phone.isNotEmpty) const SizedBox(width: 25),
        if(whatsapp.isNotEmpty) InkWell(
          onTap: () async {
            String url = "";
            if(whatsapp.length > 10 && whatsapp.startsWith('91')) {
              url = "https://wa.me/$whatsapp";
            } else {
              url = "https://wa.me/91$whatsapp";
            }
            if(await canLaunchUrlString(url)) {
              await launchUrlString(url, mode: LaunchMode.externalApplication);
            }
          },
          child: SvgPicture.asset(AppIcons.whatsapp, height: 20.r, width: 20.r,),
        ),
        if(whatsapp.isNotEmpty) const SizedBox(width: 25),
        if(mail.isNotEmpty) InkWell(
          onTap: () async {
            final url = "mailto:$mail";
            if(await canLaunchUrlString(url)) {
              await launchUrlString(url);
            }
          },
          child: SvgPicture.asset(AppIcons.email, height: 20.r, width: 20.r,),
        ),
      ],
    );
  }
}
