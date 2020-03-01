import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/NewAnnouncementJson.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';


class ISchoolNewAnnouncementTask extends TaskModel {
  static final String taskName = "ISchoolNewAnnouncementTask" +
      CheckCookiesTask.checkISchool +
      CheckCookiesTask.checkCourse;
  static int page;
  ISchoolNewAnnouncementTask(BuildContext context, int inPage)
      : super(context, taskName) {
    page = inPage;
  }

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(
        context, R.current.getISchoolNewAnnouncement);
    NewAnnouncementJsonList value =
        await ISchoolConnector.getNewAnnouncement(page);
    MyProgressDialog.hideProgressDialog();
    if (value != null) {
      for (NewAnnouncementJson item in value.newAnnouncementList) {
        Model.instance.addNewAnnouncement(item);
      }
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
      desc: R.current.getISchoolNewAnnouncementError,
    );
    ErrorDialog(parameter).show();
  }
}
