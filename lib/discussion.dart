class Discussion {
  // 标题
  String title;

  // 帖子链接
  String url;

  // 楼主
  String author;

  // 回应
  int response;

  // 最后回应
  String lastTime;

  Discussion(this.title, this.url, this.author, this.response, this.lastTime);

  @override
  String toString() {
    return '$title,$author,$response,$lastTime,$url';
  }
}
