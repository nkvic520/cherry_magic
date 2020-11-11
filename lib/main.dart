
import 'package:cherry_magic/api.dart';
import 'package:cherry_magic/detail.dart';
import 'package:cherry_magic/discussion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cherry magic group',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'cherry magic group'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Api _api = new Api();
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<Discussion> discussions = new List<Discussion>();
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
          // int index = 0;
          // List<Discussion> discussions = new List<Discussion>();
          // List<Discussion> discussionsTmp = new List<Discussion>();
          //
          // while (index != -1) {
          //   print('index--$index');
          //   discussionsTmp.clear();
          //   await Future.delayed(Duration(milliseconds: 1000));
          //   discussionsTmp = await _api.fetchDiscussion(index);
          //   if (discussionsTmp.length > 0) {
          //     discussions.addAll(discussionsTmp);
          //     index = index + 25;
          //   } else {
          //     index = -1;
          //   }
          // }
          //
          // print(discussions.length);

          // var excel = Excel.createExcel();
          // Sheet sheetObject = excel['sheet1'];
          // for (int i = 0; i < 5; i++) {
          //   for (int j = 0; j < discussions.length + 1; j++) {
          //     var cell = sheetObject.cell(
          //         CellIndex.indexByColumnRow(columnIndex: i, rowIndex: j));
          //     if (j == 0) {
          //       switch (i) {
          //         case 0:
          //           cell.value = "标题";
          //           break;
          //         case 1:
          //           cell.value = "楼主";
          //           break;
          //         case 2:
          //           cell.value = "回应";
          //           break;
          //         case 3:
          //           cell.value = "最后回应";
          //           break;
          //         case 4:
          //           cell.value = "链接";
          //           break;
          //       }
          //     } else {}
          //   }
          // }

          // excel.encode().then((onValue) async {
          //   final directory = await getExternalStorageDirectory();
          //   File("${directory.path}/excel.xlsx")
          //     ..createSync(recursive: true)
          //     ..writeAsBytesSync(onValue);
          // });
        },
        child: Icon(Icons.exit_to_app),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
