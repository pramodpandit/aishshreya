import 'dart:io';

import 'package:aishshreya/bloc/employees_bloc.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/app_dropdown.dart';
import 'package:aishshreya/ui/widget/app_text_field.dart';
import 'package:aishshreya/ui/widget/profile_image_picker.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateEmployeePage extends StatefulWidget {
  const CreateEmployeePage({Key? key}) : super(key: key);

  @override
  State<CreateEmployeePage> createState() => _CreateEmployeePageState();
}

class _CreateEmployeePageState extends State<CreateEmployeePage> {

  late final EmployeesBloc bloc;
  final countryPicker = const FlCountryCodePicker(
    favorites: ["US", 'IN'],
    favoritesIcon: Icon(PhosphorIcons.push_pin_bold),
  );

  @override
  void initState() {
    bloc = context.read<EmployeesBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Employee", style: TextStyle(
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
                      path: bloc.image.value?.path,
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
                  icon: GestureDetector(
                    onTap: () async {
                      final code = await countryPicker.showPicker(
                        context: context,
                      );
                      if (code != null)  {
                        bloc.updateDialCode(code);
                      }
                    },
                    child: Container(
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 8.0, vertical: 4.0),
                      // margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      height: 45,
                      width: 60,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        // color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: ValueListenableBuilder(
                          valueListenable: bloc.dialCode,
                          builder: (context, CountryCode dialCode, _) {
                            return Text(dialCode.dialCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                // color: Colors.white,
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.phone2,
                  title: 'Secondary Number',
                  showTitle: false,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: bloc.dob,
                  builder: (context, DateTime? date, _) {
                    return InkWell(
                      onTap: () async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: date ?? DateTime.now(),
                          firstDate: DateTime(1960),
                          lastDate: DateTime.now(),
                        );
                        if(newDate != null) {
                          bloc.updateDOB(newDate);
                        }
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: K.themeColorSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(PhosphorIcons.calendar),
                            const SizedBox(width: 10),
                            Text(date==null ? 'Enter Date Of Birth' : DateFormat('dd MMM yyyy').format(date)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.email,
                  title: 'Email',
                  showTitle: false,
                  validate: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !Validate.emailValidation.hasMatch(v!) ? "Please enter valid email" : null,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.address,
                  title: 'Address',
                  showTitle: false,
                  maxLines: 5,
                  validate: true,
                  inputAction: TextInputAction.done,
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: bloc.joiningDate,
                  builder: (context, DateTime? date, _) {
                    return InkWell(
                      onTap: () async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: date ?? DateTime.now(),
                          firstDate: DateTime(1990),
                          lastDate: DateTime.now(),
                        );
                        if(newDate != null) {
                          bloc.updateJoiningDate(newDate);
                        }
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: K.themeColorSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(PhosphorIcons.calendar),
                            const SizedBox(width: 10),
                            Text(date==null ? 'Enter Joining Date' : DateFormat('dd MMM yyyy').format(date)),
                          ],
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.fb,
                  title: 'Facebook link',
                  showTitle: false,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.fb,
                  title: 'Instagram link',
                  showTitle: false,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.fb,
                  title: 'LinkedIn link',
                  showTitle: false,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: bloc.other,
                  title: 'Other',
                  showTitle: false,
                ),
                const SizedBox(height: 10),
                AppDropdown(
                  items: bloc.empTypes.map((e) => DropdownMenuItem(child: Text(e), value: e,)).toList(),
                  onChanged: (value) {
                    bloc.setEmpType(value);
                  },
                  value: bloc.selectedEmpType,
                  hintText: 'Select Employee Type',
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
