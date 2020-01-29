import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/ui/icon/MyIcons.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:random_color/random_color.dart';

import '../../../../src/store/Model.dart';
import '../../../../src/store/json/UserDataJson.dart';

enum onListViewPress{ Setting , Logout , Report , About , ChangePassword}

class SettingScreen extends StatelessWidget {

  final List<Map> listViewData = [
    {
      "icon": Icons.settings ,
      "title": "設定" ,
      "onPress" : onListViewPress.Setting
    },
    {
      "icon": MyIcon.arrows_cw ,
      "title": "更改密碼",
      "onPress" : onListViewPress.ChangePassword
    },
    {
      "icon": MyIcon.logout ,
      "title": "登出" ,
      "onPress" : onListViewPress.Logout
    },
    {
      "icon": Icons.report ,
      "title": "意見反饋",
      "onPress" : onListViewPress.Report
    },
    {
      "icon": Icons.info ,
      "title": "關於",
      "onPress" : onListViewPress.About
    }
  ];


  void _onListViewPress(BuildContext context , onListViewPress value) {
    switch(value){
      case onListViewPress.Logout:
        Model.instance.logout();
        Navigator.of(context).push( CustomRoute(LoginPage() ));
        break;
      default:
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Setting'),
        ),
        body: ListView.separated(
          itemCount: listViewData.length+1,
          itemBuilder: (context, index) {
            Widget widget;
            if ( index == 0){
              widget =  _buildHeader(context);
            }else{
              widget = _buildSetting(context, listViewData[index-1]);
            }
            return GestureDetector(
                child: WidgetANimator(widget) ,
                onTap: () {
                  if ( index!=0)
                    _onListViewPress( context ,listViewData[index-1]['onPress'] );
                }
            );
          },
          separatorBuilder: (context, index) {
            return Container(
              color: Colors.black12,
              height: 1,
            );
          },
        ));
  }

  Container _buildHeader(BuildContext context) {
    UserInfoJson userInfo = Model.instance.userData.info;
    String givenName = userInfo.givenName;
    String userMail = userInfo.userMail;
    if ( givenName == null ||  userMail == null ){
      return Container(
        //color: Colors.yellow,
        margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
        constraints: BoxConstraints(maxHeight: 60),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 30.0,
              backgroundImage: NTUTConnector.getUserImage(),
            ),
            SizedBox(
              width: 10.0,
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    S.current.pleaseLogin,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ])
          ],
        ),
      );
    }
    return Container(
      //color: Colors.yellow,
      margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      constraints: BoxConstraints(maxHeight: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
              radius: 30.0,
              backgroundImage: NTUTConnector.getUserImage(),
          ),
          SizedBox(
            width: 10.0,
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  givenName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  userMail,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ])
        ],
      ),
    );
  }


  Container _buildSetting(BuildContext context , Map data) {
    return Container(
      //color: Colors.yellow,
      margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            data['icon'] ,
            color: RandomColor().randomColor(
                colorSaturation: ColorSaturation.highSaturation
            ),
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
