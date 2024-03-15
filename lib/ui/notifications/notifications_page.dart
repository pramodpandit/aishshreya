import 'package:aishshreya/bloc/notification_bloc.dart';
import 'package:aishshreya/data/model/AppNotification.dart';
import 'package:aishshreya/data/repository/app_repository.dart';
import 'package:aishshreya/ui/employee/employee_list.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  late NotificationBloc bloc;

  @override
  void initState() {
    bloc = NotificationBloc(context.read<AppRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.scrollController.addListener(bloc.scrollListener);
    bloc.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(
          color: Colors.black,
        ),),
        backgroundColor: K.themeColorSecondary,
      ),
      backgroundColor: K.themeColorSecondary,
      body: ValueListenableBuilder(
        valueListenable: bloc.notificationState,
        builder: (context, LoadingState state, _) {
          if(state==LoadingState.loading) {
            return Center(
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
                      bloc.getNotifications();
                    },
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }
          return ValueListenableBuilder(
            valueListenable: bloc.notifications,
            builder: (context, List<AppNotification> notifications, _) {
              if(notifications.isEmpty) {
                return const Center(child: Text("No Notifications Available!"));
              }
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: K.themeColorSecondary,
                                        child: Icon(PhosphorIcons.bell),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(notifications[i].title ?? '', style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              // height: 1.2,
                                            ),),
                                            Text(notifications[i].description ?? '', style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: K.textGrey.withOpacity(0.6),
                                              height: 1,
                                            ),),
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
                        childCount: notifications.length,
                      ),
                    ),
                  ),
                  if(state == LoadingState.paginating) const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LoadingIndicator(color: K.themeColorPrimary),
                    ),
                  ),
                ],
              );
            }
          );
        }
      ),
    );
  }
}
