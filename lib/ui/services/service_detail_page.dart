import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/TransactionDetail.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/ui/clients/client_details_page.dart';
import 'package:aishshreya/ui/employee/employee_detail_page.dart';
import 'package:aishshreya/ui/services/service_list.dart';
import 'package:flutter/material.dart';
import 'package:aishshreya/bloc/service_bloc.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/services/service_filter_sheet.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/app_text_field.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/ui/widget/occupedia_textfield.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'due_amount_services_list.dart';

class ServiceDetailPage extends StatefulWidget {
  final ServiceDetail service;
  const ServiceDetailPage({Key? key, required this.service}) : super(key: key);

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {

  late final ServiceBloc bloc;

  @override
  void initState() {
    bloc = (context.read<ServiceBloc>());
    super.initState();

    bloc.setServiceDetail(widget.service);
    bloc.dueController.stream.listen((event) {
      if(event=="CLEARED") {
        Navigator.pop(context);
        bloc.setServiceDetail(widget.service);
      }
      if(event=="CANCELLED") {
        bloc.setServiceDetail(widget.service);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Detail"),
        actions: [
          ValueListenableBuilder(
            valueListenable: bloc.service,
            builder: (context, ServiceDetail? service, _) {
              if(service==null) {
                return const SizedBox();
              }
              return ValueListenableBuilder(
                valueListenable: bloc.invoiceService,
                builder: (context, ServiceDetail? invServ, _) {
                  return InkWell(
                    onTap: () {
                      bloc.generateInvoice(service);
                    },
                    child: CircleAvatar(
                      backgroundColor: K.themeColorSecondary,
                      child: invServ?.id==service.id ? const LoadingIndicator(color: K.themeColorPrimary) : const Icon(PhosphorIcons.download_bold, size: 20),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      backgroundColor: K.themeColorSecondary,
      body: ValueListenableBuilder(
        valueListenable: bloc.serviceDetailState,
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
                children: [
                  Text(state==LoadingState.error ? "Some Error Occurred! Please try again!" : "No Internet Connection! Please Try Again!"),
                  TextButton(
                    onPressed: () {
                      bloc.setServiceDetail(widget.service);
                    },
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }
          return CustomScrollView(
            // controller: bloc.scrollController,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              ValueListenableBuilder(
                valueListenable: bloc.service,
                builder: (context, ServiceDetail? service, _) {
                  if(service==null) {
                    return const SliverToBoxAdapter(child: SizedBox(),);
                  }
                  bool isPaid = service.amount==service.amountPaid;
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: K.themeColorPrimary.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                              )
                            ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => ClientDetailPage(client: ClientDetail(id:service.clientId, name: service.clientName, phone: service.clientPhone),)
                                ));
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      '${service.clientImage}',
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
                                        Text('${service.clientName}', style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),),
                                        Row(
                                          children:  [
                                            Icon(PhosphorIcons.phone_bold, color: K.textGrey.withOpacity(0.6),size: 12,),
                                            const SizedBox(width: 5),
                                            Text('${service.clientPhone}', style: TextStyle(
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
                                  Row(
                                    children: [
                                      if(isPaid) Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Text("PAID", style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text("Amount", style: TextStyle(fontSize: 12, color: K.textGrey, fontWeight: FontWeight.w500),),
                                          Text("₹${service.amount}", style: const TextStyle(
                                            fontSize: 16,
                                            height: 1,
                                            color: K.themeColorPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),),
                                        ],
                                      ),
                                      if(!isPaid) const SizedBox(width: 10),
                                      if(!isPaid) Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text("Rem. Amt.", style: TextStyle(fontSize: 12, color: K.textGrey, fontWeight: FontWeight.w500),),
                                          Text("₹${(service.amount ?? 0) - (service.amountPaid ?? 0)}", style: const TextStyle(
                                            fontSize: 16,
                                            height: 1,
                                            color: Colors.red, //K.themeColorPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),),
                                        ],
                                      ),
                                      // const SizedBox(width: 10),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if(!isPaid) Row(
                              children: [
                                // Expanded(
                                //   child: InkWell(
                                //     onTap: () {
                                //       showModalBottomSheet(
                                //         context: context,
                                //         isScrollControlled: true,
                                //         builder: (context) => Provider.value(
                                //           value: bloc,
                                //           child: EditServiceAmountSheet(service: service),
                                //         ),
                                //       );
                                //     },
                                //     child: Container(
                                //       height: 35,
                                //       margin: const EdgeInsets.symmetric(vertical: 5),
                                //       decoration: BoxDecoration(
                                //         color: K.themeColorPrimary,
                                //         borderRadius: BorderRadius.circular(5),
                                //       ),
                                //       alignment: Alignment.center,
                                //       child: Text("Edit Amount", style: TextStyle(color: Colors.white),),
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(width: 10),
                                if((service.amount ?? 0) >= (service.amountPaid ?? 0)) Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => Provider.value(
                                          value: bloc,
                                          child: const ClearDueAmountSheet(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 35,
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      decoration: BoxDecoration(
                                        color: K.themeColorPrimary,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text("Clear Due", style: TextStyle(color: Colors.white),),
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
                                        builder: (context) => Provider.value(
                                          value: bloc,
                                          child: AddServiceAmountSheet(service: widget.service),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 35,
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      decoration: BoxDecoration(
                                        color: K.themeColorPrimary,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text("Add New", style: TextStyle(color: Colors.white),),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text('Service Needed', style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.indigo,
                                height: 1
                            ),),
                            const Divider(),
                            /*Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: K.themeColorSecondary,
                                  child: Icon(PhosphorIcons.user_gear),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${service.name}", style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: K.themeColorPrimary,
                                      ),),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                if(service.serviceDate!=null) Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(service.serviceDate ?? ''))}", style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey,
                                    ),),
                                    Text("on ${DateFormat('hh:mm a').format(DateTime.parse(service.serviceDate ?? ''))}", style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey,
                                    ),),
                                  ],
                                ),
                              ],
                            ),*/
                            ListView.builder(
                              itemCount: service.additionalServices.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                TransactionDetail adServ = service.additionalServices[index];

                                DateTime? sd = DateTime.tryParse(adServ.serviceDate ?? '');

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: K.themeColorSecondary,
                                        child: Icon(PhosphorIcons.user_gear),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${adServ.description}", style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: K.themeColorPrimary,
                                            ),),
                                            Text("₹${adServ.amount}", style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green,//K.themeColorPrimary.withOpacity(0.5),
                                            ),),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      // if(adServ.status=='Cancelled')
                                      //   Container(
                                      //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      //     decoration: BoxDecoration(
                                      //       color: Colors.red,
                                      //       borderRadius: BorderRadius.circular(4),
                                      //     ),
                                      //     child: const Text("Cancelled", style: TextStyle(
                                      //       fontSize: 12,
                                      //       color: Colors.white,
                                      //       fontWeight: FontWeight.w500,
                                      //     ),),
                                      //   )
                                      // else
                                        Row(
                                        children: [
                                          if(adServ.serviceDate!=null) Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text("on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(adServ.serviceDate ?? ''))}", style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey,
                                              ),),
                                              Text("on ${DateFormat('hh:mm a').format(DateTime.parse(adServ.serviceDate ?? ''))}", style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey,
                                              ),),
                                            ],
                                          ),
                                          // const SizedBox(width: 5),
                                          // ValueListenableBuilder(
                                          //   valueListenable: bloc.cancelling,
                                          //   builder: (context, TransactionDetail? cancelTr, _) {
                                          //     Widget child = InkWell(
                                          //       onTap: () {
                                          //         showDialog(
                                          //           context: context,
                                          //           builder: (_) => AlertDialog(
                                          //             title: const Text("Cancel Service"),
                                          //             content: Text("Are you sure you want to cancel ${adServ.description}?"),
                                          //             actions: [
                                          //               TextButton(
                                          //                 onPressed: () => Navigator.pop(context),
                                          //                 child: const Text("No"),
                                          //               ),
                                          //               TextButton(
                                          //                 onPressed: () {
                                          //                   bloc.cancelService(adServ);
                                          //                   Navigator.pop(context);
                                          //                 },
                                          //                 child: const Text("Yes"),
                                          //               ),
                                          //             ],
                                          //           ),
                                          //         );
                                          //       },
                                          //       child: CircleAvatar(
                                          //         radius: 10,
                                          //         backgroundColor: Colors.red,
                                          //         child: cancelTr?.id==adServ.id ? const LoadingIndicator(radius: 10) : const Icon(PhosphorIcons.x_bold, size: 14, color: Colors.white),
                                          //       ),
                                          //     );
                                          //     if(sd!=null) {
                                          //       if(sd.isAfter(DateTime.now())) {
                                          //         return child;
                                          //       } else {
                                          //         return const SizedBox();
                                          //       }
                                          //     }
                                          //     return child;
                                          //   },
                                          // )
                                        ],
                                      ),

                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text("Handler", style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.indigo,
                                height: 1
                            ),),
                            const Divider(),
                            InkWell(
                              onTap: () {
                                final pref = context.read<SharedPreferences>();
                                if(pref.getBool('isAdmin') ?? false) {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => EmployeeDetailPage(
                                        employee: UserDetail(id: service.eId, name: service.empName, phone: service.empPhone, dialCode: service.empDialCode),
                                      )
                                  ));
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      '${service.empImage}',
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
                                        Text('${service.empName}', style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),),
                                        Row(
                                          children:  [
                                            Icon(PhosphorIcons.phone_bold, color: K.textGrey.withOpacity(0.6),size: 12,),
                                            const SizedBox(width: 5),
                                            Text('${service.empPhone}', style: TextStyle(
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
                            ),
                            const SizedBox(height: 10),
                            AppTextField(
                              controller: bloc.invoiceDescp,
                              title: "Invoice description",
                            ),
                            const SizedBox(height: 10),
                            ValueListenableBuilder(
                              valueListenable: bloc.loadingDes,
                              builder: (context, bool loading, _) {
                                return AppButton(
                                  title: "Add Invoice Description",
                                  onTap: () {
                                    bloc.editServiceInvoiceDescp();
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
                  );
                }
              ),
              ValueListenableBuilder(
                valueListenable: bloc.transactionState,
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
                                bloc.setServiceDetail(widget.service);
                              },
                              child: const Text("Retry"),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  return ValueListenableBuilder(
                      valueListenable: bloc.transactions,
                      builder: (context, List<TransactionDetail> transactions, _) {
                        if(transactions.isEmpty) {
                          return const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text("No Transaction Done Yet!"),));
                        }
                        return MultiSliver(
                          children: [
                            const SliverToBoxAdapter(child: SizedBox(height: 20)),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) {
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: K.themeColorPrimary.withOpacity(0.1),
                                                  blurRadius: 10,
                                                  spreadRadius: 0,
                                                )
                                              ]
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 22.5,
                                                    backgroundColor: K.themeColorTertiary2,
                                                    child: Icon(PhosphorIcons.money),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text('${transactions[i].description}', style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 16,
                                                        ),),
                                                        if(transactions[i].status=='Requested') Text('${transactions[i].status}', style: const TextStyle(
                                                          fontWeight: FontWeight.w300,
                                                          fontSize: 13,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text("${transactions[i].type=="service" ? '+' : '-'}₹${transactions[i].amount}", style: TextStyle(
                                                    color: transactions[i].type=='service' ? Colors.red : Colors.green,
                                                  ),)
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                  childCount: transactions.length,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ValueListenableBuilder(
                valueListenable: bloc.serviceState,
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
          );
        }
      ),
    );
  }
}
