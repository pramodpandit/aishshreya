import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../data/repository/app_repository.dart';
import '../utils/enums.dart';
import 'bloc.dart';

class AppBloc extends Bloc {
  final AppRepository _repo;

  AppBloc(this._repo);

  ValueNotifier<LoadingState> aboutState = ValueNotifier(LoadingState.done);

/*  ValueNotifier<bool> loading = ValueNotifier(false);
  String? aboutUs, pp, tnc;

  getAppDetails() async {
    try{
      loading.value = true;
      ApiResponse<AppDetail?> res = await _repo.getAppDetails();
      if(res.status) {
        aboutUs = res.data!.about;
        pp = res.data!.pp;
        tnc = res.data!.tnc;
      } else {
        showMessage(MessageType.error(res.message));
      }
    } catch(e,s) {
      print(e);
      print(s);
      showMessage(MessageType.error(e.toString()));
    } finally {
      loading.value = false;
    }
  }

  List<AppVersionData> appVersion = [];

  StreamController<String> updateAppStream = StreamController.broadcast();
  String? updateLink;


  Future getAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentAppVersion = packageInfo.version;
      ApiResponse<List<AppVersionData>> response = await _repo.getAppVersion();

      if (response.status) {
        appVersion = response.data ?? [];
        if(appVersion.isNotEmpty) {
          if(Platform.isAndroid) {
            AppVersionData? data = appVersion.where((data) => data.platform=='android').first;
            if(data!=null && data.buildNumber!=currentAppVersion) {
              updateLink = data.updateLink;
              updateAppStream.sink.add('updateAvailable');
            }
          } else if(Platform.isIOS) {
            AppVersionData? data = appVersion.where((data) => data.platform=='ios').first;
            if(data!=null && data.buildNumber!=currentAppVersion) {
              updateLink = data.updateLink;
              updateAppStream.sink.add('updateAvailable');
            }
          }
        }
      } else {
        print('response.message ${response.message}');
        // showMessage(MessageType.error(response.message));
      }
    } on ApiException catch (apiError) {
      print('apiError.message ${apiError.message}');
      // showMessage(MessageType.error(apiError.message));
    } catch (e, s) {
      print(e);
      print(s);
      // showMessage(const MessageType.error("Something went wrong!"));
    }
  }*/

}