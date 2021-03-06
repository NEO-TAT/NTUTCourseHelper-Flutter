import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusGetCourseSubscribeTask
    extends IPlusSystemTask<Map<String, dynamic>> {
  final id;

  IPlusGetCourseSubscribeTask(this.id) : super("IPlusGetCourseSubscribeTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.searchSubscribe);
      String courseBid = await ISchoolPlusConnector.getBid(id);
      bool openNotifications =
          await ISchoolPlusConnector.getCourseSubscribe(courseBid);
      super.onEnd();
      result = {"courseBid": courseBid, "openNotifications": openNotifications};
      return TaskStatus.Success;
    }
    return status;
  }
}
