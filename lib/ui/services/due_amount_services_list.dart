import 'package:aishshreya/bloc/service_bloc.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/app_text_field.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

// class ClientDueServicesPage extends StatefulWidget {
//   const ClientDueServicesPage({Key? key}) : super(key: key);
//   @override
//   State<ClientDueServicesPage> createState() => _ClientDueServicesPageState();
// }
//
// class _ClientDueServicesPageState extends State<ClientDueServicesPage> {
//
//   late final ServiceBloc bloc;
//
//   @override
//   void initState() {
//     bloc = ServiceBloc(context.read<ServiceRepository>());
//     super.initState();
//     bloc.msgController?.stream.listen((event) {
//       AppMessageHandler().showSnackBar(context, event);
//     });
//     bloc.dueController.stream.listen((event) {
//       if(event=="CLEARED") {
//         Navigator.pop(context);
//         bloc.initService(false, true);
//       }
//     });
//     bloc.initService(false, true);
//     bloc.scrollController.addListener(bloc.servicesScrollListener);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Services Due Amount"),
//       ),
//       body: CustomScrollView(
//         // controller: bloc.scrollController,
//         slivers: [
//           const SliverToBoxAdapter(child: SizedBox()),
//           ValueListenableBuilder(
//             valueListenable: bloc.serviceState,
//             builder: (context, LoadingState state, _) {
//               if(state==LoadingState.loading) {
//                 return const SliverFillRemaining(
//                   hasScrollBody: false,
//                   child: Center(
//                     child: LoadingIndicator(color: K.themeColorPrimary),
//                   ),
//                 );
//               }
//               if(state==LoadingState.error || state == LoadingState.networkError) {
//                 return SliverToBoxAdapter(
//                   child: Center(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(state==LoadingState.error ? "Some Error Occurred! Please try again!" : "No Internet Connection! Please Try Again!"),
//                         TextButton(
//                           onPressed: () {
//                             bloc.initService(false, true);
//                           },
//                           child: const Text("Retry"),
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//               }
//               return ValueListenableBuilder(
//                   valueListenable: bloc.services,
//                   builder: (context, List<ServiceDetail> services, _) {
//                     if(services.isEmpty) {
//                       return const SliverToBoxAdapter(child: SizedBox());
//                     }
//                     return MultiSliver(
//                       children: [
//                         const SliverToBoxAdapter(child: SizedBox(height: 20)),
//                         SliverPadding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           sliver: SliverList(
//                             delegate: SliverChildBuilderDelegate(
//                                   (context, i) {
//                                 return Column(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                                       decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(10),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: K.themeColorPrimary.withOpacity(0.1),
//                                               blurRadius: 10,
//                                               spreadRadius: 0,
//                                             )
//                                           ]
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             crossAxisAlignment: CrossAxisAlignment.center,
//                                             children: [
//                                               ClipOval(
//                                                 child: Image.network(
//                                                   '${services[i].clientImage}',
//                                                   height: 45,
//                                                   width: 45,
//                                                   fit: BoxFit.cover,
//                                                   errorBuilder: (context, _,__) => const CircleAvatar(
//                                                     radius: 22.5,
//                                                     backgroundColor: K.themeColorTertiary2,
//                                                     child: Icon(PhosphorIcons.user),
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 10),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: [
//                                                     Text('${services[i].clientName}', style: const TextStyle(
//                                                       fontWeight: FontWeight.w600,
//                                                       fontSize: 16,
//                                                     ),),
//                                                     Row(
//                                                       children:  [
//                                                         Icon(PhosphorIcons.phone_bold, color: K.textGrey.withOpacity(0.6),size: 12,),
//                                                         const SizedBox(width: 5),
//                                                         Text('${services[i].clientPhone}', style: TextStyle(
//                                                           fontWeight: FontWeight.w500,
//                                                           fontSize: 12,
//                                                           color: K.textGrey.withOpacity(0.6),
//                                                           height: 1,
//                                                         ),),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 10),
//                                               Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                                 children: [
//                                                   const Text("Due", style: TextStyle(fontSize: 12, color: K.textGrey, fontWeight: FontWeight.w500),),
//                                                   Text("₹${(services[i].amount ?? 0) - (services[i].amountPaid ?? 0)}", style: const TextStyle(
//                                                     fontSize: 16,
//                                                     height: 1,
//                                                     color: K.themeColorPrimary,
//                                                     fontWeight: FontWeight.w700,
//                                                   ),),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                           const SizedBox(height: 10),
//                                           const Text('Service Used', style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w700,
//                                               color: Colors.indigo,
//                                               height: 1
//                                           ),),
//                                           const Divider(),
//                                           Row(
//                                             children: [
//                                               const CircleAvatar(
//                                                 backgroundColor: K.themeColorSecondary,
//                                                 child: Icon(PhosphorIcons.user_gear),
//                                               ),
//                                               const SizedBox(width: 15),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text("${services[i].name}", style: const TextStyle(
//                                                       fontSize: 15,
//                                                       fontWeight: FontWeight.w700,
//                                                       color: K.themeColorPrimary,
//                                                     ),),
//                                                   ],
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 15),
//                                               if(services[i].serviceDate!=null) Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                                 children: [
//                                                   Text("on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(services[i].serviceDate ?? ''))}", style: const TextStyle(
//                                                       fontSize: 12,
//                                                       fontWeight: FontWeight.w700,
//                                                       color: Colors.grey
//                                                   ),),
//                                                   Text("on ${DateFormat('hh:mm a').format(DateTime.parse(services[i].serviceDate ?? ''))}", style: const TextStyle(
//                                                       fontSize: 12,
//                                                       fontWeight: FontWeight.w700,
//                                                       color: Colors.grey
//                                                   ),),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     AppButton(
//                                       title: "Clear Dues",
//                                       onTap: () {
//                                         bloc.setService(services[i]);
//                                         showModalBottomSheet(
//                                           context: context,
//                                           isScrollControlled: true,
//                                           builder: (context) => Provider.value(
//                                             value: bloc,
//                                             child: const ClearDueAmountSheet(),
//                                           ),
//                                         );
//                                       },
//                                     )
//                                   ],
//                                 );
//                               },
//                               childCount: services.length,
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//               );
//             },
//           ),
//           const SliverToBoxAdapter(child: SizedBox(height: 20)),
//           ValueListenableBuilder(
//             valueListenable: bloc.serviceState,
//             builder: (context, LoadingState state, _) {
//               if(state==LoadingState.paginating) {
//                 return const SliverToBoxAdapter(
//                   child: Center(
//                     child: LoadingIndicator(color: K.themeColorPrimary),
//                   ),
//                 );
//               }
//               return const SliverToBoxAdapter(child: SizedBox());
//             },
//           ),
//           const SliverToBoxAdapter(child: SizedBox(height: 20)),
//         ],
//       ),
//     );
//   }
// }

class ClearDueAmountSheet extends StatelessWidget {
  const ClearDueAmountSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ServiceBloc>();
    return DraggableScrollableSheet(
        minChildSize: 0.7,
        initialChildSize: 0.7,
        maxChildSize: 0.8,
        builder: (context, sc) {
          return ValueListenableBuilder(
            valueListenable: bloc.service,
            builder: (context, ServiceDetail? service, _) {
              if(service==null) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text("Service not available!"),
                  ),
                );
              }
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
                                  Icon(PhosphorIcons.sort_ascending),
                                  SizedBox(width: 10),
                                  Text("Clear Due Amount"),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                backgroundColor: K.themeColorSecondary,
                                child: Icon(PhosphorIcons.user_gear),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("${service.name}", style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: K.themeColorPrimary,
                                    ),),
                                    if(service.serviceDate!=null) Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(service.serviceDate ?? ''))}", style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey
                                        ),),
                                        Text("on ${DateFormat('hh:mm a').format(DateTime.parse(service.serviceDate ?? ''))}", style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey
                                        ),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text("₹${service.amount}", style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),)
                            ],
                          ),
                          if(service.amountPaid!=null && service.amountPaid!=0) const SizedBox(height: 10),
                          if(service.amountPaid!=null && service.amountPaid!=0) Row(
                            children: [
                              const Expanded(
                                child: Text('Currently Paid', style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),),
                              ),
                              const SizedBox(width: 10),
                              Text("₹${service.amountPaid}", style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),)
                            ],
                          ),
                          const Divider(),
                          ValueListenableBuilder(
                            valueListenable: bloc.amountVal,
                            builder: (context, double amountVal, _) {
                              return Column(
                                children: [
                                  const Text('Pay'),
                                  AutoSizeTextField(
                                    controller: bloc.amount,
                                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    fullwidth: false,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0',
                                      // prefix: SvgPicture.asset(AppIcons.coin, height: 20, width: 20,),
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter('${((service.amount ?? 0) - (service.amountPaid ?? 0)).toInt()}'.length),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    keyboardType: TextInputType.phone,
                                    onChanged: (v) {
                                      double val = double.parse(v);
                                      double amount = ((service.amount ?? 0) - (service.amountPaid ?? 0)).toDouble();
                                      if(val<amount) {
                                        bloc.amountVal.value = double.parse(v);
                                      }

                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Slider(
                                    value: amountVal,
                                    min: 0,
                                    max: ((service.amount ?? 0) - (service.amountPaid ?? 0)).toDouble(),
                                    onChanged: (double value) {
                                      bloc.updateAmount(value);
                                    },
                                    label: '${amountVal.toInt()}',
                                    divisions: (((service.amount ?? 0) - (service.amountPaid ?? 0)).toInt() ~/ 1),
                                  ),
                                ],
                              );
                            }
                          ),
                          const SizedBox(height: 10),
                          AppTextField(
                            controller: bloc.clearDueDesc,
                            title: 'Add Description',
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder(
                            valueListenable: bloc.clearing,
                            builder: (context, bool loading, _) {
                              return AppButton(
                                title: "Clear Due",
                                onTap: () {
                                  bloc.clearDues();
                                },
                                loading: loading,
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          );
        }
    );
  }


}
