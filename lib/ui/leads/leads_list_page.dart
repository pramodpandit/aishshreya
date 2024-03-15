import 'package:aishshreya/bloc/clients_bloc.dart';
import 'package:aishshreya/bloc/leads_bloc.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/data/repository/lead_repository.dart';
import 'package:aishshreya/ui/leads/create_lead_page.dart';
import 'package:aishshreya/ui/leads/lead_detail_page.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aishshreya/data/model/LeadDetail.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:sliver_tools/sliver_tools.dart';

class LeadsListPage extends StatefulWidget {
  const LeadsListPage({Key? key}) : super(key: key);

  @override
  State<LeadsListPage> createState() => _LeadsListPageState();
}

class _LeadsListPageState extends State<LeadsListPage> {

  late final LeadsBloc bloc;

  @override
  void initState() {
    bloc = LeadsBloc(context.read<LeadsRepository>(), context.read<EmployeeRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.createLeadController.stream.listen((event) {
      if(event=="SUCCESS") {
        Navigator.pop(context);
        bloc.initLeads();
      }
    });
    bloc.initLeads();
    bloc.scrollController.addListener(bloc.scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Leads", style: TextStyle(
          color: Colors.black,
        ),),
        backgroundColor: K.themeColorSecondary,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIcons.plus_circle, color: K.themeColorPrimary, size: 25,),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => Provider.value(
                  value: bloc,
                  child: const CreateNewLeadPage(),
                )
              ));
            },
          )
        ],
      ),
      body: CustomScrollView(
        controller: bloc.scrollController,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ValueListenableBuilder(
            valueListenable: bloc.sort,
            builder: (context, Map<String, dynamic> sort, _) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return Provider.value(
                                value: bloc,
                                child: const SortSheet(),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: K.themeColorSecondary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text("Sort By: ${sort['name']}"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder(
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
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(state==LoadingState.error ? "Some Error Occurred! Please try again!" : "No Internet Connection! Please Try Again!"),
                          TextButton(
                            onPressed: () {
                              bloc.initLeads();
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
                        return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text("No Leads Available!")));
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
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => LeadDetailPage(lead: leads[i])
                                          ));
                                        },
                                        child: Column(
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
                                                    color: leads[i].status=='Active' ? Colors.blue : leads[i].status=='FollowUp' ? Colors.amber : leads[i].status=='Confirmed' ? Colors.green : Colors.grey[800],
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
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text("${leads[i].requirement}", textAlign: TextAlign.left,),
                                                    ],
                                                  ),
                                                  if(leads[i].nextFollowUpOn!=null && leads[i].status=="FollowUp") const SizedBox(height: 10),
                                                  if(leads[i].nextFollowUpOn!=null && leads[i].status=="FollowUp") Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text("Next Follow Up", style: TextStyle(
                                                        color: K.themeColorPrimary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),),
                                                      const SizedBox(height: 10,),
                                                      Row(
                                                        children: [
                                                          const Icon(PhosphorIcons.clock_afternoon),
                                                          const SizedBox(width: 10),
                                                          Text("${DateFormat("MMM dd, yyyy hh:mm a").format(DateTime.parse(leads[i].nextFollowUpOn ?? ''))}"),
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
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
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Provider.value(
                value: bloc,
                child: const FilterSheet(),
              );
            },
          );
        },
        backgroundColor: Colors.white,
        child: Icon(PhosphorIcons.funnel, color: K.themeColorPrimary,),
      ),
    );
  }
}



class FilterSheet extends StatelessWidget {
  const FilterSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LeadsBloc>();
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
    final bloc = context.read<LeadsBloc>();
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
