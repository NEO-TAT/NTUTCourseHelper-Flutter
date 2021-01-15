import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';

import '../Task.dart';
import 'CourseSystemTask.dart';

class CourseDepartmentTask extends CourseSystemTask<List<Map>> {
  final code;

  CourseDepartmentTask(this.code) : super("CourseDepartmentTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.searchingDepartment);
      List<Map> value = await CourseConnector.getDepartmentList(code);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return TaskStatus.GiveUp;
      }
    }
    return status;
  }
}
