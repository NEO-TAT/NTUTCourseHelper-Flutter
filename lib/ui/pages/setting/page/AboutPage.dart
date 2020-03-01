import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/update/AppUpdate.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:random_color/random_color.dart';

enum onListViewPress { AppUpdate, Contribution, Version }

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final List<Map> listViewData = [
    {
      "icon": Icons.update,
      "color": Colors.orange,
      "title": R.current.checkVersion,
      "onPress": onListViewPress.AppUpdate
    },
    {
      "icon": Icons.face,
      "color": Colors.lightGreen,
      "title": R.current.Contribution,
      "onPress": onListViewPress.Contribution
    },
    {
      "icon": Icons.info,
      "color": Colors.blue,
      "title": R.current.versionInfo,
      "onPress": onListViewPress.Version
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onListViewPress(onListViewPress value) {
    switch (value) {
      case onListViewPress.AppUpdate:
        MyToast.show(R.current.checkingVersion);
        AppUpdate.checkUpdate().then((value) {
          if (value != null) {
            AppUpdate.showUpdateDialog(context, value);
          } else {
            MyToast.show(R.current.isNewVersion);
          }
        });
        break;
      case onListViewPress.Contribution:
        EasyDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text(
            R.current.aboutDialogString,
          ),
          description: Text(""),
          contentList: [
            Text(
              "Power by morris13579",
              textAlign: TextAlign.end,
            ),
          ],
        ).show(context);
        break;
      case onListViewPress.Version:
        AppUpdate.getAppVersion().then((version) {
          MyToast.show(version);
        });
        break;
      default:
        MyToast.show(R.current.noFunction);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.about),
      ),
      body: ListView.separated(
        itemCount: listViewData.length,
        itemBuilder: (context, index) {
          Widget widget;
          widget = _buildAbout(listViewData[index]);
          return GestureDetector(
              behavior: HitTestBehavior.opaque, //讓透明部分有反應
              child: WidgetAnimator(widget),
              onTap: () {
                _onListViewPress(listViewData[index]['onPress']);
              });
        },
        separatorBuilder: (context, index) {
          // 顯示格線
          return Container(
            color: Colors.black12,
            height: 1,
          );
        },
      ),
    );
  }

  Container _buildAbout(Map data) {
    return Container(
      //color: Colors.yellow,
      padding:
          EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            data['icon'],
            color: data['color'],
          ),
          SizedBox(
            width: 20.0,
          ),
          Text(
            data['title'],
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
