import 'package:flutter_app/src/store/JsonInit.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
part 'CourseScoreJson.g.dart';

const List<String> constCourseType = [
  "○", //	  必	部訂共同必修
  "△", //	必	校訂共同必修
  "☆", //	選	共同選修
  "●", //	  必	部訂專業必修
  "▲", //	  必	校訂專業必修
  "★"]; //	選	專業選修

@JsonSerializable()
class CourseScoreCreditJson{
  GraduationInformationJson graduationInformation;
  List<SemesterCourseScoreJson> semesterCourseScoreList;
  CourseScoreCreditJson({ this.graduationInformation , this.semesterCourseScoreList }){
    graduationInformation = graduationInformation??GraduationInformationJson();
    semesterCourseScoreList = semesterCourseScoreList ?? List();
  }

  SemesterCourseScoreJson getCourseBySemester( SemesterJson semesterJson){
    for(SemesterCourseScoreJson i in semesterCourseScoreList){
      if( i.semester == semesterJson ){
        return i;
      }
    }
    return null;
  }

  List<CourseInfoJson> getCourseInfoList(){
    List<CourseInfoJson> courseInfoList = List();
    for(SemesterCourseScoreJson i in semesterCourseScoreList){
      courseInfoList.addAll(i.courseScoreList);
    }
    return courseInfoList;
  }

  CourseInfoJson getCourseByCourseId(String courseId){
    for(SemesterCourseScoreJson i in semesterCourseScoreList){
      for(CourseInfoJson j in i.courseScoreList) {
        if( courseId == j.courseId ){
          return j;
        }
      }
    }
    return null;
  }

  List<String> getCourseIdList(){
    List<String> courseIdList = List();
    for(SemesterCourseScoreJson i in semesterCourseScoreList){
      for(CourseInfoJson j in i.courseScoreList) {
        courseIdList.add(j.courseId);
      }
    }
    return courseIdList;
  }

  List<SemesterJson> getSemesterList(){
    List<SemesterJson> value;
    for(SemesterCourseScoreJson i in semesterCourseScoreList){
      value.add(i.semester);
    }
    return value;
  }

  factory CourseScoreCreditJson.fromJson(Map<String, dynamic> json) =>
      _$CourseScoreCreditJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseScoreCreditJsonToJson(this);
}



@JsonSerializable()
class GraduationInformationJson {
  int lowCredit; //最低畢業門檻
  int outerDepartmentMacCredit; //外系最多承認學分
  Map<String,int> courseTypeMinCredit;

  GraduationInformationJson({this.lowCredit , this.courseTypeMinCredit , this.outerDepartmentMacCredit }){
    lowCredit = lowCredit ?? 0;
    outerDepartmentMacCredit = outerDepartmentMacCredit ?? 0;
    if( courseTypeMinCredit == null ){
      courseTypeMinCredit = Map();
      for( String type in constCourseType ){
        courseTypeMinCredit[type] = 0;
      }
    }
  }

  factory GraduationInformationJson.fromJson(Map<String, dynamic> json) =>
      _$GraduationInformationJsonFromJson(json);
  Map<String, dynamic> toJson() => _$GraduationInformationJsonToJson(this);

}



@JsonSerializable()
class SemesterCourseScoreJson {
  SemesterJson semester;
  RankJson now;
  RankJson history;
  List<CourseInfoJson> courseScoreList;
  double averageScore; //總平均
  double performanceScore; //操行成績
  double totalCredit; //修習總學分數
  double takeCredit; //實得學分數

  SemesterCourseScoreJson(
      {this.semester,
      this.now,
      this.averageScore,
      this.courseScoreList,
      this.history,
      this.performanceScore,
      this.takeCredit,
      this.totalCredit}) {
    now = now ?? RankJson();
    history = history ?? RankJson();
    courseScoreList = courseScoreList ?? List();
    semester = semester ?? SemesterJson();
    averageScore = averageScore ?? 0;
    performanceScore = performanceScore ?? 0;
    totalCredit = totalCredit ?? 0;
    takeCredit = takeCredit ?? 0;
  }

  bool get isRankEmpty {
    return history.isEmpty && now.isEmpty;
  }

  String getAverageScoreString() {
    return averageScore.toString();
  }

  String getPerformanceScoreString() {
    return performanceScore.toString();
  }

  String getTakeCreditString() {
    return takeCredit.toString();
  }

  String getTotalCreditString() {
    double total = 0;
    for (CourseInfoJson score in courseScoreList) {
      total += score.credit;
    }
    return (totalCredit != 0) ? totalCredit.toString() : total.toString();
  }

  @override
  String toString() {
    return sprintf(
        "---------semester--------     \n%s \n" +
            "---------now--------          \n%s \n" +
            "---------history--------      \n%s \n" +
            "---------courseScore--------  \n%s \n" +
            "averageScore     :%s \n" +
            "performanceScore :%s \n" +
            "totalCredit      :%s \n" +
            "takeCredit       :%s \n",
        [
          semester.toString(),
          now.toString(),
          history.toString(),
          courseScoreList.toString(),
          averageScore.toString(),
          performanceScore.toString(),
          totalCredit.toString(),
          takeCredit.toString()
        ]);
  }

  factory SemesterCourseScoreJson.fromJson(Map<String, dynamic> json) =>
      _$SemesterCourseScoreJsonFromJson(json);
  Map<String, dynamic> toJson() => _$SemesterCourseScoreJsonToJson(this);

}

@JsonSerializable()
class RankJson {
  RankItemJson course;
  RankItemJson department;

  RankJson({this.course, this.department}) {
    course = course ?? RankItemJson();
    department = department ?? RankItemJson();
  }

  bool get isEmpty {
    return course.isEmpty && department.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "---------course--------     \n%s \n" +
            "---------department--------          \n%s \n",
        [course.toString(), department.toString()]);
  }

  factory RankJson.fromJson(Map<String, dynamic> json) =>
      _$RankJsonFromJson(json);
  Map<String, dynamic> toJson() => _$RankJsonToJson(this);

}

@JsonSerializable()
class RankItemJson {
  double rank;
  double total;
  double percentage;

  RankItemJson({this.percentage, this.rank, this.total}) {
    percentage = percentage ?? 0;
    rank = rank ?? 0;
    total = total ?? 0;
  }

  bool get isEmpty {
    return rank == 0 && total == 0 && percentage == 0;
  }

  @override
  String toString() {
    return sprintf(
        "percentage     :%s \n" +
            "rank           :%s \n" +
            "total          :%s \n",
        [
          percentage.toString(),
          rank.toString(),
          total.toString(),
        ]);
  }

  factory RankItemJson.fromJson(Map<String, dynamic> json) =>
      _$RankItemJsonFromJson(json);
  Map<String, dynamic> toJson() => _$RankItemJsonToJson(this);

}

@JsonSerializable()
class CourseInfoJson {
  String courseId;
  String name;
  String score;
  double credit; //學分
  bool isWithdraw;  //是否撤選
  bool isOtherDepartment;  //是否為外系
  String category;

  CourseInfoJson({this.courseId, this.name, this.score, this.credit,this.category,this.isOtherDepartment,this.isWithdraw}) {
    courseId = JsonInit.stringInit(courseId);
    name = JsonInit.stringInit(name);
    score = JsonInit.stringInit(score);
    category = JsonInit.stringInit(category);
    credit = credit ?? 0;
    isWithdraw = isWithdraw ?? false;
    isOtherDepartment = isOtherDepartment ?? false;
  }

  @override
  String toString() {
    return sprintf(
        "name           :%s \n" +
            "score           :%s \n" +
            "credit          :%s \n",
        [
          name.toString(),
          score.toString(),
          credit.toString(),
        ]);
  }

  factory CourseInfoJson.fromJson(Map<String, dynamic> json) =>
      _$CourseInfoJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseInfoJsonToJson(this);


}
