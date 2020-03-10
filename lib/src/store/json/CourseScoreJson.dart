import 'package:flutter_app/src/store/JsonInit.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
part 'CourseScoreJson.g.dart';


@JsonSerializable()
class CourseScoreJson {
  SemesterJson semester;
  RankJson now;
  RankJson history;
  List<ScoreJson> courseScoreList;
  double averageScore; //總平均
  double performanceScore; //操行成績
  double totalCredit; //修習總學分數
  double takeCredit; //實得學分數

  CourseScoreJson(
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
    for (ScoreJson score in courseScoreList) {
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

  factory CourseScoreJson.fromJson(Map<String, dynamic> json) =>
      _$CourseScoreJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseScoreJsonToJson(this);

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
class ScoreJson {
  String courseId;
  String name;
  String score;
  double credit; //學分

  ScoreJson({this.courseId, this.name, this.score, this.credit}) {
    courseId = JsonInit.stringInit(courseId);
    name = JsonInit.stringInit(name);
    score = JsonInit.stringInit(score);
    credit = credit ?? 0;
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

  factory ScoreJson.fromJson(Map<String, dynamic> json) =>
      _$ScoreJsonFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreJsonToJson(this);


}
