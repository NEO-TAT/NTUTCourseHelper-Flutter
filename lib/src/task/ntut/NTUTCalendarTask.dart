import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/model/ntut/NTUTCalendarJson.dart';

import '../Task.dart';
import 'NTUTTask.dart';

class NTUTCalendarTask extends NTUTTask<List<NTUTCalendarJson>> {
  final DateTime startTime;
  final DateTime endTime;

  NTUTCalendarTask(this.startTime, this.endTime) : super("NTUTCalendarTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      List<NTUTCalendarJson> value;
      super.onStart(R.current.getCalendar);
      value = await NTUTConnector.getCalendar(startTime, endTime);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super.onError(R.current.getCalendarError);
      }
    }
    return status;
  }
}
