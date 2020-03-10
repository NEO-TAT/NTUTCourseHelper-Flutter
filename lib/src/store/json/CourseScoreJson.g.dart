// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseScoreJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseScoreCreditJson _$CourseScoreCreditJsonFromJson(
    Map<String, dynamic> json) {
  return CourseScoreCreditJson(
    graduationInformation: json['graduationInformation'] == null
        ? null
        : GraduationInformationJson.fromJson(
            json['graduationInformation'] as Map<String, dynamic>),
    semesterCourseScoreList: (json['semesterCourseScoreList'] as List)
        ?.map((e) => e == null
            ? null
            : SemesterCourseScoreJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CourseScoreCreditJsonToJson(
        CourseScoreCreditJson instance) =>
    <String, dynamic>{
      'graduationInformation': instance.graduationInformation,
      'semesterCourseScoreList': instance.semesterCourseScoreList,
    };

GraduationInformationJson _$GraduationInformationJsonFromJson(
    Map<String, dynamic> json) {
  return GraduationInformationJson(
    lowCredit: json['lowCredit'] as int,
    courseTypeMinCredit:
        (json['courseTypeMinCredit'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    outerDepartmentMacCredit: json['outerDepartmentMacCredit'] as int,
  );
}

Map<String, dynamic> _$GraduationInformationJsonToJson(
        GraduationInformationJson instance) =>
    <String, dynamic>{
      'lowCredit': instance.lowCredit,
      'outerDepartmentMacCredit': instance.outerDepartmentMacCredit,
      'courseTypeMinCredit': instance.courseTypeMinCredit,
    };

SemesterCourseScoreJson _$SemesterCourseScoreJsonFromJson(
    Map<String, dynamic> json) {
  return SemesterCourseScoreJson(
    semester: json['semester'] == null
        ? null
        : SemesterJson.fromJson(json['semester'] as Map<String, dynamic>),
    now: json['now'] == null
        ? null
        : RankJson.fromJson(json['now'] as Map<String, dynamic>),
    averageScore: (json['averageScore'] as num)?.toDouble(),
    courseScoreList: (json['courseScoreList'] as List)
        ?.map((e) => e == null
            ? null
            : CourseInfoJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    history: json['history'] == null
        ? null
        : RankJson.fromJson(json['history'] as Map<String, dynamic>),
    performanceScore: (json['performanceScore'] as num)?.toDouble(),
    takeCredit: (json['takeCredit'] as num)?.toDouble(),
    totalCredit: (json['totalCredit'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$SemesterCourseScoreJsonToJson(
        SemesterCourseScoreJson instance) =>
    <String, dynamic>{
      'semester': instance.semester,
      'now': instance.now,
      'history': instance.history,
      'courseScoreList': instance.courseScoreList,
      'averageScore': instance.averageScore,
      'performanceScore': instance.performanceScore,
      'totalCredit': instance.totalCredit,
      'takeCredit': instance.takeCredit,
    };

RankJson _$RankJsonFromJson(Map<String, dynamic> json) {
  return RankJson(
    course: json['course'] == null
        ? null
        : RankItemJson.fromJson(json['course'] as Map<String, dynamic>),
    department: json['department'] == null
        ? null
        : RankItemJson.fromJson(json['department'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RankJsonToJson(RankJson instance) => <String, dynamic>{
      'course': instance.course,
      'department': instance.department,
    };

RankItemJson _$RankItemJsonFromJson(Map<String, dynamic> json) {
  return RankItemJson(
    percentage: (json['percentage'] as num)?.toDouble(),
    rank: (json['rank'] as num)?.toDouble(),
    total: (json['total'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$RankItemJsonToJson(RankItemJson instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'total': instance.total,
      'percentage': instance.percentage,
    };

CourseInfoJson _$CourseInfoJsonFromJson(Map<String, dynamic> json) {
  return CourseInfoJson(
    courseId: json['courseId'] as String,
    name: json['name'] as String,
    score: json['score'] as String,
    credit: (json['credit'] as num)?.toDouble(),
    courseType: json['courseType'] as String,
    isOtherDepartment: json['isOtherDepartment'] as bool,
    isWithdraw: json['isWithdraw'] as bool,
  );
}

Map<String, dynamic> _$CourseInfoJsonToJson(CourseInfoJson instance) =>
    <String, dynamic>{
      'courseId': instance.courseId,
      'name': instance.name,
      'score': instance.score,
      'credit': instance.credit,
      'isWithdraw': instance.isWithdraw,
      'isOtherDepartment': instance.isOtherDepartment,
      'courseType': instance.courseType,
    };
