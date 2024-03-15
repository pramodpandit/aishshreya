import 'dart:io';

import 'package:aishshreya/bloc/client_detail_bloc.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/app_text_field.dart';
import 'package:aishshreya/ui/widget/profile_image_picker.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

class EditClientPage extends StatefulWidget {
  const EditClientPage({Key? key}) : super(key: key);

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {

  late final ClientDetailBloc bloc;

  @override
  void initState() {
    bloc = context.read<ClientDetailBloc>();
    super.initState();
    bloc.initEditClientDetails();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Client Edit", style: TextStyle(
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
                IgnorePointer(
                  ignoring: true,
                  child: AppTextField(
                    controller: bloc.phone,
                    title: 'Number',
                    showTitle: false,
                    enabled: false,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 10),
                IgnorePointer(
                  ignoring: false,
                  child: AppTextField(
                    controller: bloc.phone2,
                    title: 'Phone Number 2',
                    showTitle: false,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 10),
                IgnorePointer(
                  ignoring: true,
                  child: AppTextField(
                    controller: bloc.email,
                    title: 'Email',
                    showTitle: false,
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: bloc.creating,
                  builder: (context, bool loading, _) {
                    return AppButton(
                      title: 'Update',
                      onTap: () {
                        bloc.editClient();
                      },
                      margin: EdgeInsets.zero,
                      loading: loading,
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
