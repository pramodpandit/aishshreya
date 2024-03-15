
import 'package:aishshreya/bloc/dashboard_bloc.dart';
import 'package:aishshreya/bloc/notification_controller.dart';
import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/data/model/DashboardDetail.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/call_logs/call_logs_page.dart';
import 'package:aishshreya/ui/clients/client_details_page.dart';
import 'package:aishshreya/ui/clients/client_page.dart';
import 'package:aishshreya/ui/employee/employee_list.dart';
import 'package:aishshreya/ui/leads/leads_list_page.dart';
import 'package:aishshreya/ui/notifications/notifications_page.dart';
import 'package:aishshreya/ui/services/due_amount_services_list.dart';
import 'package:aishshreya/ui/services/service_list.dart';
import 'package:aishshreya/ui/services/service_transactions.dart';
import 'package:aishshreya/ui/widget/app_drawer.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class HomePage extends StatefulWidget {
  static const route = "/HomePage";
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final DashboardBloc bloc;

  @override
  void initState() {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );

    bloc = DashboardBloc(context.read<EmployeeRepository>(), context.read<ServiceRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.initAdmin();
    bloc.uploadCallLogs();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Dashboard"),
        leading: IconButton(
          icon: const Icon(PhosphorIcons.list_bold,),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
          }, icon: const Icon(PhosphorIcons.bell),)
        ],
      ),
      backgroundColor: K.themeColorSecondary,
      body: RefreshIndicator(
        onRefresh: () async {
          bloc.initAdmin();
        },
        child: ValueListenableBuilder(
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
                        bloc.initAdmin();
                      },
                      child: const Text("Retry"),
                    )
                  ],
                ),
              );
            }
            return Consumer<SharedPreferences>(
              builder: (context, pref, _) {
                bool isAdmin = pref.getBool('isAdmin')==true;
                bool isAccountant = pref.getBool('isAccountant')==true;
                bool isEmp = true;
                if(!isAdmin && !isAccountant) {
                  isEmp = true;
                } else {
                  isEmp = false;
                }
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    ValueListenableBuilder(
                      valueListenable: bloc.dashboardInfoState,
                      builder: (context, LoadingState state, _) {
                        if(state==LoadingState.loading) {
                          return const SliverToBoxAdapter(
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
                                      bloc.initAdmin();
                                    },
                                    child: const Text("Retry"),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                        return ValueListenableBuilder(
                          valueListenable: bloc.dashboard,
                          builder: (context, DashboardDetail? dashboard, _) {
                            if(dashboard==null) {
                              return const SliverToBoxAdapter(child: SizedBox());
                            }
                            return SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    //Employee Widget
                                    if(isAdmin) Container(
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
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: K.themeColorSecondary,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(PhosphorIcons.users_three, color: K.themeColorPrimary,),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Employees", style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: K.textGrey,
                                                ),),
                                                Text("${dashboard.totalEmployee}", style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: K.themeColorPrimary
                                                ),),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => const EmployeeList()
                                              ));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: K.textGrey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(25)
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(PhosphorIcons.arrow_square_out, size: 20, color: Colors.indigo,),
                                                  const SizedBox(width: 10),
                                                  Text("View Employees", style: TextStyle(
                                                    color: Colors.indigo,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if(isAdmin) const SizedBox(height: 10),
                                    //Client & Lead Widget
                                    Row(
                                      children: [
                                        if(isAdmin || isAccountant) Expanded(
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
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: K.themeColorSecondary,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Icon(PhosphorIcons.user_circle, color: K.themeColorPrimary,),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Clients", style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: K.textGrey,
                                                        ),),
                                                        Text("${dashboard.totalClients}", style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: K.themeColorPrimary
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding: EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                          color: K.themeColorTertiary1,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            const Text('Last week', textAlign: TextAlign.center, style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w600,
                                                              color: K.textGrey,
                                                            ),),
                                                            const SizedBox(height: 5),
                                                            Text("${dashboard.clientsLastWeek}", style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 15,
                                                            ),),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Container(
                                                        padding: EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                          color: K.themeColorTertiary1,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            const Text('Last month', textAlign: TextAlign.center, style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w600,
                                                              color: K.textGrey,
                                                            ),),
                                                            const SizedBox(height: 5),
                                                            Text("${dashboard.clientsLastMonth}", style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 15,
                                                            ),),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(context, MaterialPageRoute(
                                                        builder: (context) => const ClientListPage()
                                                    ));
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                    decoration: BoxDecoration(
                                                        color: K.textGrey.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(25)
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: const [
                                                        Icon(PhosphorIcons.arrow_square_out, size: 20, color: Colors.indigo,),
                                                        SizedBox(width: 10),
                                                        Text("View Clients", style: TextStyle(
                                                          color: Colors.indigo,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if(isAdmin) const SizedBox(width: 10),
                                        if(isAdmin || isEmp) Expanded(
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
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: K.themeColorSecondary,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: const Icon(PhosphorIcons.user_circle, color: K.themeColorPrimary,),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text("Leads", style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: K.textGrey,
                                                        ),),
                                                        Text("${dashboard.totalLeads}", style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: K.themeColorPrimary
                                                        ),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding: const EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                          color: K.themeColorTertiary1,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            const Text('Last week', textAlign: TextAlign.center, style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w600,
                                                              color: K.textGrey,
                                                            ),),
                                                            const SizedBox(height: 5),
                                                            Text("${dashboard.leadsLastWeek}", style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 15,
                                                            ),),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Container(
                                                        padding: EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                          color: K.themeColorTertiary1,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            const Text('Last month', textAlign: TextAlign.center, style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w600,
                                                              color: K.textGrey,
                                                            ),),
                                                            const SizedBox(height: 5),
                                                            Text("${dashboard.leadsLastMonth}", style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 15,
                                                            ),),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(context, MaterialPageRoute(
                                                        builder: (context) => const LeadsListPage()
                                                    ));
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                    decoration: BoxDecoration(
                                                        color: K.textGrey.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(25)
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: const [
                                                        Icon(PhosphorIcons.arrow_square_out, size: 20, color: Colors.indigo,),
                                                        SizedBox(width: 10),
                                                        Text("View Leads", style: TextStyle(
                                                          color: Colors.indigo,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    //Call Log & Service Widget
                                    Row(
                                      children: [
                                        if(isAdmin) Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => const CallLogsPage()
                                              ));
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
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: K.themeColorSecondary,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Icon(PhosphorIcons.phone_call, color: K.themeColorPrimary,),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Call Logs", style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: K.textGrey,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.push(context, MaterialPageRoute(
                                                          builder: (context) => const CallLogsPage()
                                                      ));
                                                    },
                                                    icon: Icon(PhosphorIcons.arrow_square_out, size: 20, color: Colors.indigo,),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if(isAdmin) const SizedBox(width: 10),
                                        if(isAdmin || isAccountant) Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => const ClientServicesPage()
                                              ));
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
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: K.themeColorSecondary,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Icon(PhosphorIcons.circles_three_plus, color: K.themeColorPrimary,),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: const [
                                                        Text("Services", style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: K.textGrey,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.push(context, MaterialPageRoute(
                                                          builder: (context) => const ClientServicesPage()
                                                      ));
                                                    },
                                                    icon: Icon(PhosphorIcons.arrow_square_out, size: 20, color: Colors.indigo,),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //Dues Widget
                                    if(isAdmin || isAccountant) const SizedBox(height: 10),
                                    if(isAdmin || isAccountant) InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => const ClientServicesPage()
                                        ));
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
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: K.themeColorSecondary,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Icon(PhosphorIcons.currency_inr, color: K.themeColorPrimary,),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text("Dues", style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: K.textGrey,
                                                      ),),
                                                    ],
                                                  ),
                                                ),
                                                Text("₹${dashboard.totalDue}", style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                  color: Colors.red,
                                                ),),
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.push(context, MaterialPageRoute(
                                                        builder: (context) => const CallLogsPage()
                                                    ));
                                                  },
                                                  icon: Icon(PhosphorIcons.arrow_square_out, size: 20, color: Colors.indigo,),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: K.themeColorTertiary1,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        const Text('Due Today', textAlign: TextAlign.center, style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: K.textGrey,
                                                        ),),
                                                        const SizedBox(height: 5),
                                                        Text("${dashboard.dueToday}", style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                          color: Colors.amberAccent,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: K.themeColorTertiary1,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        const Text('Past Dues', textAlign: TextAlign.center, style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: K.textGrey,
                                                        ),),
                                                        const SizedBox(height: 5),
                                                        Text("${dashboard.duePassed}", style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                          color: Colors.redAccent,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            /*const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: K.themeColorTertiary1,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        const Text('Next week', textAlign: TextAlign.center, style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: K.textGrey,
                                                        ),),
                                                        const SizedBox(height: 5),
                                                        Text("${dashboard.dueNextWeek}", style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                          color: Colors.greenAccent,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: K.themeColorTertiary1,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        const Text('Next 30 days', textAlign: TextAlign.center, style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: K.textGrey,
                                                        ),),
                                                        const SizedBox(height: 5),
                                                        Text("${dashboard.dueNextMonth}", style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                          color: Colors.greenAccent,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),*/
                                          ],
                                        ),
                                      ),
                                    ),
                                    //Transaction Widget
                                    if(isAdmin || isAccountant) const SizedBox(height: 10),
                                    if(isAdmin || isAccountant) InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => const TransactionsHistoryPage()
                                        ));
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
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: K.themeColorSecondary,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(PhosphorIcons.coin, color: K.themeColorPrimary,),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Transactions", style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: K.textGrey,
                                                  ),),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) => const CallLogsPage()
                                                ));
                                              },
                                              icon: Icon(PhosphorIcons.arrow_square_out, size: 20, color: Colors.indigo,),
                                            ),
                                          ],
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
                    ),
                    if(isAdmin || isAccountant) ValueListenableBuilder(
                      valueListenable: bloc.serviceDuesState,
                      builder: (context, LoadingState state, _) {
                        if(state==LoadingState.loading) {
                          return const SliverToBoxAdapter(
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
                                      bloc.initAdmin();
                                    },
                                    child: const Text("Retry"),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                        return ValueListenableBuilder(
                          valueListenable: bloc.serviceDues,
                          builder: (context, List<ServiceDetail> dueServices, _) {
                            if(dueServices.isEmpty) {
                              return const SliverToBoxAdapter(child: SizedBox());
                            }
                            return MultiSliver(
                              children: [
                                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20,),
                                  sliver: SliverToBoxAdapter(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: const [
                                              CircleAvatar(
                                                backgroundColor: Colors.white,
                                                child: Icon(PhosphorIcons.user_list, color: K.themeColorPrimary,),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "Clients - Service Amount Due",
                                                style: TextStyle(
                                                  color: K.themeColorPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  letterSpacing: 0
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => const ClientServicesPage()
                                            ));
                                          },
                                          child: const Text("View All",style: TextStyle(
                                            color: K.textGrey,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(child: SizedBox(height: 10)),
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
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(context, MaterialPageRoute(
                                                          builder: (context) => ClientDetailPage(client: ClientDetail(id:dueServices[i].clientId, name: dueServices[i].clientName, phone: dueServices[i].clientPhone),)
                                                      ));
                                                    },
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        ClipOval(
                                                          child: Image.network(
                                                            '${dueServices[i].clientImage}',
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
                                                              Text('${dueServices[i].clientName}', style: const TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 16,
                                                              ),),
                                                              Row(
                                                                children:  [
                                                                  Icon(PhosphorIcons.phone_bold, color: K.textGrey.withOpacity(0.6),size: 12,),
                                                                  const SizedBox(width: 5),
                                                                  Text('${dueServices[i].clientPhone}', style: TextStyle(
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
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            const Text("Due", style: TextStyle(fontSize: 12, color: K.textGrey, fontWeight: FontWeight.w500),),
                                                            Text("₹${(dueServices[i].amount ?? 0) - (dueServices[i].amountPaid ?? 0)}", style: const TextStyle(
                                                              fontSize: 16,
                                                              height: 1,
                                                              color: K.themeColorPrimary,
                                                              fontWeight: FontWeight.w700,
                                                            ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const Text('Service Used', style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.indigo,
                                                      height: 1
                                                  ),),
                                                  const Divider(),
                                                  Row(
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
                                                            Text("${dueServices[i].name}", style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w700,
                                                                color: K.themeColorPrimary,
                                                            ),),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      if(dueServices[i].serviceDate!=null) Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text("on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(dueServices[i].serviceDate ?? ''))}", style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.grey
                                                          ),),
                                                          Text("on ${DateFormat('hh:mm a').format(DateTime.parse(dueServices[i].serviceDate ?? ''))}", style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.grey
                                                          ),),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        );
                                      },
                                      childCount: dueServices.length>2 ? 2: dueServices.length,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        );
                      }
                    ),
                    if(isAdmin || isAccountant) ValueListenableBuilder(
                      valueListenable: bloc.upcomingServiceState,
                      builder: (context, LoadingState state, _) {
                        if(state==LoadingState.loading) {
                          return const SliverToBoxAdapter(
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
                                      bloc.initAdmin();
                                    },
                                    child: const Text("Retry"),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                        return ValueListenableBuilder(
                          valueListenable: bloc.upcomingService,
                          builder: (context, List<ServiceDetail> upcomingServices, _) {
                            if(upcomingServices.isEmpty) {
                              return const SliverToBoxAdapter(child: SizedBox());
                            }
                            return MultiSliver(
                              children: [
                                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20,),
                                  sliver: SliverToBoxAdapter(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: const [
                                              CircleAvatar(
                                                backgroundColor: Colors.white,
                                                child: Icon(PhosphorIcons.user_switch, color: K.themeColorPrimary,),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "Clients - Upcoming Services",
                                                style: TextStyle(
                                                    color: K.themeColorPrimary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    letterSpacing: 0
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => const ClientServicesPage(showUpcoming: true)
                                            ));
                                          },
                                          child: const Text("View All",style: TextStyle(
                                            color: K.textGrey,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(child: SizedBox(height: 10)),
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
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(context, MaterialPageRoute(
                                                          builder: (context) => ClientDetailPage(client: ClientDetail(id:upcomingServices[i].clientId, name: upcomingServices[i].clientName, phone: upcomingServices[i].clientPhone),)
                                                      ));
                                                    },
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        ClipOval(
                                                          child: Image.network(
                                                            '${upcomingServices[i].clientImage}',
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
                                                              Text('${upcomingServices[i].clientName}', style: const TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 16,
                                                              ),),
                                                              Row(
                                                                children:  [
                                                                  Icon(PhosphorIcons.phone_bold, color: K.textGrey.withOpacity(0.6),size: 12,),
                                                                  const SizedBox(width: 5),
                                                                  Text('${upcomingServices[i].clientPhone}', style: TextStyle(
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
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            const Text("Amount", style: TextStyle(fontSize: 12, color: K.textGrey, fontWeight: FontWeight.w500),),
                                                            Text("₹${upcomingServices[i].amount}", style: const TextStyle(
                                                              fontSize: 16,
                                                              height: 1,
                                                              color: K.themeColorPrimary,
                                                              fontWeight: FontWeight.w700,
                                                            ),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const Text('Service Needed', style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.indigo,
                                                      height: 1
                                                  ),),
                                                  const Divider(),
                                                  Row(
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
                                                            Text("${upcomingServices[i].name}", style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w700,
                                                              color: K.themeColorPrimary,
                                                            ),),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      if(upcomingServices[i].serviceDate!=null) Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text("on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(upcomingServices[i].serviceDate ?? ''))}", style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.grey
                                                          ),),
                                                          Text("on ${DateFormat('hh:mm a').format(DateTime.parse(upcomingServices[i].serviceDate ?? ''))}", style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.grey
                                                          ),),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        );
                                      },
                                      childCount: upcomingServices.length>2 ? 2: upcomingServices.length,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        );
                      }
                    ),
                  ],
                );
              }
            );
          }
        ),
      ),
    );
  }
}

