import 'dart:io';

import 'package:aishshreya/bloc/client_detail_bloc.dart';
import 'package:aishshreya/bloc/lead_detail_bloc.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/app_text_field.dart';
import 'package:aishshreya/ui/widget/profile_image_picker.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

class EditLeadDetailPage extends StatefulWidget {
  const EditLeadDetailPage({Key? key}) : super(key: key);

  @override
  State<EditLeadDetailPage> createState() => _EditLeadDetailPageState();
}

class _EditLeadDetailPageState extends State<EditLeadDetailPage> {

  late final LeadDetailBloc bloc;

  @override
  void initState() {
    bloc = context.read<LeadDetailBloc>();
    super.initState();
    bloc.initEditLeadDetails();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Lead Details", style: TextStyle(
          color: Colors.black,
        ),),
        backgroundColor: K.themeColorSecondary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: bloc.formState,
            child: Column(
              children: [
                ProfileImagePicker(
                  path: bloc.imageURL.value ?? bloc.image.value?.path,
                  onImageSelect: (v) {
                    if(v.isNotEmpty) {
                      bloc.image.value = File(v);
                    }
                  },
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: bloc.name,
                  title: 'Name',
                  showTitle: false,
                  validate: true,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.phone,
                  title: 'Number',
                  enabled: false,
                  showTitle: false,
                  validate: true,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.phone2,
                  title: 'Phone Number 2',
                  showTitle: false,
                  validate: false,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.email,
                  title: 'Email',
                  showTitle: false,
                  validate: false,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.requirement,
                  title: 'Requirement',
                  showTitle: false,
                  validate: true,
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: bloc.creating,
                  builder: (context, bool loading, _) {
                    return AppButton(
                      title: 'Update',
                      onTap: () {
                        bloc.editLead();
                      },
                      margin: EdgeInsets.zero,
                      loading: loading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
