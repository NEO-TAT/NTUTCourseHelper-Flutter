import 'package:auto_size_text/auto_size_text.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/costants/app_colors.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseScoreJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/TaskModelFunction.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/score/ScoreRankTask.dart';
import 'package:flutter_app/ui/other/AppExpansionTile.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/score/GraduationPicker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sprintf/sprintf.dart';

class ScoreViewerPage extends StatefulWidget {
  @override
  _ScoreViewerPageState createState() => _ScoreViewerPageState();
}

class _ScoreViewerPageState extends State<ScoreViewerPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  bool isLoading = true;
  List<SemesterCourseScoreJson> courseScoreList = List();
  CourseScoreCreditJson courseScoreCredit;
  ScrollController _scrollController = ScrollController();
  int _currentTabIndex = 0;
  List<Widget> tabLabelList = List();
  List<Widget> tabChildList = List();

  @override
  void initState() {
    super.initState();
    courseScoreCredit = Model.instance.getCourseScoreCredit();
    courseScoreList = Model.instance.getSemesterCourseScore();
    if (courseScoreList.length == 0) {
      _addScoreRankTask();
    } else {
      _buildTabBar();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addScoreRankTask() async {
    courseScoreList = List();
    setState(() {
      isLoading = true;
    });
    TaskHandler.instance.addTask(ScoreRankTask(context));
    await TaskHandler.instance.startTaskQueue(context);
    courseScoreList = Model.instance.getTempData(ScoreRankTask.tempDataKey);
    if (courseScoreList != null) {
      await Model.instance.setSemesterCourseScore(courseScoreList);
    }
    courseScoreList = courseScoreList ?? List();
    _buildTabBar();
    setState(() {
      isLoading = false;
    });
  }

  void _onSelectFinish(GraduationInformationJson value) {
    Log.d(value.toString());
    if (value != null) {
      courseScoreCredit.graduationInformation = value;
      Model.instance.setCourseScoreCredit(courseScoreCredit);
      Model.instance.saveCourseScoreCredit();
    }
    _buildTabBar();
  }

  void _addSearchCourseTypeTask() async {
    TaskHandler.instance.addTask(TaskModelFunction(context,
        require: [CheckCookiesTask.checkCourse], taskFunction: () async {
      List<CourseInfoJson> courseInfoList =
          courseScoreCredit.getCourseInfoList();
      int total = courseScoreCredit.getCourseInfoList().length;
      for (int i = 0; i < total; i++) {
        CourseInfoJson courseInfo = courseInfoList[i];
        String courseId = courseInfo.courseId;
        if (courseInfo.category.isEmpty) {
          //沒有類別才尋找
          CourseConnector.getCourseExtraInfo(courseId).then((courseExtraInfo) {
            courseScoreCredit.getCourseByCourseId(courseId);
            courseInfo.category = courseExtraInfo.course.category;
            courseInfo.openClass =
                courseExtraInfo.course.openClass.replaceAll("\n", " ");
            Log.d(courseInfo.openClass);
          });
        }
      }
      return true;
    }, errorFunction: () async {
      ErrorDialogParameter parameter = ErrorDialogParameter(
        context: context,
        desc: "錯誤",
      );
      ErrorDialog(parameter).show();
    }, successFunction: () async {}));
    await TaskHandler.instance.startTaskQueue(context);
    GraduationPicker picker = GraduationPicker(context);
    picker.show(_onSelectFinish);
    _buildTabBar();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabLabelList.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('成績查詢'),
          actions: [
            if (courseScoreList.length > 0)
              Padding(
                padding: EdgeInsets.only(
                  right: 20,
                ),
                child: InkWell(
                  onTap: () {
                    _addSearchCourseTypeTask();
                  },
                  child: Icon(EvaIcons.searchOutline),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                right: 20,
              ),
              child: InkWell(
                onTap: () {
                  _addScoreRankTask();
                },
                child: Icon(EvaIcons.refreshOutline),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.mainColor,
            unselectedLabelColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
//      labelPadding: EdgeInsets.symmetric(horizontal: 8),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.white,
            ),
            isScrollable: true,
            tabs: tabLabelList,
            onTap: (int index) {
              _currentTabIndex = index;
              setState(() {});
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (!isLoading)
                (tabChildList.length > 0)
                    ? tabChildList[_currentTabIndex]
                    : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void _buildTabBar() {
    tabLabelList = List();
    tabChildList = List();
    if (courseScoreCredit.graduationInformation.isSelect) {
      tabLabelList.add(_buildTabLabel("學分總覽"));
      tabChildList.add(Container(
        child: Column(
          children: <Widget>[
            _buildSummary(),
            _buildGeneralLessonItem(),
            _buildOtherDepartmentItem(),
            _buildWarning(),
          ],
        ),
      ));
    }
    for (int i = 0; i < courseScoreList.length; i++) {
      SemesterCourseScoreJson courseScore = courseScoreList[i];
      tabLabelList.add(_buildTabLabel(
          "${courseScore.semester.year}-${courseScore.semester.semester}"));
      tabChildList.add(_buildSemesterScores(courseScore));
    }
    if (_tabController != null) {
      if (tabChildList.length != _tabController.length) {
        _tabController.dispose();
        _tabController =
            TabController(length: tabChildList.length, vsync: this);
      }
    } else {
      _tabController = TabController(length: tabChildList.length, vsync: this);
    }
    _currentTabIndex = 0;
    _tabController.animateTo(_currentTabIndex);
    setState(() {});
  }

  Widget _buildTabLabel(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Tab(
        text: title,
      ),
    );
  }

  Widget _buildTile(String title) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: new Material(
        //INK可以實現裝飾容器
        child: new Ink(
          //用ink圓角矩形
          // color: Colors.red,
          decoration: new BoxDecoration(
            //背景
            color: Colors.white,
            //設置四周圓角 角度
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            //設置四周邊框
            border: new Border.all(width: 1, color: Colors.red),
          ),
          child: new InkWell(
            //圓角設置,給水波紋也設置同樣的圓角
            //如果這裡不設置就會出現矩形的水波紋效果
            borderRadius: new BorderRadius.circular(25.0),
            child: Container(
              //設置 child 居中
              alignment: Alignment(0, 0),
              height: 50,
              width: 300,
              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    List<Widget> widgetList = List();
    GraduationInformationJson graduationInformation =
        courseScoreCredit.graduationInformation;
    Widget widget = _buildTile(sprintf("學分總覽 %d/%d", [
      courseScoreCredit.getTotalCourseCredit(),
      graduationInformation.lowCredit
    ]));
    widgetList.add(_buildType("○", "部訂共同必修"));
    widgetList.add(_buildType("△", "校訂共同必修"));
    widgetList.add(_buildType("☆", "共同選修"));
    widgetList.add(_buildType("●", "部訂專業必修"));
    widgetList.add(_buildType("▲", "校訂專業必修"));
    widgetList.add(_buildType("★", "專業選修"));
    return Container(
      child: AppExpansionTile(
        title: widget,
        children: widgetList,
        initiallyExpanded: true,
      ),
    );
  }

  Widget _buildType(String type, String title) {
    int nowCredit = courseScoreCredit.getCreditByType(type);
    int minCredit =
        courseScoreCredit.graduationInformation.courseTypeMinCredit[type];
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(sprintf("%s%s :", [
                type,
                title,
              ])),
            ),
            Text(sprintf("%d/%d", [nowCredit, minCredit]))
          ],
        ),
      ),
      onTap: () {
        Map<String, List<CourseInfoJson>> result =
            courseScoreCredit.getCourseByType(type);
        String pr = "";
        for (String key in result.keys.toList()) {
          pr += "\n$key";
          for (CourseInfoJson course in result[key]) {
            pr += (course.name + " ");
          }
        }
        pr = pr.substring(1,pr.length);
        MyToast.show(pr);
        Log.d(pr);
      },
    );
  }

  Widget _buildOneLineCourse(String name, String openClass) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(name),
          ),
          Text(openClass)
        ],
      ),
    );
  }

  Widget _buildGeneralLessonItem() {
    Map<String, List<CourseInfoJson>> generalLesson =
        courseScoreCredit.getGeneralLesson();
    List<Widget> widgetList = List();
    int selectCredit = 0;
    int coreCredit = 0;
    for (String key in generalLesson.keys) {
      for (CourseInfoJson course in generalLesson[key]) {
        if (course.isCoreGeneralLesson) {
          coreCredit += course.credit.toInt();
        } else {
          selectCredit += course.credit.toInt();
        }
        Widget courseItemWidget;
        courseItemWidget = _buildOneLineCourse(course.name, course.openClass);
        widgetList.add(courseItemWidget);
      }
    }
    Widget titleWidget =
        _buildTile(sprintf("博雅總覽 實得核心:%d 實得選修:%d", [coreCredit, selectCredit]));
    return Container(
      child: AppExpansionTile(
        title: titleWidget,
        children: widgetList,
        initiallyExpanded: true,
      ),
    );
  }

  Widget _buildOtherDepartmentItem() {
    String department =
        Model.instance.getGraduationInformation().selectDepartment;
    int otherDepartmentMaxCredit = courseScoreCredit.graduationInformation.outerDepartmentMaxCredit;
    department = department.substring(0, 2);
    Log.d(department);
    Map<String, List<CourseInfoJson>> generalLesson =
        courseScoreCredit.getOtherDepartmentCourse(department);
    List<Widget> widgetList = List();
    int otherDepartmentCredit = 0;
    for (String key in generalLesson.keys) {
      for (CourseInfoJson course in generalLesson[key]) {
        otherDepartmentCredit += course.credit.toInt();
        Widget courseItemWidget;
        courseItemWidget = courseItemWidget =
            _buildOneLineCourse(course.name, course.openClass);
        widgetList.add(courseItemWidget);
      }
    }
    Widget titleWidget =
        _buildTile(sprintf("外系學分: %d/%d", [otherDepartmentCredit ,otherDepartmentMaxCredit ]));
    return Container(
      child: AppExpansionTile(
        title: titleWidget,
        children: widgetList,
        initiallyExpanded: true,
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "此計算僅供參考，實際請以學校為主",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterScores(SemesterCourseScoreJson courseScore) {
    return Container(
      padding: EdgeInsets.all(24.0),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: <Widget>[
              ..._buildCourseScores(courseScore),
              SizedBox(height: 16),
              ..._buildSemesterScore(courseScore),
              SizedBox(height: 16),
              ..._buildRanks(courseScore),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCourseScores(SemesterCourseScoreJson courseScore) {
    List<CourseInfoJson> scoreList = courseScore.courseScoreList;
    return [
      _buildTitle('各科成績'),
      for (CourseInfoJson score in scoreList) _buildScoreItem(score),
    ];
  }

  Widget _buildScoreItem(CourseInfoJson score) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                score.name,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            if (score.category.isNotEmpty)
              Text(
                score.category,
                style: TextStyle(fontSize: 16.0),
              ),
            Container(
              width: 40,
              child: Text(score.score,
                  style: TextStyle(fontSize: 16.0), textAlign: TextAlign.end),
            ),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
      ],
    );
  }

  List<Widget> _buildSemesterScore(SemesterCourseScoreJson courseScore) {
    return [
      _buildTitle('學期成績'),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            sprintf("總平均: %s", [courseScore.getAverageScoreString()]),
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          Text(
            sprintf("操行成績: %s", [courseScore.getPerformanceScoreString()]),
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 8,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            sprintf("修習學分: %s", [courseScore.getTotalCreditString()]),
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          Text(
            sprintf("實得學分: %s", [courseScore.getTotalCreditString()]),
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 8,
      ),
    ];
  }

  List<Widget> _buildRanks(SemesterCourseScoreJson courseScore) {
    return (courseScore.isRankEmpty)
        ? [
            Container(
              child: Text(
                "暫無排名資訊",
                style: TextStyle(fontSize: 24),
              ),
            )
          ]
        : [
            _buildRankItems(courseScore.now, "學期排名"),
            SizedBox(
              height: 16,
            ),
            _buildRankItems(courseScore.history, "歷屆排名"),
          ];
  }

  Widget _buildRankItems(RankJson rank, String title) {
    double fontSize = 14;
    TextStyle textStyle = TextStyle(fontSize: fontSize);
    return Column(
      children: <Widget>[
        _buildTitle(title),
        _buildRankPart(rank.course, textStyle),
        _buildRankPart(rank.department, textStyle),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget _buildRankPart(RankItemJson rankItem, [TextStyle textStyle]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: AutoSizeText(
            sprintf("百分比: %s %", [rankItem.rank.toString()]),
            style: textStyle,
            minFontSize: 10,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: AutoSizeText(
            sprintf("百分比: %s %", [rankItem.total.toString()]),
            style: textStyle,
            minFontSize: 10,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: AutoSizeText(
            sprintf("百分比: %s %", [rankItem.percentage.toString()]),
            style: textStyle,
            minFontSize: 10,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
