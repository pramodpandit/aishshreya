import 'package:aishshreya/bloc/employee_detail_bloc.dart';
import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/data/model/LeadDetail.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/data/repository/lead_repository.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'edit_employee.dart';

class EmployeeDetailPage extends StatefulWidget {
  final UserDetail employee;
  const EmployeeDetailPage({Key? key, required this.employee}) : super(key: key);

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {

  late final EmployeeDetailBloc bloc;

  @override
  void initState() {
    bloc = EmployeeDetailBloc(widget.employee, context.read<EmployeeRepository>(), context.read<LeadsRepository>(), context.read<ServiceRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.editEmployeeStream.stream.listen((event) {
      if(event=="SUCCESS") {
        Navigator.pop(context);
        bloc.initEmployeeDetails();
      }
    });
    bloc.initEmployeeDetails();
    bloc.scrollController.addListener(bloc.scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Detail", style: TextStyle(
          color: Colors.black,
        ),),
      ),
      body: ValueListenableBuilder(
        valueListenable: bloc.state,
        builder: (context, LoadingState state, _) {
          if(state==LoadingState.loading) {
            return const Center(
              child: LoadingIndicator(color: K.themeColorPrimary),
            );
          }
          if(state==LoadingState.error || state == LoadingState.networkError) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state==LoadingState.error ? "Some Error Occurred! Please try again!" : "No Internet Connection! Please Try Again!"),
                  TextButton(
                    onPressed: () {
                      bloc.initEmployeeDetails();
                    },
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }
          return CustomScrollView(
            controller: bloc.scrollController,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox()),
              ValueListenableBuilder(
                valueListenable: bloc.employeeDetail,
                builder: (context, UserDetail? user, _) {
                  if(user==null) {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  '${user.image}',
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, _,__) => const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: K.themeColorTertiary2,
                                    child: Icon(PhosphorIcons.user),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Provider.value(
                                        value: bloc,
                                        child: const EditEmployeePage(),
                                      )
                                  ));
                                },
                                child: Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity(vertical: 0, horizontal: 0),
                                  side: BorderSide(width: 1.0, color: Colors.indigo),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${user.name}", style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: K.themeColorPrimary,
                                ),),
                                Text("${user.dialCode}${user.phone}"),
                                Text("${user.email}"),
                                Text(user.address ?? 'NO ADDRESS'),
                                Text("DOB: ${user.dob ?? 'No DOB'}"),
                                Text("Joining Date: ${user.joiningDate ?? "NO Joining Date Given"}"),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  );
                }
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 10),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        // color: K.themeColorSecondary,
                      ),
                      child: ValueListenableBuilder(
                          valueListenable: bloc.selectedPage,
                          builder: (context, int selectedIndex, _) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconTitleTab(
                                  title: "Clients",
                                  isSelected: selectedIndex==0,
                                  onTap: () => bloc.updatePage(0),
                                ),
                                const SizedBox(
                                  height: 20,
                                  width: 10,
                                  child: VerticalDivider(thickness: 1),
                                ),
                                IconTitleTab(
                                  title: "Leads",
                                  isSelected: selectedIndex==1,
                                  onTap: () => bloc.updatePage(1),
                                ),
                                const SizedBox(
                                  height: 20,
                                  width: 10,
                                  child: VerticalDivider(thickness: 1),
                                ),
                                IconTitleTab(
                                  title: "Services",
                                  isSelected: selectedIndex==2,
                                  onTap: () => bloc.updatePage(2),
                                ),
                              ],
                            );
                          }
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: ValueListenableBuilder(
                  valueListenable: bloc.selectedPage,
                  builder: (context, int selectedIndex, _) {
                    switch(selectedIndex) {

                      case 0: return ValueListenableBuilder(
                          valueListenable: bloc.clientsState,
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
                                          bloc.getEmployeeClients();
                                        },
                                        child: const Text("Retry"),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ValueListenableBuilder(
                                valueListenable: bloc.clients,
                                builder: (context, List<ClientDetail> clients, _) {
                                  if(clients.isEmpty) {
                                    return const SliverToBoxAdapter(child: Center(child: Text("No Clients Available!"),));
                                  }
                              return MultiSliver(
                                children: [
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, i) {
                                        return Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                ClipOval(
                                                  child: Image.network(
                                                    '${clients[i].image}',
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
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text('${clients[i].name}', style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 16,
                                                      ),),
                                                      Row(
                                                        children:  [
                                                          Icon(PhosphorIcons.phone_bold, color: K.textGrey.withOpacity(0.6),size: 12,),
                                                          const SizedBox(width: 5),
                                                          Text('${clients[i].phone}', style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 12,
                                                            color: K.textGrey.withOpacity(0.6),
                                                            height: 1,
                                                          ),),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if(i<clients.length-1) const Divider(),
                                          ],
                                        );
                                      },
                                      childCount: clients.length,
                                    ),
                                  ),
                                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                                  if(state==LoadingState.paginating) const SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: LoadingIndicator(color: K.themeColorPrimary),
                                    ),
                                  ),
                                  if(state==LoadingState.paginating) const SliverToBoxAdapter(child: SizedBox(height: 20)),
                                ],
                              );
                            }
                          );
                        }
                      );
                      case 1: return ValueListenableBuilder(
                          valueListenable: bloc.leadsState,
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
                                          bloc.getEmployeeLeads();
                                        },
                                        child: const Text("Retry"),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ValueListenableBuilder(
                                valueListenable: bloc.leads,
                                builder: (context, List<LeadDetail> leads, _) {
                                  if(leads.isEmpty) {
                                    return const SliverToBoxAdapter(child: Center(child: Text("No Leads Available"),));
                                  }
                              return MultiSliver(
                                children: [
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, i) {
                                        return Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                ClipOval(
                                                  child: Image.network(
                                                    '${leads[i].image}',
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
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text('${leads[i].name}', style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 16,
                                                      ),),
                                                      Row(
                                                        children:  [
                                                          Icon(PhosphorIcons.phone_bold, color: K.textGrey.withOpacity(0.6),size: 12,),
                                                          const SizedBox(width: 5),
                                                          Text('${leads[i].phone}', style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 12,
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
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text("${leads[i].status}", style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: K.themeColorSecondary,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              alignment: Alignment.center,
                                              child: Row(
                                                children: [
                                                  Text("${leads[i].requirement}", textAlign: TextAlign.left,),
                                                ],
                                              ),
                                            ),
                                            if(i<leads.length-1) const Divider(),
                                          ],
                                        );
                                      },
                                      childCount: leads.length,
                                    ),
                                  ),
                                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                                  if(state==LoadingState.paginating) const SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: LoadingIndicator(color: K.themeColorPrimary),
                                    ),
                                  ),
                                  if(state==LoadingState.paginating) const SliverToBoxAdapter(child: SizedBox(height: 20)),
                                ],
                              );
                            }
                          );
                        }
                      );
                      case 2: return ValueListenableBuilder(
                        valueListenable: bloc.servicesState,
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
                                        bloc.getEmployeeServices();
                                      },
                                      child: const Text("Retry"),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                          return ValueListenableBuilder(
                            valueListenable: bloc.services,
                            builder: (context, List<ServiceDetail> services, _) {
                              if(services.isEmpty) {
                                return const SliverToBoxAdapter(child: Center(child: Text("No Services Available!"),));
                              }
                              return MultiSliver(
                                children: [
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, i) {
                                        return Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: K.themeColorSecondary,
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: K.themeColorPrimary.withOpacity(0.1),
                                                    blurRadius: 10,
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      // CircleAvatar(
                                                      //   backgroundColor: K.themeColorPrimary.withOpacity(0.2),
                                                      //   child: Icon(PhosphorIcons.user_focus, color: K.themeColorPrimary,),
                                                      // ),
                                                      // const SizedBox(width: 15),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("${services[i].name}", style: const TextStyle(
                                                              fontSize: 16,
                                                              height: 1,
                                                              fontWeight: FontWeight.w500,
                                                              color: K.themeColorPrimary,
                                                            ),),
                                                            if(services[i].serviceDate!=null) Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text("on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(services[i].serviceDate ?? ''))}", style: const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.grey,
                                                                ),),
                                                                Text("on ${DateFormat('hh:mm a').format(DateTime.parse(services[i].serviceDate ?? ''))}", style: const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.grey,
                                                                ),),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      Text("₹${services[i].amount}", style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                      ),),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      ClipOval(
                                                        child: Image.network(
                                                          '${services[i].clientImage}',
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
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text('${services[i].clientName}', style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 16,
                                                            ),),
                                                            Row(
                                                              children:  [
                                                                Icon(PhosphorIcons.phone_bold, color: K.textGrey.withOpacity(0.6),size: 12,),
                                                                const SizedBox(width: 5),
                                                                Text('${services[i].clientPhone}', style: TextStyle(
                                                                  fontWeight: FontWeight.w500,
                                                                  fontSize: 12,
                                                                  color: K.textGrey.withOpacity(0.6),
                                                                  height: 1,
                                                                ),),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if(i<services.length-1) const SizedBox(height: 10),
                                          ],
                                        );
                                      },
                                      childCount: services.length,
                                    ),
                                  ),
                                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                                  if(state==LoadingState.paginating) const SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: LoadingIndicator(color: K.themeColorPrimary),
                                    ),
                                  ),
                                  if(state==LoadingState.paginating) const SliverToBoxAdapter(child: SizedBox(height: 20)),
                                ],
                              );
                            }
                          );
                        }
                      );
                      default: return Container();
                    }
                  },
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}


class IconTitleTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const IconTitleTab({Key? key, required this.title, this.isSelected = false, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: isSelected ? K.themeColorPrimary : K.themeColorSecondary,
            borderRadius: BorderRadius.circular(20)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(
              // fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isSelected ? K.themeColorBg : K.themeColorPrimary,
            ),),
          ],
        ),
      ),
    );
  }
}