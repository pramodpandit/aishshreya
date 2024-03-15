import 'package:aishshreya/bloc/employee_detail_bloc.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/data/repository/lead_repository.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/auth/login_page.dart';
import 'package:aishshreya/ui/call_logs/call_logs_page.dart';
import 'package:aishshreya/ui/clients/client_page.dart';
import 'package:aishshreya/ui/employee/edit_employee.dart';
import 'package:aishshreya/ui/employee/employee_list.dart';
import 'package:aishshreya/ui/leads/leads_list_page.dart';
import 'package:aishshreya/ui/services/due_amount_services_list.dart';
import 'package:aishshreya/ui/services/service_list.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:aishshreya/data/network/api_service.dart';
import 'package:aishshreya/utils/image_icons.dart';
import 'package:aishshreya/utils/user_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  late final EmployeeDetailBloc bloc;

  @override
  void initState() {

    bloc = EmployeeDetailBloc(UserDetail(), context.read<EmployeeRepository>(), context.read<LeadsRepository>(), context.read<ServiceRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.editEmployeeStream.stream.listen((event) {
      if(event=="SUCCESS") {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });
    bloc.initOwnDetails();
  }


  @override
  Widget build(BuildContext context) {
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
        debugPrint('${pref.getString('image')}');
        return Drawer(
          child: SafeArea(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(pref.getString('name') ?? ''),
                  accountEmail: Text(pref.getString('email') ?? ''),
                  currentAccountPicture: ClipOval(
                    child: Image.network(
                      pref.getString('image') ?? '',
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => const CircleAvatar(
                        radius: 72/2,
                        child: Icon(PhosphorIcons.user, color: Colors.white,),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Provider.value(
                          value: bloc,
                          child: const EditEmployeePage(editingOwn: true),
                        )
                    ));
                  },
                  title: const Text("Profile"),
                ),
                if(isAdmin) ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const EmployeeList()
                    ));
                  },
                  title: const Text("Employees"),
                ),
                if(isAccountant || isAdmin) ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const ClientListPage()
                    ));
                  },
                  title: const Text("Clients"),
                ),
                if(isAdmin || isEmp) ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const LeadsListPage()
                    ));
                  },
                  title: const Text("Leads"),
                ),
                if(isAdmin) ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const CallLogsPage()
                    ));
                  },
                  title: const Text("Call Logs"),
                ),
                if(isAccountant || isAdmin) ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const ClientServicesPage()
                    ));
                  },
                  title: const Text("Services"),
                ),
                // if(isAccountant || isAdmin) ListTile(
                //   onTap: () {
                //     Navigator.push(context, MaterialPageRoute(
                //         builder: (context) => const ClientDueServicesPage()
                //     ));
                //   },
                //   title: const Text("Due Client Services"),
                // ),
                const Divider(),
                ListTile(
                  onTap: () {
                    SharedPreferences pref = context.read<SharedPreferences>();
                    pref.clear();
                    Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.route, (route) => false);
                  },
                  title: const Text("Logout" ,style:  TextStyle(
                    color: Colors.red,
                  ),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
