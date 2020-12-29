import 'dart:async';
import 'dart:io';

import 'package:cherry_magic/DatabaseHelper.dart';
import 'package:cherry_magic/api.dart';
import 'package:cherry_magic/detail.dart';
import 'package:cherry_magic/discussion.dart';
import 'package:cherry_magic/fans.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Api _api = Api();
  int member = 0;
  List<Fans> fans = [];
  Timer timer;

  @override
  void dispose() async {
    timer?.cancel();
    timer = null;
    await DbHelper().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timer = Timer.periodic(Duration(hours: 1), (timer) async {
      await _api.fetchMember().then((value) => {member = value});
      if (mounted) setState(() {});
      await DbHelper().saveItem(Fans(member, DateTime.now().toString()));
    });
    getList();

    return Scaffold(
      appBar: AppBar(
        title: Text('cherry magic成员数：$member'),
        actions: [
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 10),
              child: Text('帖子'),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DiscussionPage(
                  title: "帖子",
                );
              }));
            },
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Center(
            child: Text(
                '${fans[index].member}------${fans[index].recordTime.substring(0, 16)}'),
          );
        },
        itemCount: fans.length,
      ),
    );
  }

  getList() async {
    fans = await DbHelper().getTotalList();
  }
}

class DiscussionPage extends StatefulWidget {
  DiscussionPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  Api _api = Api();
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<Discussion> discussions = List<Discussion>();
  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _onRefresh() async {
    index = 0;
    await _api
        .fetchDiscussion(index)
        .then((value) => {discussions.clear(), discussions.addAll(value)});
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    index = index + 25;
    await _api
        .fetchDiscussion(index)
        .then((value) => {discussions.addAll(value)});
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("上拉加载");
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("加载失败！点击重试！");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("松手,加载更多!");
          } else {
            body = Text("没有更多数据了!");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        }),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemBuilder: (c, i) => InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DetailPage(discussions[i].url);
              }));
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Text(
                      discussions[i].title,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerRight,
                    child: Text(
                      discussions[i].author,
                      style: TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${discussions[i].response ?? 0}',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                        Text(
                          discussions[i].lastTime,
                          style: TextStyle(fontSize: 10, color: Colors.black26),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0,
                  )
                ],
              ),
            ),
          ),
          itemCount: discussions.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('帖子总数：${discussions.length}');

          var excel = Excel.createExcel();
          Sheet sheetObject = excel['discussion'];
          for (int i = 0; i < 5; i++) {
            for (int j = 0; j < discussions.length + 1; j++) {
              var cell = sheetObject.cell(
                  CellIndex.indexByColumnRow(columnIndex: i, rowIndex: j));
              if (j == 0) {
                switch (i) {
                  case 0:
                    cell.value = "标题";
                    break;
                  case 1:
                    cell.value = "楼主";
                    break;
                  case 2:
                    cell.value = "回应";
                    break;
                  case 3:
                    cell.value = "最后回应";
                    break;
                  case 4:
                    cell.value = "链接";
                    break;
                }
              } else {
                switch (i) {
                  case 0:
                    cell.value = discussions[j - 1].title;
                    break;
                  case 1:
                    cell.value = discussions[j - 1].author;
                    break;
                  case 2:
                    cell.value = discussions[j - 1].response;
                    break;
                  case 3:
                    cell.value = discussions[j - 1].lastTime;
                    break;
                  case 4:
                    cell.value = discussions[j - 1].url;
                    break;
                }
              }
            }
          }

          excel.encode().then((onValue) async {
            final directory = await getExternalStorageDirectory();
            File("${directory.path}/cherrymagic.xlsx")
              ..createSync(recursive: true)
              ..writeAsBytesSync(onValue);
          });
        },
        child: Icon(Icons.exit_to_app),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
