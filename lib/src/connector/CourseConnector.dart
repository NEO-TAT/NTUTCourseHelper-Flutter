//
//  CourseConnector.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:quiver/time.dart';
import 'core/Connector.dart';
import 'core/ConnectorParameter.dart';

enum CourseConnectorStatus {
  LoginSuccess,
  LoginFail,
  ConnectTimeOutError,
  NetworkError,
  UnknownError
}

class CourseConnector {
  static bool _isLogin = false;
  static final String _getLoginCourseUrl =
      "https://nportal.ntut.edu.tw/ssoIndex.do";
  static final String _courseCNHost = "https://aps.ntut.edu.tw/course/tw/";
  static final String _courseENHost = "https://aps.ntut.edu.tw/course/en/";
  static final String _postCourseCNUrl = _courseCNHost + "/Select.jsp";
  static final String _postCourseENUrl = _courseENHost + "/Select.jsp";
  static final String _checkLoginUrl = _courseCNHost + "/Select.jsp";

  static Future<CourseConnectorStatus> login() async {
    String result;
    _isLogin = false;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Map<String, String> data = {
        "apUrl": "https://aps.ntut.edu.tw/course/tw/courseSID.jsp",
        "apOu": "aa_0010-",
        "sso": "true",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };
      parameter = ConnectorParameter(_getLoginCourseUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("input");
      data = Map();
      for (Element node in nodes) {
        String name = node.attributes['name'];
        String value = node.attributes['value'];
        data[name] = value;
      }
      String jumpUrl =
          tagNode.getElementsByTagName("form")[0].attributes["action"];
      parameter = ConnectorParameter(jumpUrl);
      parameter.data = data;
      await Connector.getDataByPostResponse(parameter);
      _isLogin = true;
      return CourseConnectorStatus.LoginSuccess;
    } catch (e) {
      Log.e(e.toString());
      return CourseConnectorStatus.LoginFail;
    }
  }

  static Future<CourseExtraInfoJson> getCourseExtraInfo(String courseId) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> courseNodes, nodes, classmateNodes;
      Map<String, String> data = {
        "code": courseId,
        "format": "-1",
      };
      parameter = ConnectorParameter(_postCourseCNUrl);
      parameter.data = data;
      parameter.charsetName = 'big5';
      String result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      courseNodes = tagNode.getElementsByTagName("table");

      CourseExtraInfoJson courseExtraInfo = CourseExtraInfoJson();

      //取得學期資料
      nodes = courseNodes[0].getElementsByTagName("td");
      SemesterJson semester = SemesterJson();
      semester.year = nodes[1].text;
      semester.semester = nodes[2].text;

      courseExtraInfo.courseSemester = semester;

      CourseExtraJson courseExtra = CourseExtraJson();

      courseExtra.name = nodes[3].getElementsByTagName("a")[0].text;
      courseExtra.category = nodes[7].text; // 取得類別
      courseExtra.selectNumber = nodes[11].text;
      courseExtra.withdrawNumber = nodes[12].text;
      courseExtra.id = courseId;

      courseExtraInfo.course = courseExtra;

      nodes = courseNodes[2].getElementsByTagName("tr");
      for (int i = 1; i < nodes.length; i++) {
        node = nodes[i];
        classmateNodes = node.getElementsByTagName("td");
        ClassmateJson classmate = ClassmateJson();
        classmate.className = classmateNodes[0].text;
        classmate.studentId =
            classmateNodes[1].getElementsByTagName("a")[0].text;
        classmate.href = _courseCNHost +
            classmateNodes[1].getElementsByTagName("a")[0].attributes["href"];
        classmate.studentName = classmateNodes[2].text;
        classmate.studentEnglishName = classmateNodes[3].text;
        classmate.isSelect = !classmateNodes[4].text.contains("撤選");
        courseExtraInfo.classmate.add(classmate);
      }
      return courseExtraInfo;
    } catch (e) {
      //throw e;
      Log.e(e.toString());
      return null;
    }
  }

  static Future<List<SemesterJson>> getCourseSemester(String studentId) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> nodes;

      Map<String, String> data = {
        "code": studentId,
        "format": "-3",
      };
      parameter = ConnectorParameter(_postCourseCNUrl);
      parameter.data = data;
      parameter.charsetName = 'big5';
      Response response = await Connector.getDataByPostResponse(parameter);
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[0];
      nodes = node.getElementsByTagName("tr");
      List<SemesterJson> semesterJsonList = List();
      for (int i = 1; i < nodes.length; i++) {
        node = nodes[i];
        String year, semester;
        year = node.getElementsByTagName("a")[0].text.split(" ")[0];
        semester = node.getElementsByTagName("a")[0].text.split(" ")[2];
        semesterJsonList.add(SemesterJson(year: year, semester: semester));
      }
      return semesterJsonList;
    } catch (e) {
      //throw e;
      Log.e(e.toString());
      return null;
    }
  }

  static String strQ2B(String input) {
    List<int> newString = List();
    for (int c in input.codeUnits) {
      if (c == 12288) {
        c = 32;
        continue;
      }
      if (c > 65280 && c < 65375) {
        c = (c - 65248);
      }
      newString.add(c);
    }
    return String.fromCharCodes(newString);
  }

  static Future<List<CourseMainInfoJson>> getENCourseMainInfoList(
      String studentId, SemesterJson semester) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> courseNodes, nodesOne, nodes;
      List<Day> dayEnum = [
        Day.Sunday,
        Day.Monday,
        Day.Tuesday,
        Day.Wednesday,
        Day.Thursday,
        Day.Friday,
        Day.Saturday
      ];
      Map<String, String> data = {
        "code": studentId,
        "format": "-2",
        "year": semester.year,
        "sem": semester.semester,
      };
      parameter = ConnectorParameter(_postCourseENUrl);
      parameter.data = data;
      parameter.charsetName = 'big5';
      Response response = await Connector.getDataByPostResponse(parameter);
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[1];
      courseNodes = node.getElementsByTagName("tr");

      List<CourseMainInfoJson> courseMainInfoList = List();
      for (int i = 2; i < courseNodes.length - 1; i++) {
        CourseMainInfoJson courseMainInfo = CourseMainInfoJson();
        CourseMainJson courseMain = CourseMainJson();
        nodesOne = courseNodes[i].getElementsByTagName("td");
        if (nodesOne[16].text.contains("Withdraw")) {
          continue;
        }
        //取得課號
        courseMain.id = nodesOne[0].text.replaceAll("\n", "");
        //取的課程名稱/課程連結
        nodes = nodesOne[1].getElementsByTagName("a"); //確定是否有連結
        if (nodes.length >= 1) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }
        courseMain.credits = nodesOne[2].text.replaceAll("\n", ""); //學分
        courseMain.hours = nodesOne[3].text.replaceAll("\n", ""); //時數

        //時間
        for (int j = 0; j < 7; j++) {
          Day day = dayEnum[j]; //要做變換網站是從星期日開始
          String time = nodesOne[j + 6].text;
          time = strQ2B(time);
          courseMain.time[day] = time;
        }

        courseMainInfo.course = courseMain;

        int length;
        //取得老師名稱
        length = nodesOne[4].innerHtml.split("<br>").length;
        for (String name in nodesOne[4].innerHtml.split("<br>")) {
          TeacherJson teacher = TeacherJson();
          teacher.name = name.replaceAll("\n", "");
          courseMainInfo.teacher.add(teacher);
        }

        //取得教室名稱
        length = nodesOne[13].innerHtml.split("<br>").length;
        for (String name
            in nodesOne[13].innerHtml.split("<br>").getRange(0, length - 1)) {
          ClassroomJson classroom = ClassroomJson();
          classroom.name = name.replaceAll("\n", "");
          courseMainInfo.classroom.add(classroom);
        }

        //取得開設教室名稱
        for (Element node in nodesOne[5].getElementsByTagName("a")) {
          ClassJson classInfo = ClassJson();
          classInfo.name = node.text;
          classInfo.href = _courseCNHost + node.attributes["href"];
          courseMainInfo.openClass.add(classInfo);
        }
        courseMainInfoList.add(courseMainInfo);
      }

      return courseMainInfoList;
    } catch (e) {
      //throw e;
      Log.e(e.toString());
      return null;
    }
  }

  static Future<List<CourseMainInfoJson>> getTWCourseMainInfoList(
      String studentId, SemesterJson semester) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> courseNodes, nodesOne, nodes;
      List<Day> dayEnum = [
        Day.Sunday,
        Day.Monday,
        Day.Tuesday,
        Day.Wednesday,
        Day.Thursday,
        Day.Friday,
        Day.Saturday
      ];
      Map<String, String> data = {
        "code": studentId,
        "format": "-2",
        "year": semester.year,
        "sem": semester.semester,
      };
      parameter = ConnectorParameter(_postCourseCNUrl);
      parameter.data = data;
      parameter.charsetName = 'big5';
      Response response = await Connector.getDataByPostResponse(parameter);
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[1];
      courseNodes = node.getElementsByTagName("tr");

      List<CourseMainInfoJson> courseMainInfoList = List();
      for (int i = 2; i < courseNodes.length - 1; i++) {
        CourseMainInfoJson courseMainInfo = CourseMainInfoJson();
        CourseMainJson courseMain = CourseMainJson();
        nodesOne = courseNodes[i].getElementsByTagName("td");
        if (nodesOne[16].text.contains("撤選")) {
          continue;
        }
        //取得課號
        nodes = nodesOne[0].getElementsByTagName("a"); //確定是否有課號
        if (nodes.length >= 1) {
          courseMain.id = nodes[0].text;
          courseMain.href = _courseCNHost + nodes[0].attributes["href"];
        }
        //取的課程名稱/課程連結
        nodes = nodesOne[1].getElementsByTagName("a"); //確定是否有連結
        if (nodes.length >= 1) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }
        courseMain.stage = nodesOne[2].text.replaceAll("\n", ""); //階段
        courseMain.credits = nodesOne[3].text.replaceAll("\n", ""); //學分
        courseMain.hours = nodesOne[4].text.replaceAll("\n", ""); //時數
        courseMain.note = nodesOne[20].text.replaceAll("\n", ""); //備註
        if (nodesOne[19].getElementsByTagName("a").length > 0) {
          courseMain.scheduleHref = _courseCNHost +
              nodesOne[19]
                  .getElementsByTagName("a")[0]
                  .attributes["href"]; //教學進度大綱
        }

        //時間
        for (int j = 0; j < 7; j++) {
          Day day = dayEnum[j]; //要做變換網站是從星期日開始
          String time = nodesOne[j + 8].text;
          time = strQ2B(time);
          courseMain.time[day] = time;
        }

        courseMainInfo.course = courseMain;

        //取得老師名稱
        for (Element node in nodesOne[6].getElementsByTagName("a")) {
          TeacherJson teacher = TeacherJson();
          teacher.name = node.text;
          teacher.href = _courseCNHost + node.attributes["href"];
          courseMainInfo.teacher.add(teacher);
        }

        //取得教室名稱
        for (Element node in nodesOne[15].getElementsByTagName("a")) {
          ClassroomJson classroom = ClassroomJson();
          classroom.name = node.text;
          classroom.href = _courseCNHost + node.attributes["href"];
          courseMainInfo.classroom.add(classroom);
        }

        //取得開設教室名稱
        for (Element node in nodesOne[7].getElementsByTagName("a")) {
          ClassJson classInfo = ClassJson();
          classInfo.name = node.text;
          classInfo.href = _courseCNHost + node.attributes["href"];
          courseMainInfo.openClass.add(classInfo);
        }

        courseMainInfoList.add(courseMainInfo);
      }

      return courseMainInfoList;
    } catch (e) {
      //throw e;
      Log.e(e.toString());
      return null;
    }
  }

  static Future<Map> getGraduation(String year, String department) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    RegExp exp;
    RegExpMatch matches;
    Map graduationMap = Map();
    try {
      parameter =
          ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp");
      parameter.charsetName = "big5";
      parameter.data = {"format": "-3", "year": year, "matric": "7"};
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("tbody").first;
      nodes = node.getElementsByTagName("tr");
      String href;
      for (int i = 1; i < nodes.length; i++) {
        node = nodes[i];
        node = node.getElementsByTagName("a").first;
        if (node.text.contains(department)) {
          href = node.attributes["href"];
          break;
        }
      }
      href = "https://aps.ntut.edu.tw/course/tw/" + href;
      parameter = ConnectorParameter(href);
      parameter.charsetName = "big5";
      result = await Connector.getDataByGet(parameter);

      exp = RegExp(r"最低畢業學分：(\d+)學分");
      matches = exp.firstMatch(result);
      graduationMap["lowCredit"] = int.parse(matches.group(1));

      exp = RegExp(r"共同必修：(\d+)學分");
      matches = exp.firstMatch(result);
      graduationMap["△"] = int.parse(matches.group(1));

      exp = RegExp(r"專業必修：(\d+)學分");
      matches = exp.firstMatch(result);
      graduationMap["▲"] = int.parse(matches.group(1));

      exp = RegExp(r"專業選修：(\d+)學分");
      matches = exp.firstMatch(result);
      graduationMap["★"] = int.parse(matches.group(1));

      /*
      exp = RegExp("通識博雅課程應修滿(\d+)學分");
      matches = exp.firstMatch(result);
      exp = RegExp("跨系所專業選修(\d+)學分為畢業學分");
      matches = exp.firstMatch(result);
      */
      return graduationMap;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Future<List<String>> getYearList() async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<String> resultList = List();
    try {
      parameter =
          ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp");
      parameter.data = {"format": "-1"};
      parameter.charsetName = "big5";
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("a");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        resultList.add(node.text);
      }
      return resultList;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Future<List<Map>> getDivisionList(String year) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<Map> resultList = List();
    try {
      parameter =
          ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp");
      parameter.data = {"format": "-2" , "year": year};
      parameter.charsetName = "big5";
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("a");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        Map<String , String> code = Uri.parse(node.attributes["href"]).queryParameters;
        resultList.add( {"name" : node.text , "code" :code });
      }
      return resultList;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }


  static Future<List<Map>> getDepartmentList(Map code) async{
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<Map> resultList = List();
    try {
      parameter =
          ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp");
      parameter.data = code;
      Log.d( code.toString() );
      parameter.charsetName = "big5";
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("table").first;
      nodes = node.getElementsByTagName("a");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        Map<String , String> code = Uri.parse(node.attributes["href"]).queryParameters;
        Log.d( code.toString() );
        resultList.add( {"name" : node.text.replaceAll(RegExp("[ |\s]"), "") , "code" :code });
      }
      return resultList;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static bool get isLogin {
    return _isLogin;
  }

  static void loginFalse() {
    _isLogin = false;
  }

  static Future<bool> checkLogin() async {
    Log.d("Course CheckLogin");
    ConnectorParameter parameter;
    _isLogin = false;
    try {
      parameter = ConnectorParameter(_checkLoginUrl);
      parameter.charsetName = "big5";
      String result = await Connector.getDataByGet(parameter);
      if (result.isEmpty || result.contains("尚未登錄入口網站")) {
        return false;
      } else {
        Log.d("Course Is Readly Login");
        _isLogin = true;
        return true;
      }
    } catch (e) {
      //throw e;
      Log.e(e.toString());
      return false;
    }
  }
}
