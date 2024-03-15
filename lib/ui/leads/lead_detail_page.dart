import 'package:aishshreya/bloc/client_detail_bloc.dart';
import 'package:aishshreya/bloc/employee_detail_bloc.dart';
import 'package:aishshreya/bloc/lead_detail_bloc.dart';
import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/data/model/LeadDetail.dart';
import 'package:aishshreya/data/model/LeadHistory.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/data/repository/lead_repository.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/clients/client_details_page.dart';
import 'package:aishshreya/ui/leads/edit_lead_details.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/app_dropdown.dart';
import 'package:aishshreya/ui/widget/app_text_field.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart';



class LeadDetailPage extends StatefulWidget {
  final LeadDetail lead;
  const LeadDetailPage({Key? key, required this.lead}) : super(key: key);

  @override
  State<LeadDetailPage> createState() => _LeadDetailPageState();
}

class _LeadDetailPageState extends State<LeadDetailPage> {

  late final LeadDetailBloc bloc;

  @override
  void initState() {
    bloc = LeadDetailBloc(widget.lead, context.read<EmployeeRepository>(), context.read<LeadsRepository>(), context.read<ServiceRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.createController.stream.listen((event) {
      if(event=="SUCCESS") {
        Navigator.pop(context);
        bloc.initClientDetails();
      }
    });
    bloc.createController.stream.listen((event) {
      if(event=="SUCCESS") {
        Navigator.pop(context);
        bloc.initClientDetails();
      }
    });
    bloc.initClientDetails();
    bloc.scrollController.addListener(bloc.scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lead Details", style: TextStyle(
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
                        bloc.initClientDetails();
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
                  valueListenable: bloc.leadDetail,
                  builder: (context, LeadDetail? user, _) {
                    if(user==null) {
                      return const SliverToBoxAdapter(child: SizedBox());
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                          child: const EditLeadDetailPage(),
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
                                  Text("${user.phone}"),
                                  Text("${user.email}"),
                                  const SizedBox(height: 5),
                                  if(user.status!='Confirmed' && user.status!='Dead') Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) {
                                                return Provider<LeadDetailBloc>.value(
                                                  value: bloc,
                                                  child: const UpdateLeadStatusSheet(),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: K.themeColorPrimary,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text("Update Status", style: TextStyle(
                                                color: Colors.white
                                            ),),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) {
                                                return Provider<LeadDetailBloc>.value(
                                                  value: bloc,
                                                  child: const AddNewServiceWithClientSheet(),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: K.themeColorPrimary,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text("Create Service", style: TextStyle(
                                                color: Colors.white
                                            ),),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    );
                  },
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
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconTitleTab(
                                      title: "Lead History",
                                      isSelected: selectedIndex==0,
                                      onTap: () => bloc.updatePage(0),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                      width: 10,
                                      child: VerticalDivider(thickness: 1),
                                    ),
                                    IconTitleTab(
                                      title: "Past Services",
                                      isSelected: selectedIndex==1,
                                      onTap: () => bloc.updatePage(1),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                      width: 10,
                                      child: VerticalDivider(thickness: 1),
                                    ),
                                    IconTitleTab(
                                      title: "Past Lead History",
                                      isSelected: selectedIndex==2,
                                      onTap: () => bloc.updatePage(2),
                                    ),
                                  ],
                                ),
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
                      builder: (context, int page, _) {
                        switch(page) {
                          case 0: return ValueListenableBuilder(
                            valueListenable: bloc.leadDetail,
                            builder: (context, LeadDetail? user, _) {
                              if(user==null) {
                                return const SliverToBoxAdapter(child: Center(child: Text("History Not Available"),));
                              }
                              List<LeadHistory> history = user.leadHistory;
                              if(history.isEmpty) {
                                return const SliverToBoxAdapter(child: Center(child: Text("History Not Available!"),));
                              }
                              return MultiSliver(
                                children: [
                                  const SliverToBoxAdapter(
                                    child: Text("Lead History", style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),),
                                  ),
                                  const SizedBox(height: 10),
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
                                                            if(history[i].title!=null) Text("${history[i].title}", style: const TextStyle(
                                                              fontSize: 16,
                                                              height: 1,
                                                              fontWeight: FontWeight.w500,
                                                              color: K.themeColorPrimary,
                                                            ),),
                                                            if(history[i].description!=null) Text("${history[i].description}", style: const TextStyle(
                                                              fontSize: 15,
                                                              height: 1,
                                                              fontWeight: FontWeight.w500,
                                                              color: K.textGrey,
                                                            ),),
                                                            if(history[i].createdAt!=null) Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text("Created on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(history[i].createdAt ?? ''))}", style: const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.grey,
                                                                ),),
                                                                // Text("${DateFormat('hh:mm a').format(DateTime.parse(history[i].createdAt ?? ''))}", style: const TextStyle(
                                                                //   fontSize: 12,
                                                                //   fontWeight: FontWeight.w700,
                                                                //   color: Colors.grey,
                                                                // ),),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      if(history[i].schedule!=null) Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text("Follow Up On "),
                                                          Text("${DateFormat('MMM dd, yyyy').format(DateTime.parse(history[i].schedule ?? ''))}", style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w700,
                                                            color: K.themeColorPrimary,
                                                          ),),
                                                          Text("${DateFormat('hh:mm a').format(DateTime.parse(history[i].schedule ?? ''))}", style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w700,
                                                            color: K.themeColorPrimary,
                                                          ),),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                            if(i<history.length-1) const SizedBox(height: 10),
                                          ],
                                        );
                                      },
                                      childCount: history.length,
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
                            },
                          );
                          case 1: return ValueListenableBuilder(
                              valueListenable: bloc.serviceState,
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
                                              bloc.getLeadPastServices();
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
                                          const SliverToBoxAdapter(
                                            child: Text("Past Services", style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),),
                                          ),
                                          const SizedBox(height: 10),
                                          SliverList(
                                            delegate: SliverChildBuilderDelegate(
                                              (context, i) {
                                                // bool isPaid = services[i].amount==services[i].amountPaid;
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
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                              // Row(
                                                              //   children: [
                                                              //     if(isPaid) Container(
                                                              //       margin: EdgeInsets.symmetric(horizontal: 10),
                                                              //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                              //       decoration: BoxDecoration(
                                                              //         color: Colors.green,
                                                              //         borderRadius: BorderRadius.circular(5),
                                                              //       ),
                                                              //       child: const Text("PAID", style: TextStyle(
                                                              //         fontSize: 12,
                                                              //         fontWeight: FontWeight.w700,
                                                              //         color: Colors.white,
                                                              //       ),),
                                                              //     ),
                                                              //     Column(
                                                              //       crossAxisAlignment: CrossAxisAlignment.end,
                                                              //       children: [
                                                              //         Text("₹${services[i].amount}", style: const TextStyle(
                                                              //           fontSize: 16,
                                                              //           fontWeight: FontWeight.w700,
                                                              //         ),),
                                                              //         if(services[i].amount!=services[i].amountPaid) Container(
                                                              //           margin: const EdgeInsets.symmetric(vertical: 0),
                                                              //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                              //           decoration: BoxDecoration(
                                                              //             color: Colors.redAccent,
                                                              //             borderRadius: BorderRadius.circular(5),
                                                              //           ),
                                                              //           child: Text("DUE: ₹${(services[i].amount ?? 0) - (services[i].amountPaid ?? 0)}", style: const TextStyle(
                                                              //             fontSize: 12,
                                                              //             fontWeight: FontWeight.w700,
                                                              //             color: Colors.white,
                                                              //           ),),
                                                              //         ),
                                                              //       ],
                                                              //     ),
                                                              //   ],
                                                              // ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 10),
                                                          // const Text("Handler"),
                                                          // const SizedBox(height: 10),
                                                          // InkWell(
                                                          //   onTap: () {
                                                          //     final pref = context.read<SharedPreferences>();
                                                          //     if(pref.getBool('isAdmin') ?? false) {
                                                          //       Navigator.push(context, MaterialPageRoute(
                                                          //           builder: (context) => EmployeeDetailPage(
                                                          //             employee: UserDetail(id: services[i].eId, name: services[i].empName, phone: services[i].empPhone, dialCode: services[i].empDialCode),
                                                          //           )
                                                          //       ));
                                                          //     }
                                                          //   },
                                                          //   child: Row(
                                                          //     crossAxisAlignment: CrossAxisAlignment.center,
                                                          //     children: [
                                                          //       ClipOval(
                                                          //         child: Image.network(
                                                          //           '${services[i].empImage}',
                                                          //           height: 45,
                                                          //           width: 45,
                                                          //           fit: BoxFit.cover,
                                                          //           errorBuilder: (context, _,__) => const CircleAvatar(
                                                          //             radius: 22.5,
                                                          //             backgroundColor: K.themeColorTertiary2,
                                                          //             child: Icon(PhosphorIcons.user),
                                                          //           ),
                                                          //         ),
                                                          //       ),
                                                          //       const SizedBox(width: 10),
                                                          //       Expanded(
                                                          //         child: Column(
                                                          //           crossAxisAlignment: CrossAxisAlignment.start,
                                                          //           mainAxisAlignment: MainAxisAlignment.center,
                                                          //           children: [
                                                          //             Text('${services[i].empName}', style: const TextStyle(
                                                          //               fontWeight: FontWeight.w600,
                                                          //               fontSize: 16,
                                                          //             ),),
                                                          //             Row(
                                                          //               children:  [
                                                          //                 Icon(PhosphorIcons.phone_bold, color: K.textGrey.withOpacity(0.6),size: 12,),
                                                          //                 const SizedBox(width: 5),
                                                          //                 Text('${services[i].empPhone}', style: TextStyle(
                                                          //                   fontWeight: FontWeight.w500,
                                                          //                   fontSize: 12,
                                                          //                   color: K.textGrey.withOpacity(0.6),
                                                          //                   height: 1,
                                                          //                 ),),
                                                          //               ],
                                                          //             ),
                                                          //           ],
                                                          //         ),
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          // ),
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
                                        ],
                                      );
                                    }
                                );
                              }
                          );
                          case 2: return ValueListenableBuilder(
                            valueListenable: bloc.leadHistoryState,
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
                                            bloc.getPastServiceLeadHistory();
                                          },
                                          child: const Text("Retry"),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return ValueListenableBuilder(
                                valueListenable: bloc.leadServiceHistory,
                                builder: (context, List<LeadHistory> history, _) {
                                  if(history.isEmpty) {
                                    return const SliverToBoxAdapter(child: Center(child: Text("No History Available!"),));
                                  }
                                  return MultiSliver(
                                    children: [
                                      const SliverToBoxAdapter(
                                        child: Text("Past Lead History", style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),),
                                      ),
                                      const SizedBox(height: 10),
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
                                                                if(history[i].title!=null) Text("${history[i].title}", style: const TextStyle(
                                                                  fontSize: 16,
                                                                  height: 1,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: K.themeColorPrimary,
                                                                ),),
                                                                if(history[i].description!=null) Text("${history[i].description}", style: const TextStyle(
                                                                  fontSize: 15,
                                                                  height: 1,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: K.textGrey,
                                                                ),),
                                                                if(history[i].createdAt!=null) Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text("Created on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(history[i].createdAt ?? ''))}", style: const TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w700,
                                                                      color: Colors.grey,
                                                                    ),),
                                                                    // Text("${DateFormat('hh:mm a').format(DateTime.parse(history[i].createdAt ?? ''))}", style: const TextStyle(
                                                                    //   fontSize: 12,
                                                                    //   fontWeight: FontWeight.w700,
                                                                    //   color: Colors.grey,
                                                                    // ),),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 15),
                                                          if(history[i].schedule!=null) Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Text("Follow Up On "),
                                                              Text("${DateFormat('MMM dd, yyyy').format(DateTime.parse(history[i].schedule ?? ''))}", style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w700,
                                                                color: K.themeColorPrimary,
                                                              ),),
                                                              Text("${DateFormat('hh:mm a').format(DateTime.parse(history[i].schedule ?? ''))}", style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w700,
                                                                color: K.themeColorPrimary,
                                                              ),),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),
                                                    ],
                                                  ),
                                                ),
                                                if(i<history.length-1) const SizedBox(height: 10),
                                              ],
                                            );
                                          },
                                          childCount: history.length,
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
                            },
                          );
                          default: return const SliverToBoxAdapter(child: SizedBox());
                        }
                      }
                  ),
                ),
              ],
            );
          }
      ),
    );
  }
}

class UpdateLeadStatusSheet extends StatelessWidget {
  const UpdateLeadStatusSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LeadDetailBloc>();
    return DraggableScrollableSheet(
        minChildSize: 0.6,
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        builder: (context, sc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Form(
                  key: bloc.formState,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Row(
                            children: const [
                              Icon(PhosphorIcons.plus),
                              SizedBox(width: 10),
                              Text("Update Lead Status"),
                            ],
                          )),
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
                      ValueListenableBuilder(
                        valueListenable: bloc.leadStatus,
                        builder: (context,String? status,_) {
                          return Column(
                            children: [
                              AppDropdown(
                                value: status,
                                onChanged: (v) => bloc.updateLS(v!),
                                items: bloc.leadStatuses.map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e))
                                ).toList(),
                                hintText: 'Select Status',
                              ),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: bloc.title,
                                title: "Title",
                                validate: true,
                              ),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: bloc.description,
                                title: "Description",
                                validate: true,
                              ),
                              if(status=="FollowUp") const SizedBox(height: 10),
                              if(status=="FollowUp") ValueListenableBuilder(
                                valueListenable: bloc.schedule,
                                builder: (context, DateTime? date, _) {
                                  return InkWell(
                                    onTap: () async {
                                      DateTime? newDate = await showDatePicker(
                                        context: context,
                                        initialDate: date ?? DateTime.now().add(const Duration(days: 1)),
                                        firstDate: DateTime.now().add(const Duration(days: 1)),
                                        lastDate: DateTime.now().add(const Duration(days: 30)),
                                      );
                                      if(newDate != null) {
                                        var picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (picked != null) {
                                          DateTime dt = DateTime(newDate.year,
                                              newDate.month,
                                              newDate.day,
                                              picked.hour,
                                              picked.minute);

                                          bloc.updateSchedule(dt);
                                        }
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
                                          Text(date==null ? 'Enter Schedule Date' : DateFormat('dd MMM yyyy hh:mm a').format(date)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 15),
                      ValueListenableBuilder(
                        valueListenable: bloc.creatingLead,
                        builder: (context, bool loading, _) {
                          return AppButton(
                            title: "Update",
                            onTap: () {
                              bloc.updateLeadStatus();
                            },
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
    );
  }

}

class AddNewServiceWithClientSheet extends StatelessWidget {
  const AddNewServiceWithClientSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LeadDetailBloc>();
    return DraggableScrollableSheet(
        minChildSize: 0.6,
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        builder: (context, sc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Form(
                  key: bloc.formState,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Row(
                            children: const [
                              Icon(PhosphorIcons.plus),
                              SizedBox(width: 10),
                              Text("Add New Service With Lead"),
                            ],
                          )),
                          const SizedBox(width: 10),
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
                      AppTextField(
                        controller: bloc.serviceName,
                        title: "Service name",
                        validate: true,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        controller: bloc.amount,
                        title: "Amount",
                        validate: true,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      const SizedBox(height: 10),
                      ValueListenableBuilder(
                        valueListenable: bloc.schedule,
                        builder: (context, DateTime? date, _) {
                          return InkWell(
                            onTap: () async {
                              DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: date ?? DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now().add(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if(newDate != null) {
                                var picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  DateTime dt = DateTime(newDate.year,
                                      newDate.month,
                                      newDate.day,
                                      picked.hour,
                                      picked.minute);

                                  bloc.updateSchedule(dt);
                                }
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
                                  Text(date==null ? 'Enter Schedule Date' : DateFormat('dd MMM yyyy hh:mm a').format(date)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      ValueListenableBuilder(
                        valueListenable: bloc.creatingService,
                        builder: (context, bool loading, _) {
                          return AppButton(
                            title: "Add New Service",
                            onTap: () {
                              bloc.createServiceWithLead();
                            },
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
    );
  }

}