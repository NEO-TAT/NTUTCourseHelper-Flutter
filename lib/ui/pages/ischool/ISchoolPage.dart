import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/ui/pages/ischool/TabPage.dart';
import 'package:flutter_app/ui/pages/ischool/screen/CourseAnnouncementPage.dart';
import 'package:flutter_app/ui/pages/ischool/screen/CourseISchoolFilePage.dart';
import 'package:flutter_app/ui/pages/ischool/screen/CourseISchoolPlusFilePage.dart';
import 'package:flutter_app/ui/pages/ischool/screen/CourseInfoPage.dart';

class ISchoolPage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;
  ISchoolPage(this.studentId, this.courseInfo);

  @override
  _ISchoolPageState createState() => _ISchoolPageState();
}

class _ISchoolPageState extends State<ISchoolPage>
    with SingleTickerProviderStateMixin {
  TabPageList tabPageList;
  TabController _tabController;
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    tabPageList = TabPageList();
    tabPageList.add(TabPage(R.current.course, Icons.info,
        CourseInfoPage(widget.studentId, widget.courseInfo)));
    tabPageList.add(TabPage(R.current.announcement, Icons.announcement,
        CourseAnnouncementPage(widget.studentId, widget.courseInfo)));
    tabPageList.add(TabPage(R.current.file, Icons.file_download,
        CourseISchoolFilePage(widget.studentId, widget.courseInfo)));
    tabPageList.add(TabPage(R.current.file, Icons.file_download,
        CourseISchoolPlusFilePage(widget.studentId, widget.courseInfo)));

    _tabController = TabController(vsync: this, length: tabPageList.length);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var currentState = tabPageList.getKey(_currentIndex).currentState;
        bool pop = (currentState == null) ? true : currentState.canPop();
        return pop;
      },
      child: MaterialApp(
        home: tabPageView(),
      ),
    );
  }

  Widget tabPageView() {
    CourseMainJson course = widget.courseInfo.main.course;

    return DefaultTabController(
      length: tabPageList.length,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(course.name),
          bottom: TabBar(
            indicatorPadding: EdgeInsets.all(0),
            labelPadding: EdgeInsets.all(0),
            isScrollable: true,
            controller: _tabController,
            tabs: tabPageList.getTabList(context),
            onTap: (index) {
              _pageController.jumpToPage(index);
              _currentIndex = index;
            },
          ),
        ),
        body: PageView(
          //控制滑動
          controller: _pageController,
          children: tabPageList.getTabPageList,
          onPageChanged: (index) {
            _tabController.animateTo(index); //與上面tab同步
            _currentIndex = index;
          },
        ),
      ),
    );
  }
}
