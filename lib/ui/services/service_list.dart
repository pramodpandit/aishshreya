import 'package:aishshreya/bloc/service_bloc.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/TransactionDetail.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/services/service_detail_page.dart';
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
import 'package:sliver_tools/sliver_tools.dart';

class ClientServicesPage extends StatefulWidget {
  final bool showUpcoming;
  final bool showDueServices;
  const ClientServicesPage({Key? key, this.showUpcoming = false, this.showDueServices = false}) : super(key: key);
  @override
  State<ClientServicesPage> createState() => _ClientServicesPageState();
}

class _ClientServicesPageState extends State<ClientServicesPage> {

  late final ServiceBloc bloc;

  @override
  void initState() {
    bloc = ServiceBloc(context.read<ServiceRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.initService(widget.showUpcoming, widget.showDueServices);
    bloc.scrollController.addListener(bloc.servicesScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Services"),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Provider.value(
                  value: bloc,
                  child: const ServiceFilterSheet(),
                ),
              );
            },
            icon: const Icon(PhosphorIcons.funnel, ),
          )
        ],
      ),
      backgroundColor: K.themeColorSecondary,
      body: CustomScrollView(
        controller: bloc.scrollController,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AppTextField3(
                title: 'Search service..',
                controller: bloc.searchQuery,
                showTitle: false,
                icon: const Icon(PhosphorIcons.magnifying_glass, color: K.textGrey, size: 25,),
                onChanged: bloc.onSearch,
              ),
            ),
          ),
          ValueListenableBuilder(
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
                            bloc.initService(widget.showUpcoming, widget.showDueServices);
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
                      return const SliverFillRemaining(child: Center(child: Text("No Services Added Yet!"),));
                    }
                    return MultiSliver(
                      children: [
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        ValueListenableBuilder(
                          valueListenable: bloc.searchingCli,
                          builder: (context, bool isSearching, _) {
                            return ValueListenableBuilder(
                              valueListenable: bloc.searchService,
                              builder: (context, List<ServiceDetail> searchService, _) {
                                if(searchService.isEmpty && isSearching) {
                                  return const SliverFillRemaining(
                                    hasScrollBody: true,
                                    child: Center(
                                      child: Text("No Service Found!"),
                                    ),
                                  );
                                }
                                return Provider<ServiceBloc>.value(
                                  value: bloc,
                                  child: ServiceSliverList(services: isSearching ? searchService : services),
                                );
                              },
                            );
                          },
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
      ),
    );
  }
}

class ServiceSliverList extends StatelessWidget {
  final List<ServiceDetail> services;
  const ServiceSliverList({Key? key, required this.services}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ServiceBloc>();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, i) {
            bool isPaid = services[i].amount==services[i].amountPaid;
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Provider.value(
                      value: bloc,
                      child: ServiceDetailPage(service: services[i]),
                    )));
                  },
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
                                    Text("₹${services[i].amount}", style: const TextStyle(
                                      fontSize: 16,
                                      height: 1,
                                      color: K.themeColorPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),),
                                  ],
                                ),
                                // const SizedBox(width: 10),
                                // ValueListenableBuilder(
                                //     valueListenable: bloc.invoiceService,
                                //     builder: (context, ServiceDetail? invServ, _) {
                                //       return InkWell(
                                //         onTap: () {
                                //           bloc.generateInvoice(services[i]);
                                //         },
                                //         child: CircleAvatar(
                                //           backgroundColor: K.themeColorSecondary,
                                //           child: invServ?.id==services[i].id ? const LoadingIndicator(color: K.themeColorPrimary) : const Icon(PhosphorIcons.download_bold, size: 20),
                                //         ),
                                //       );
                                //     }
                                // ),
                              ],
                            ),
                          ],
                        ),
                        // if(!isPaid) InkWell(
                        //   onTap: () {
                        //     showModalBottomSheet(
                        //       context: context,
                        //       isScrollControlled: true,
                        //       builder: (context) => Provider.value(
                        //         value: bloc,
                        //         child: EditServiceAmountSheet(service: services[i]),
                        //       ),
                        //     );
                        //   },
                        //   child: Container(
                        //     height: 35,
                        //     margin: const EdgeInsets.symmetric(vertical: 5),
                        //     decoration: BoxDecoration(
                        //       color: K.themeColorPrimary,
                        //       borderRadius: BorderRadius.circular(5),
                        //     ),
                        //     alignment: Alignment.center,
                        //     child: Text("Edit Amount", style: TextStyle(color: Colors.white),),
                        //   ),
                        // ),
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
                                  Text("${services[i].name}", style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: K.themeColorPrimary,
                                  ),),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            if(services[i].serviceDate!=null) Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                        ),*/
                        ListView.builder(
                          itemCount: services[i].additionalServices.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            TransactionDetail adServ = services[i].additionalServices[index];
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
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
          childCount: services.length,
        ),
      ),
    );
  }
}



class EditServiceAmountSheet extends StatefulWidget {
  final ServiceDetail service;
  const EditServiceAmountSheet({Key? key, required this.service}) : super(key: key);

  @override
  State<EditServiceAmountSheet> createState() => _EditServiceAmountSheetState();
}

class _EditServiceAmountSheetState extends State<EditServiceAmountSheet> {

  late final ServiceBloc bloc;
  @override
  void initState() {
    bloc = context.read<ServiceBloc>();
    super.initState();
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: bloc.formState,
              child: Column(
                children: [
                  AppBar(
                    title: Text("Edit Amount"),
                  ),
                  if(widget.service.amountPaid != 0) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: K.themeColorSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIcons.warning, color: Colors.red,),
                        const SizedBox(width: 10),
                        Text("Already paid ₹${widget.service.amountPaid} from ₹${widget.service.amount}", style: TextStyle(color: Colors.red,),)
                      ],
                    ),
                  ),
                  AppTextField(
                    controller: bloc.editAmount,
                    title: 'Add New Amount',
                    validate: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: bloc.selectedService,
                    builder: (context, ServiceDetail? loading, _) {
                      return AppButton(
                        title: "Edit Amount",
                        onTap: () {
                          bloc.editServiceAmount(widget.service);
                        },
                        loading: loading!=null,
                        margin: EdgeInsets.zero,
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          );
        }
    );
  }


}

class AddServiceAmountSheet extends StatefulWidget {
  final ServiceDetail service;
  const AddServiceAmountSheet({Key? key, required this.service}) : super(key: key);

  @override
  State<AddServiceAmountSheet> createState() => _AddServiceAmountSheetState();
}

class _AddServiceAmountSheetState extends State<AddServiceAmountSheet> {

  late final ServiceBloc bloc;
  @override
  void initState() {
    bloc = context.read<ServiceBloc>();
    super.initState();
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: bloc.formState,
              child: Column(
                children: [
                  AppBar(
                    title: Text("Add Additional Service"),
                  ),
                  AppTextField(
                    controller: bloc.title,
                    title: 'Description',
                    validate: true,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: bloc.editAmount,
                    title: 'Add New Amount',
                    validate: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: bloc.isAdditionalService,
                    builder: (context, bool isAdditionalService, _) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Text("Is Additional Service")),
                              Row(
                                children: [
                                  Radio(value: true, groupValue: isAdditionalService, onChanged: (v) => bloc.updateAdditionalService(true)),
                                  const SizedBox(width: 5),
                                  Text("Yes"),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio(value: false, groupValue: isAdditionalService, onChanged: (v) => bloc.updateAdditionalService(false)),
                                  const SizedBox(width: 5),
                                  Text("No"),
                                ],
                              ),
                            ],
                          ),
                          if(isAdditionalService) const SizedBox(height: 10),
                          if(isAdditionalService) ValueListenableBuilder(
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
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: bloc.selectedService,
                    builder: (context, ServiceDetail? loading, _) {
                      return AppButton(
                        title: "Add Additional Service",
                        onTap: () {
                          bloc.addServiceAmount(widget.service);
                        },
                        loading: loading!=null,
                        margin: EdgeInsets.zero,
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          );
        }
    );
  }


}

class InvoiceDescriptionSheet extends StatefulWidget {
  final ServiceDetail service;
  const InvoiceDescriptionSheet({Key? key, required this.service}) : super(key: key);

  @override
  State<InvoiceDescriptionSheet> createState() => _InvoiceDescriptionSheetState();
}

class _InvoiceDescriptionSheetState extends State<InvoiceDescriptionSheet> {

  late final ServiceBloc bloc;
  @override
  void initState() {
    bloc = context.read<ServiceBloc>();
    super.initState();
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: bloc.formState,
              child: Column(
                children: [
                  AppBar(
                    title: Text("Add Invoice Description"),
                  ),
                  AppTextField(
                    controller: bloc.title,
                    title: 'Invoice description',
                    validate: true,
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: bloc.selectedService,
                    builder: (context, ServiceDetail? loading, _) {
                      return AppButton(
                        title: "Add Additional Service",
                        onTap: () {

                          bloc.generateInvoice(widget.service);
                        },
                        loading: loading!=null,
                        margin: EdgeInsets.zero,
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          );
        }
    );
  }


}





