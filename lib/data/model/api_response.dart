class ApiResponse<T> {
  ApiResponse({
      required this.status,
      required this.message,
      this.data,});

  ApiResponse.fromJson(dynamic json, [this.data]) {
    status = json['status'];
    message = json['message'];
  }
  late bool status;
  late String message;
  T? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    map['data'] = data;
    return map;
  }

}