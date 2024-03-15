import 'package:aishshreya/bloc/employees_bloc.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/ui/employee/create_employee.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/occupedia_textfield.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:aishshreya/bloc/dashboard_bloc.dart';
import 'package:aishshreya/data/model/DashboardDetail.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/call_logs/call_logs_page.dart';
import 'package:aishshreya/ui/clients/client_page.dart';
import 'package:aishshreya/ui/employee/employee_list.dart';
import 'package:aishshreya/ui/notifications/notifications_page.dart';
import 'package:aishshreya/ui/services/due_amount_services_list.dart';
import 'package:aishshreya/ui/services/service_list.dart';
import 'package:aishshreya/ui/widget/app_drawer.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'edit_employee.dart';
import 'employee_detail_page.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({Key? key}) : super(key: key);

  @override
  State<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {

  late final EmployeesBloc bloc;

  @override
  void initState() {
    bloc = EmployeesBloc(context.read<EmployeeRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.createEmployeeStream.stream.listen((event) {
      if(event=="SUCCESS") {
        Navigator.pop(context);
        bloc.initEmployeeList();
      }
    });
    bloc.initEmployeeList();
    bloc.scrollController.addListener(bloc.employeesScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.themeColorSecondary,
      appBar: AppBar(
        title: const Text("All Employees", style: TextStyle(
          color: Colors.black,
        ),),
        backgroundColor: K.themeColorSecondary,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.plus_circle, color: K.themeColorPrimary, size: 25),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => Provider<EmployeesBloc>.value(
                  value: bloc,
                  child: const CreateEmployeePage(),
                )
              ));
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: AppTextField3(
              title: 'Search Employee',
              controller: bloc.searchQuery,
              showTitle: false,
              icon: const Icon(PhosphorIcons.magnifying_glass, color: K.textGrey, size: 25,),
              onChanged: bloc.onSearch,
            ),
          ),
          const SizedBox(height: 5),
          ValueListenableBuilder(
            valueListenable: bloc.sort,
            builder: (context, Map<String, dynamic> sort, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return Provider<EmployeesBloc>.value(
                          value: bloc,
                          child: const SortSheet(),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text("Sort By: ${sort['name']}"),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: CustomScrollView(
                controller: bloc.scrollController,
                slivers: [
                  ValueListenableBuilder(
                      valueListenable: bloc.employeeState,
                      builder: (context, LoadingState state, _) {
                        if(state==LoadingState.loading) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: LoadingIndicator(color: K.themeColorPrimary),
                            ),
                          );
                        }
                        if(state==LoadingState.error || state == LoadingState.networkError) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(state==LoadingState.error ? "Some Error Occurred! Please try again!" : "No Internet Connection! Please Try Again!"),
                                  TextButton(
                                    onPressed: () {
                                      // bloc.initService(widget.showUpcoming, widget.showDueServices);
                                    },
                                    child: const Text("Retry"),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                        return ValueListenableBuilder(
                          valueListenable: bloc.employees,
                          builder: (context, List<UserDetail> employees, _) {
                            if(employees.isEmpty) {
                              return const SliverFillRemaining(
                                hasScrollBody: true,
                                child: Center(
                                  child: Text("No Employees Available!"),
                                ),
                              );
                            }
                          return ValueListenableBuilder(
                            valueListenable: bloc.searchingEmp,
                            builder: (context, bool isSearching, _) {
                              return ValueListenableBuilder(
                                valueListenable: bloc.searchEmployees,
                                builder: (context, List<UserDetail> searchEmp, _) {
                                  if(searchEmp.isEmpty && isSearching) {
                                    return const SliverFillRemaining(
                                      hasScrollBody: true,
                                      child: Center(
                                        child: Text("No Employees Available!"),
                                      ),
                                    );
                                  }
                                  return EmployeeSliverList(employees: isSearching ? searchEmp : employees);
                                }
                              );
                            }
                          );
                        }
                      );
                    }
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ValueListenableBuilder(
                    valueListenable: bloc.employeeState,
                    builder: (context, LoadingState state, _) {
                      if(state==LoadingState.paginating) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: LoadingIndicator(color: K.themeColorPrimary),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox());
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Provider<EmployeesBloc>.value(
                value: bloc,
                child: const FilterSheet(),
              );
            },
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(PhosphorIcons.funnel, color: K.themeColorPrimary,),
      ),
    );
  }

}

class EmployeeSliverList extends StatelessWidget {
  final List<UserDetail> employees;
  const EmployeeSliverList({Key? key, required this.employees}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, i) {
          bool showNameTag = false;
          if(i==0) {
            showNameTag = true;
          } else {
            String str1 = employees[i-1].name?.substring(0,1) ?? '';
            String str2 = employees[i].name?.substring(0,1) ?? '';
            // debugPrint('$str1 $str2');
            if(str1 != str2) {
              showNameTag = true;
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(showNameTag) Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: BoxDecoration(
                  color: K.themeColorTertiary2,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text('${employees[i].name?.substring(0,1).toUpperCase()}', style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),),
              ),
              if(showNameTag) const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => EmployeeDetailPage(employee: employees[i])
                  ));
                },
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipOval(
                          child: Image.network(
                            '${employees[i].image}',
                            height: 45,
                            width: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _,__) => const CircleAvatar(
                              radius: 22.5,
                              backgroundColor: K.themeColorTertiary2,
                              child: Icon(PhosphorIcons.user),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 0,
                          child: CircleAvatar(
                            radius: 5,
                            backgroundColor: employees[i].status=='Active' ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${employees[i].name}', style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            // height: 1.2,
                          ),),
                          Row(
                            children:  [
                              const Icon(PhosphorIcons.phone_call_bold, color: K.themeColorPrimary,size: 15,),
                              const SizedBox(width: 5),
                              Text('${employees[i].dialCode}${employees[i].phone}', style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: K.textGrey.withOpacity(0.6),
                                height: 1,
                              ),),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        decoration: BoxDecoration(
                          color: K.themeColorSecondary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(PhosphorIcons.caret_right_bold, size: 15,)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
        childCount: employees.length,
      ),
    );
  }
}


class FilterSheet extends StatelessWidget {
  const FilterSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EmployeesBloc>();
    return DraggableScrollableSheet(
        minChildSize: 0.5,
        initialChildSize: 0.5,
        maxChildSize: 0.7,
        builder: (context, sc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Row(
                      children: const [
                        Icon(PhosphorIcons.funnel, color: K.themeColorPrimary,),
                        SizedBox(width: 10),
                        Text("Filter"),
                      ],
                    )),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(PhosphorIcons.x_bold,),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: bloc.filter,
                    builder: (context, Map<String, dynamic> filter, _) {
                      return ListView.separated(
                        controller: sc,
                        itemCount: bloc.filterTypes.length,
                        shrinkWrap: false,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, i) {
                          return InkWell(
                            onTap: () {
                              bloc.updateFilter(bloc.filterTypes[i]);
                              Navigator.pop(context);
                            },
                            child: filterCard('${bloc.filterTypes[i]['name']}', bloc.filterTypes[i]['id']==filter['id']));
                        },
                        separatorBuilder: (context, _) => const SizedBox(height: 15),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
              ],
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

class SortSheet extends StatelessWidget {
  const SortSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EmployeesBloc>();
    return DraggableScrollableSheet(
      minChildSize: 0.5,
      initialChildSize: 0.5,
      maxChildSize: 0.7,
      builder: (context, sc) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Row(
                    children: const [
                      Icon(PhosphorIcons.sort_ascending),
                      SizedBox(width: 10),
                      Text("Sort"),
                    ],
                  )),
                  const SizedBox(width: 10),
                  ValueListenableBuilder(
                    valueListenable: bloc.isAscending,
                    builder: (context, bool isAscending, _) {
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: K.themeColorPrimary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if(!isAscending) {
                                  bloc.updateSortAsc(true);
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAscending ? Colors.white : null,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text('Asc'),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if(isAscending) {
                                  bloc.updateSortAsc(false);
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAscending ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text('Desc'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(PhosphorIcons.x_bold,),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: bloc.sort,
                  builder: (context, Map<String, dynamic> sort, _) {
                    return ListView.separated(
                      controller: sc,
                      itemCount: bloc.sortTypes.length,
                      shrinkWrap: false,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, i) {
                        return InkWell(
                          onTap: () {
                            bloc.updateSortType(bloc.sortTypes[i]);
                            Navigator.pop(context);
                          },
                          child: filterCard('${bloc.sortTypes[i]['name']}', bloc.sortTypes[i]['id']==sort['id']));
                      },
                      separatorBuilder: (context, _) => const SizedBox(height: 15),
                    );
                  }
                ),
              ),
              const SizedBox(height: 15),
            ],
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

