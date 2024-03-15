import 'package:aishshreya/bloc/service_bloc.dart';
import 'package:flutter/material.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/app_text_field.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ServiceFilterSheet extends StatefulWidget {
  const ServiceFilterSheet({Key? key}) : super(key: key);

  @override
  State<ServiceFilterSheet> createState() => _ServiceFilterSheetState();
}

class _ServiceFilterSheetState extends State<ServiceFilterSheet> {

  late final ServiceBloc bloc;
  @override
  void initState() {
    bloc = context.read<ServiceBloc>();
    super.initState();
    bloc.initFilterSort();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ServiceBloc>();
    return DraggableScrollableSheet(
        minChildSize: 0.7,
        initialChildSize: 0.7,
        maxChildSize: 0.8,
        builder: (context, sc) {
          return Container(
            // padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: bloc.formState,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppBar(
                      title: Text("Service Filters"),
                      actions: [
                        TextButton(onPressed: () {bloc.resetFilter(); Navigator.pop(context);}, child: Text("RESET")),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: bloc.showFilter,
                      builder: (context, bool isSelected, _) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 35,
                              child: Container(
                                color: K.themeColorSecondary,
                                child: Column(
                                  children: [
                                    ListTile(
                                      onTap: () => bloc.updateShowFilter(true),
                                      title: Text("Filter"),
                                      selected: isSelected,
                                    ),
                                    ListTile(
                                      onTap: () => bloc.updateShowFilter(false),
                                      title: Text("Sort"),
                                      selected: !isSelected,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 65,
                              child: Builder(
                                builder: (context) {
                                  if(isSelected) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView(
                                        children: [
                                          Text("By Payment Status"),
                                          const SizedBox(height: 10),
                                          ValueListenableBuilder(
                                            valueListenable: bloc.selectedStatus,
                                            builder: (context, AppFilter? sort, _) {
                                              return ListView.separated(
                                                controller: sc,
                                                itemCount: bloc.serviceStatus.length,
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, i) {
                                                  return InkWell(
                                                    onTap: () {
                                                      bloc.updateFilter(bloc.serviceStatus[i], 3);
                                                    },
                                                    child: filterCard(bloc.serviceStatus[i].name, bloc.serviceStatus[i].id==sort?.id));
                                                },
                                                separatorBuilder: (context, _) => const SizedBox(height: 15),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          Text("By "),
                                          const SizedBox(height: 10),
                                          ValueListenableBuilder(
                                            valueListenable: bloc.selectedFilter,
                                            builder: (context, AppFilter? sort, _) {
                                              return ListView.separated(
                                                controller: sc,
                                                itemCount: bloc.filter.length,
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, i) {
                                                  return Column(
                                                    children: [
                                                      InkWell(
                                                          onTap: () {
                                                            bloc.updateFilter(bloc.filter[i], 1);
                                                          },
                                                          child: filterCard(bloc.filter[i].name, bloc.filter[i].id==sort?.id)),
                                                      if(bloc.filter[i].id==sort?.id) const SizedBox(height: 10),
                                                      if(bloc.filter[i].id=='date' && bloc.filter[i].id==sort?.id) ValueListenableBuilder(
                                                        valueListenable: bloc.date,
                                                        builder: (context, DateTime? date, _) {
                                                          return InkWell(
                                                            onTap: () async {
                                                              DateTime? newDate = await showDatePicker(
                                                                context: context,
                                                                initialDate: date ?? DateTime.now(),
                                                                firstDate: DateTime(1990),
                                                                lastDate: DateTime.now().add(Duration(days: 90)),
                                                              );
                                                              if(newDate != null) {
                                                                bloc.updateDate(newDate);
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 50,
                                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                                              decoration: BoxDecoration(
                                                                color: K.themeColorSecondary,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  const Icon(PhosphorIcons.calendar),
                                                                  const SizedBox(width: 10),
                                                                  Text(date==null ? 'Select Date' : DateFormat('dd MMM yyyy').format(date)),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      if(bloc.filter[i].id=='range' && bloc.filter[i].id==sort?.id) ValueListenableBuilder(
                                                        valueListenable: bloc.dateRange,
                                                        builder: (context, DateTimeRange? date, _) {
                                                          return InkWell(
                                                            onTap: () async {
                                                              DateTimeRange? newDate = await showDateRangePicker(
                                                                context: context,
                                                                initialDateRange: date,
                                                                firstDate: DateTime(1990),
                                                                lastDate: DateTime.now().add(const Duration(days: 90)),
                                                                builder: (BuildContext context, child) {
                                                                  return Theme(
                                                                    data: ThemeData.light().copyWith(
                                                                      colorScheme: ColorScheme.light(
                                                                        primary: Colors.indigo,
                                                                      ),
                                                                    ),
                                                                    child: child ?? SizedBox(),
                                                                  );
                                                                },
                                                              );
                                                              if(newDate != null) {
                                                                bloc.updateDateRange(newDate);
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 50,
                                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                                              decoration: BoxDecoration(
                                                                color: K.themeColorSecondary,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  const Icon(PhosphorIcons.calendar),
                                                                  const SizedBox(width: 10),
                                                                  Text(date==null ? 'Select Date Range' : "${DateFormat('dd MMM yyyy').format(date.start)} - ${DateFormat('dd MMM yyyy').format(date.end)}"),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                                separatorBuilder: (context, _) => const SizedBox(height: 15),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    );
                                  }
                                  return ValueListenableBuilder(
                                    valueListenable: bloc.selectedSort,
                                    builder: (context, AppFilter? sort, _) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Sort By"),
                                            const SizedBox(height: 10),
                                            Expanded(
                                              child: ListView.separated(
                                                controller: sc,
                                                itemCount: bloc.sort.length,
                                                shrinkWrap: false,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, i) {
                                                  return InkWell(
                                                    onTap: () {
                                                      bloc.updateFilter(bloc.sort[i], 2);
                                                    },
                                                    child: filterCard(bloc.sort[i].name, bloc.sort[i].id==sort?.id));
                                                },
                                                separatorBuilder: (context, _) => const SizedBox(height: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        bool res = bloc.applyFilter();
                        if(res) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        height: 45,
                        width: 1.sw,
                        decoration: BoxDecoration(
                          color: K.themeColorPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text("Apply Filters", style: TextStyle(
                          color: Colors.white,
                        ),),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Widget filterCard(String title, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? K.themeColorPrimary : K.themeColorSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(
            color: selected ? Colors.white : null,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),)),
          const SizedBox(width: 10),
          if(selected) const Icon(PhosphorIcons.check_circle_bold, color: Colors.white,),
        ],
      ),
    );
  }


}
