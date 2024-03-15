import 'package:aishshreya/bloc/clients_bloc.dart';
import 'package:aishshreya/data/repository/lead_repository.dart';
import 'package:aishshreya/ui/clients/create_new_client.dart';
import 'package:aishshreya/ui/widget/occupedia_textfield.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'client_details_page.dart';
import 'edit_client_page.dart';

class ClientListPage extends StatefulWidget {
  const ClientListPage({Key? key}) : super(key: key);

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {

  late final ClientsBloc bloc;

  @override
  void initState() {
    bloc = ClientsBloc(context.read<LeadsRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.createClientController.stream.listen((event) {
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
        title: const Text("All Clients", style: TextStyle(
          color: Colors.black,
        ),),
        backgroundColor: K.themeColorSecondary,
        actions: [
          Consumer<SharedPreferences>(
            builder: (context, pref, _) {
              bool isAccountant = pref.getBool('isAccountant')==true;
              if(isAccountant) {
                return const SizedBox();
              }
              return IconButton(
                icon: const Icon(PhosphorIcons.plus_circle, color: K.themeColorPrimary, size: 25,),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Provider.value(
                      value: bloc,
                      child: const CreateNewClientPage(),
                    )
                  ));
                },
              );
            }
          )
        ],
      ),
      body: CustomScrollView(
        controller: bloc.scrollController,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AppTextField3(
                title: 'Search Client by name,phone..',
                controller: bloc.searchQuery,
                showTitle: false,
                icon: const Icon(PhosphorIcons.magnifying_glass, color: K.textGrey, size: 25,),
                onChanged: bloc.onSearch,
              ),
            ),
          ),
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
                            bloc.initClientDetails();
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
                    return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text("No Clients Available!")));
                  }

                  return MultiSliver(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: bloc.searchingCli,
                        builder: (context, bool isSearching, _) {
                          return ValueListenableBuilder(
                            valueListenable: bloc.searchClients,
                            builder: (context, List<ClientDetail> searchClients, _) {
                              if(searchClients.isEmpty && isSearching) {
                                return const SliverFillRemaining(
                                  hasScrollBody: true,
                                  child: Center(
                                    child: Text("No Clients Found!"),
                                  ),
                                );
                              }
                              return ClientsListView(clients: isSearching ? searchClients : clients);
                            },
                          );
                        },
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

class ClientsListView extends StatelessWidget {
  final List<ClientDetail> clients;
  const ClientsListView({Key? key, required this.clients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, i) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditClientPage()));
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ClientDetailPage(client: clients[i])));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      color: K.themeColorSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Stack(
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
                            Positioned(
                              bottom: 5,
                              right: 0,
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: Colors.green,
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
                              Text('${clients[i].name}', style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                // height: 1.2,
                              ),),
                              Row(
                                children:  [
                                  const Icon(PhosphorIcons.phone_call_bold, color: K.themeColorPrimary,size: 15,),
                                  const SizedBox(width: 5),
                                  Text('${clients[i].phone}', style: TextStyle(
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(PhosphorIcons.caret_right_bold, size: 15,)
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
          childCount: clients.length,
        ),
      ),
    );
  }
}



class FilterSheet extends StatelessWidget {
  const FilterSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ClientsBloc>();
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
    final bloc = context.read<ClientsBloc>();
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


