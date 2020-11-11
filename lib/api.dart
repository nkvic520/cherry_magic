import 'package:cherry_magic/discussion.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';

class Api {
  Future<List<Discussion>> fetchDiscussion(int index) async {
    Dio dio = new Dio();
    dio.options.responseType = ResponseType.json;
    Response response = await dio
        .get("https://www.douban.com/group/706910/discussion?start=$index");
    List<Discussion> books = new List<Discussion>();
    try {
      var document = parse(response.data.toString());
      var content = document.querySelector(".olt");
      var titles = content.querySelectorAll(".title");
      var authors = content.querySelectorAll("a");
      var responses = content.querySelectorAll(".r-count");
      var lastTimes = content.querySelectorAll(".time");
      int count = responses.length > lastTimes.length
          ? lastTimes.length
          : responses.length;
      for (int i = 0; i < count; i++) {
        Discussion item = new Discussion(
          titles[i].querySelector("a").attributes["title"],
          titles[i].querySelector("a").attributes["href"].trim(),
          authors[1 + 2 * i].text,
          int.tryParse(responses[i + 1].text),
          lastTimes[i].text,
        );

        books.add(item);
        print(item.toString());
      }
      return books;
    } catch (e) {
      print(e);
    }

    return books;
  }
}
