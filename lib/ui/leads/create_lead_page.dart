import 'package:aishshreya/bloc/employees_bloc.dart';
import 'package:aishshreya/bloc/leads_bloc.dart';
import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/app_drawer.dart';
import 'package:aishshreya/ui/widget/app_dropdown.dart';
import 'package:aishshreya/ui/widget/app_text_field.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:aishshreya/ui/widget/profile_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateNewLeadPage extends StatefulWidget {
  const CreateNewLeadPage({Key? key}) : super(key: key);

  @override
  State<CreateNewLeadPage> createState() => _CreateNewLeadPageState();
}

class _CreateNewLeadPageState extends State<CreateNewLeadPage> {
  late final LeadsBloc bloc;
  final countryPicker = const FlCountryCodePicker(
    favorites: ["US", 'IN'],
    favoritesIcon: Icon(PhosphorIcons.push_pin_bold),
  );

  @override
  void initState() {
    bloc = context.read<LeadsBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Lead", style: TextStyle(
          color: Colors.black,
        ),),
        backgroundColor: K.themeColorSecondary,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: bloc.formState,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Stack(
                  children: [
                    ProfileImagePicker(
                      path: bloc.imageURL ?? bloc.image.value?.path,
                      onImageSelect: (v) {
                        if(v.isNotEmpty) {
                          bloc.image.value = File(v);
                        }
                      },
                    ),
                    // const Positioned(
                    //   bottom: 5,
                    //   right: 0,
                    //   child: CircleAvatar(
                    //     radius: 13,
                    //     backgroundColor: K.themeColorPrimary,
                    //     child: CircleAvatar(
                    //       radius: 12,
                    //       backgroundColor: Colors.white,
                    //       child: Icon(PhosphorIcons.camera, size: 14, color: K.themeColorPrimary,),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                // ValueListenableBuilder(
                //   valueListenable: bloc.clients,
                //   builder: (context, List<ClientDetail> clients, _) {
                //     return AppDropdown(
                //       value: bloc.clientId,
                //       onChanged: (v) => bloc.updateClient(v!),
                //       items: clients.map((e) => DropdownMenuItem(
                //           value: '${e.id}',
                //           child: Text('${e.name}'))).toList(),
                //       hintText: 'Select Client',
                //     );
                //   },
                // ),
                // const SizedBox(height: 10),
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
                  title: 'Phone number 2',
                  showTitle: false,
                  // validate: true,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.requirement,
                  title: 'Lead requirement',
                  showTitle: false,
                  validate: true,
                ),
                const SizedBox(height: 10),
                Consumer<SharedPreferences>(
                  builder: (context, pref, _) {
                    bool isAdmin = pref.getBool('isAdmin')==true;
                    if(isAdmin) {
                      return Column(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: bloc.employees,
                            builder: (context, List<UserDetail> employees, _) {
                              return AppDropdown(
                                value: bloc.selectedEmpId,
                                onChanged: (v) => bloc.updateEmployee(v!),
                                items: employees.map((e) => DropdownMenuItem(
                                    value: '${e.id}',
                                    child: Text('${e.name}'))).toList(),
                                hintText: 'Select Employee',
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }
                    return const SizedBox(height: 0);
                  }
                ),
                AppTextField(
                  controller: bloc.email,
                  title: 'Email',
                  showTitle: false,
                  validate: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? null : !Validate.emailValidation.hasMatch(v) ? "Please enter valid email" : null,
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                    valueListenable: bloc.creating,
                    builder: (context, bool loading, _) {
                      return AppButton(
                        title: 'Submit',
                        onTap: () {
                          bloc.createNewEmployee();
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
