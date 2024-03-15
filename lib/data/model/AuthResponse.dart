class AuthResponse<T> {
  AuthResponse({
    required this.status,
    required this.verified,
    required this.message,
    this.data,});

  AuthResponse.fromJson(dynamic json, [this.data]) {
    status = json['status'];
    verified = json['verified'];
    message = json['message'];
  }
  late bool status;
  late bool verified;
  late String message;
  T? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['verified'] = verified;
    map['message'] = message;
    map['data'] = data;
    return map;
  }

}