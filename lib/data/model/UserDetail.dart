/// id : 1
/// name : "Admin"
/// dial_code : "+91"
/// phone : "1234567890"
/// email : "admin@gmail.com"
/// image : ""
/// dob : "2023-02-13"
/// secondary_num : ""
/// address : ""
/// joining_date : ""
/// insta : ""
/// fb : ""
/// linked_in : ""
/// other : ""
/// created_at : "2023-02-13 09:26:21"
/// updated_at : ""
/// is_admin : 1
/// status : "Active"
/// user_token : "eyJpdiI6Imw0RVIvaHJKS1p1WXRmNytLdjExNGc9PSIsInZhbHVlIjoiL0xENG55NnZFa0hlZEZUSXNjcS9odktYM2Vxd2ZMTm5qd09MMlI4UXU5NjA3aHlWV28zSzFDVXlNd0tRTTV6aSIsIm1hYyI6IjgyZjIwYTJlNmQ0NTViMTFlOTA0YzNiYTdlMzYzYTZiNWNlZWFlNDc4MmFlNDZmY2JhYmJhMjIyMzhlYzM4ZGUiLCJ0YWciOiIifQ=="

class UserDetail {
  UserDetail({
      this.id, 
      this.name, 
      this.dialCode, 
      this.phone, 
      this.email, 
      this.image, 
      this.dob, 
      this.secondaryNum, 
      this.address, 
      this.joiningDate, 
      this.insta, 
      this.fb, 
      this.linkedIn, 
      this.other, 
      this.createdAt, 
      this.updatedAt, 
      this.isAdmin, 
      this.status, 
      this.userToken,});

  UserDetail.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    dialCode = json['dial_code'];
    phone = json['phone'];
    email = json['email'];
    image = json['image'];
    dob = json['dob'];
    secondaryNum = json['secondary_num'];
    address = json['address'];
    joiningDate = json['joining_date'];
    insta = json['insta'];
    fb = json['fb'];
    linkedIn = json['linked_in'];
    other = json['other'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isAdmin = json['is_admin'];
    status = json['status'];
    userToken = json['user_token'];
  }
  num? id;
  String? name;
  String? dialCode;
  String? phone;
  String? email;
  String? image;
  String? dob;
  String? secondaryNum;
  String? address;
  String? joiningDate;
  String? insta;
  String? fb;
  String? linkedIn;
  String? other;
  String? createdAt;
  String? updatedAt;
  num? isAdmin;
  String? status;
  String? userToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['dial_code'] = dialCode;
    map['phone'] = phone;
    map['email'] = email;
    map['image'] = image;
    map['dob'] = dob;
    map['secondary_num'] = secondaryNum;
    map['address'] = address;
    map['joining_date'] = joiningDate;
    map['insta'] = insta;
    map['fb'] = fb;
    map['linked_in'] = linkedIn;
    map['other'] = other;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['is_admin'] = isAdmin;
    map['status'] = status;
    map['user_token'] = userToken;
    return map;
  }

}