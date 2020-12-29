class Fans {
  int id;

  // 成员数
  int member;

  // 记录时间
  String recordTime;

  Fans(this.member, this.recordTime);

  @override
  String toString() {
    return '$member,$recordTime';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Member'] = this.member;
    data['RecordTime'] = this.recordTime;
    return data;
  }

  Fans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    member = json['Member'];
    recordTime = json['RecordTime'];
  }
}
