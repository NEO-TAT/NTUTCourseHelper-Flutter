import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/NewAnnouncementJson.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import '../../../../ui/other/ErrorDialog.dart';
import '../CheckCookiesTask.dart';
import '../TaskModel.dart';

class ISchoolNewAnnouncementDetailTask extends TaskModel {
  static final String taskName =
      "ISchoolNewAnnouncementDetailTask" + CheckCookiesTask.checkISchool;
  static NewAnnouncementJson announcement;
  ISchoolNewAnnouncementDetailTask(
      BuildContext context, NewAnnouncementJson value)
      : super(context, taskName) {
    announcement = value;
  }

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(
        context, R.current.getISchoolNewAnnouncementDetail);
    String value =
        await ISchoolConnector.getNewAnnouncementDetail(announcement.messageId);
    MyProgressDialog.hideProgressDialog();
    if (value != null) {
      announcement.detail = value;
      announcement.isRead = true;
      Model.instance.saveNewAnnouncement();
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.getISchoolNewAnnouncementDetailError,
    );
    ErrorDialog(parameter).show();
  }
}
