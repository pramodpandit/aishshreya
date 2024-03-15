import 'package:aishshreya/bloc/transactions_bloc.dart';
import 'package:aishshreya/data/model/TransactionDetail.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/services/trx_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart';

class TransactionsHistoryPage extends StatefulWidget {
  const TransactionsHistoryPage({Key? key}) : super(key: key);

  @override
  State<TransactionsHistoryPage> createState() => _TransactionsHistoryPageState();
}

class _TransactionsHistoryPageState extends State<TransactionsHistoryPage> {

  late final TransactionsBloc bloc;

  @override
  void initState() {
    bloc = TransactionsBloc(context.read<ServiceRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.initTransactions();
    bloc.scrollController.addListener(bloc.scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Transactions", style: TextStyle(
          color: Colors.black,
        ),),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Provider.value(
                  value: bloc,
                  child: const TransactionFilterSheet(),
                ),
              );
            },
            icon: const Icon(PhosphorIcons.funnel),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: bloc.scrollController,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          Consumer<SharedPreferences>(
            builder: (context, pref, _) {
              bool isAdmin = pref.getBool('isAdmin')==true;
              bool isAccountant = pref.getBool('isAccountant')==true;
              return ValueListenableBuilder(
                  valueListenable: bloc.transactionsState,
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
                                  bloc.initTransactions();
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
                            return const SliverFillRemaining(
                              hasScrollBody: false,
                                child: Center(child: Text("No transactions available!"),
                              ),
                            );
                          }
                          return MultiSliver(
                            children: [
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, i) {
                                      return Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Theme(
                                              data: ThemeData(
                                                backgroundColor: K.themeColorSecondary,
                                                fontFamily: K.fontFamily,
                                                dividerColor: Colors.transparent,
                                              ),
                                              child: ExpansionTile(
                                                title: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10).copyWith(
                                                    right: 0
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: K.themeColorSecondary,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text('${transactions[i].clientName}', style: const TextStyle(
                                                                  fontWeight: FontWeight.w500,
                                                                  fontSize: 16,
                                                                  // height: 1.2,
                                                                ),),
                                                                Text("${transactions[i].serviceName}"),
                                                                Row(
                                                                  children:  [
                                                                    const Icon(PhosphorIcons.phone_call_bold, color: K.themeColorPrimary,size: 15,),
                                                                    const SizedBox(width: 5),
                                                                    Text('${transactions[i].clientPhone}', style: TextStyle(
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: 13,
                                                                      color: K.textGrey.withOpacity(0.6),
                                                                      height: 1,
                                                                    ),),
                                                                  ],
                                                                ),
                                                                Text("${transactions[i].description}", style: const TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors.grey,
                                                                ),),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10),
                                                        ],
                                                      ),
                                                      if(isAdmin) if(transactions[i].status=='Requested') const SizedBox(height: 10),
                                                      if(isAdmin) if(transactions[i].status=='Requested') ValueListenableBuilder(
                                                          valueListenable: bloc.transactionDetail,
                                                          builder: (context, TransactionDetail? det, _) {
                                                            if(det!=null && det.id==transactions[i].id) {
                                                              return const Center(
                                                                child: LoadingIndicator(color: K.themeColorPrimary,),
                                                              );
                                                            }
                                                            return Row(
                                                              children: [
                                                                Expanded(
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      bloc.updateTransactionStatus(transactions[i], true);
                                                                    },
                                                                    child: Container(
                                                                      height: 40,
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.green,
                                                                        borderRadius: BorderRadius.circular(10),
                                                                      ),
                                                                      alignment: Alignment.center,
                                                                      child: const Text('Paid', style: TextStyle(color: Colors.white),),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Expanded(
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      bloc.updateTransactionStatus(transactions[i], true);
                                                                    },
                                                                    child: Container(
                                                                      height: 40,
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.redAccent,
                                                                        borderRadius: BorderRadius.circular(10),
                                                                      ),
                                                                      alignment: Alignment.center,
                                                                      child: const Text('Not Paid', style: TextStyle(color: Colors.white),),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                trailing: Padding(
                                                  padding: const EdgeInsets.only(right: 10),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text("₹${transactions[i].amount}", style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w500,
                                                      ),),
                                                      if(transactions[i].createdAt!=null) Text("${DateFormat("MMM dd, yyyy").format(DateTime.parse(transactions[i].createdAt ?? ''))}", style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: K.textGrey,
                                                      ),),
                                                    ],
                                                  ),
                                                ),
                                                tilePadding: EdgeInsets.zero,
                                                backgroundColor: K.themeColorSecondary,
                                                collapsedBackgroundColor: K.themeColorSecondary,
                                                childrenPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                children: [
                                                  Row(
                                                    children: [
                                                      ClipOval(
                                                        child: Image.network(
                                                          "${transactions[i].empImage}",
                                                          height: 40,
                                                          width: 40,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return const CircleAvatar(
                                                              radius: 20,
                                                              child: Icon(PhosphorIcons.user, color: Colors.white,),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text('${transactions[i].empName}', style: const TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 16,
                                                              // height: 1.2,
                                                            ),),
                                                            Row(
                                                              children:  [
                                                                const Icon(PhosphorIcons.phone_call_bold, color: K.themeColorPrimary,size: 15,),
                                                                const SizedBox(width: 5),
                                                                Text('${transactions[i].empDialCode}${transactions[i].empPhone}', style: TextStyle(
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
                                                    ],
                                                  ),
                                                ],
                                              ),
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
            }
          )
        ],
      ),
    );
  }
}
