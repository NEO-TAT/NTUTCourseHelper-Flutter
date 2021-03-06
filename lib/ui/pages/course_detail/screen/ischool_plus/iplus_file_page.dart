import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/file/file_download.dart';
import 'package:flutter_app/src/file/file_store.dart';
import 'package:flutter_app/src/model/course_table/course_table_json.dart';
import 'package:flutter_app/src/model/ischool_plus/course_file_json.dart';
import 'package:flutter_app/src/store/model.dart';
import 'package:flutter_app/src/task/iplus/iplus_course_file_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_app/src/util/analytics_utils.dart';
import 'package:flutter_app/src/util/route_utils.dart';
import 'package:flutter_app/ui/icon/my_icons.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class IPlusFilePage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  IPlusFilePage(this.studentId, this.courseInfo);

  @override
  _IPlusFilePage createState() => _IPlusFilePage();
}

class _IPlusFilePage extends State<IPlusFilePage>
    with AutomaticKeepAliveClientMixin {
  List<CourseFileJson> courseFileList = [];
  SelectList selectList = SelectList();
  bool isSupport;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    isSupport = Model.instance.getAccount() == widget.studentId;
    Future.delayed(Duration.zero, () {
      if (isSupport) {
        _addTask();
      }
      FileStore.findLocalPath(context);
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    if (selectList.inSelectMode) {
      selectList.leaveSelectMode();
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  void _addTask() async {
    await Future.delayed(Duration(microseconds: 500));
    String courseId = widget.courseInfo.main.course.id;

    TaskFlow taskFlow = TaskFlow();
    var task = IPlusCourseFileTask(courseId);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      courseFileList = task.result;
    }
    courseFileList = courseFileList ?? [];
    selectList.addItems(courseFileList.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Scaffold(
        body: (courseFileList.length > 0)
            ? _buildFileList()
            : (isSupport)
                ? Center(
                    child: Text(R.current.noAnyFile),
                  )
                : Center(
                    child: Text(R.current.notSupport),
                  ),
        floatingActionButton: (selectList.inSelectMode)
            ? FloatingActionButton(
                // FloatingActionButton: 浮動按鈕
                onPressed: _floatingDownloadPress,
                // 按下觸發的方式名稱: void _incrementCounter()
                tooltip: R.current.download,
                // 按住按鈕時出現的提示字
                child: Icon(Icons.file_download),
              )
            : null);
  }

  Future<void> _floatingDownloadPress() async {
    MyToast.show(R.current.downloadWillStart);
    for (int i = 0; i < courseFileList.length; i++) {
      if (selectList.getItemSelect(i)) {
        await _downloadOneFile(i, false);
      }
    }
    selectList.leaveSelectMode();
    setState(() {});
  }

  Widget _buildFileList() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              itemCount: courseFileList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque, //讓透明部分有反應
                  child: _buildCourseFile(index, courseFileList[index]),
                  onTap: () {
                    if (selectList.inSelectMode) {
                      selectList.setItemReverse(index);
                      setState(() {});
                    } else {
                      _downloadOneFile(index);
                    }
                  },
                  onLongPress: () {
                    if (!selectList.inSelectMode) {
                      selectList.setItemReverse(index);
                      setState(() {});
                    }
                  },
                );
              },
              separatorBuilder: (context, index) {
                // 顯示格線
                return Container(
                  color: Colors.black12,
                  height: 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> iconList = [
    Icon(
      MyIcon.file_pdf,
      color: Colors.red,
    ),
    Icon(
      MyIcon.file_word,
      color: Colors.blue,
    ),
    Icon(
      MyIcon.file_powerpoint,
      color: Colors.redAccent,
    ),
    Icon(
      MyIcon.file_excel,
      color: Colors.green,
    ),
    Icon(
      MyIcon.file_archive,
      color: Colors.blue,
    ),
    Icon(
      MyIcon.link,
      color: Colors.grey,
    ),
    Icon(
      MyIcon.doc_inv,
      color: Colors.blueGrey,
    )
  ];

  Widget _buildCourseFile(int index, CourseFileJson courseFile) {
    return Container(
        color: selectList.getItemSelect(index)
            ? Colors.grey
            : Theme.of(context).backgroundColor,
        padding: EdgeInsets.all(10),
        child: Column(
          children: _buildFileItem(courseFile),
        ));
  }

  List<Widget> _buildFileItem(CourseFileJson courseFile) {
    List<Widget> widgetList = [];
    List<Widget> iconWidgetList = [];
    for (FileType fileType in courseFile.fileType) {
      iconWidgetList.add(iconList[fileType.type.index]);
    }
    widgetList.add(
      Row(
        children: [
          Column(
            children: iconWidgetList,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
          ),
          Expanded(
            child: Text(courseFile.name),
          ),
        ],
      ),
    );
    return widgetList;
  }

  Future<void> _downloadOneFile(int index, [showToast = true]) async {
    CourseFileJson courseFile = courseFileList[index];
    FileType fileType = courseFile.fileType[0];
    String dirName = widget.courseInfo.main.course.name;
    String url;
    String referer;
    List<String> urlList = [];
    await AnalyticsUtils.logDownloadFileEvent();
    if (showToast) {
      MyToast.show(R.current.downloadWillStart);
    }
    urlList = await ISchoolPlusConnector.getRealFileUrl(fileType.postData);
    if (urlList == null) {
      MyToast.show(sprintf("%s%s", [courseFile.name, R.current.downloadError]));
      return;
    }
    url = urlList[0];
    referer = urlList[1];
    Uri urlParse = Uri.parse(url);
    if (!urlParse.host.toLowerCase().contains("ntut.edu.tw")) {
      //代表可能是一個連結
      ErrorDialogParameter errorDialogParameter =
          ErrorDialogParameter(context: context, desc: R.current.isALink);
      errorDialogParameter.title = R.current.AreYouSureToOpen;
      errorDialogParameter.dialogType = DialogType.INFO;
      errorDialogParameter.btnOkText = R.current.sure;
      errorDialogParameter.btnOkOnPress = () {
        _launchURL(url);
      };
      ErrorDialog(errorDialogParameter).show();
      return;
    } else if (urlParse.host.contains("istream.ntut.edu.tw")) {
      ErrorDialogParameter errorDialogParameter =
          ErrorDialogParameter(context: context, desc: R.current.isVideo);
      errorDialogParameter.title = R.current.AreYouSureToOpen;
      errorDialogParameter.dialogType = DialogType.INFO;
      errorDialogParameter.btnOkText = R.current.sure;
      errorDialogParameter.btnOkOnPress = () {
        Get.back();
        RouteUtils.toVideoPlayer(
            urlParse.toString(), widget.courseInfo, courseFile.name);
      };
      ErrorDialog(errorDialogParameter).show();
    } else {
      await FileDownload.download(
          context, url, dirName, courseFile.name, referer);
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class SelectList {
  List<bool> _selectList = [];

  void addItem() {
    _selectList.add(false);
  }

  void addItems(int number) {
    for (int i = 0; i < number; i++) {
      addItem();
    }
  }

  void setItemSelect(int index, bool value) {
    if (index >= _selectList.length) {
      return;
    } else {
      _selectList[index] = value;
    }
  }

  void setItemReverse(int index) {
    if (index >= _selectList.length) {
      return;
    } else {
      _selectList[index] = !_selectList[index];
    }
  }

  bool getItemSelect(int index) {
    if (index >= _selectList.length) {
      return false;
    } else {
      return _selectList[index];
    }
  }

  bool get inSelectMode {
    bool select = false;
    for (bool value in _selectList) {
      select |= value;
    }
    return select;
  }

  void leaveSelectMode() {
    for (int i = 0; i < _selectList.length; i++) {
      _selectList[i] = false;
    }
  }
}
