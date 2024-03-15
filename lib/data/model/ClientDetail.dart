class ClientDetail {
  ClientDetail({
      this.id, 
      this.name, 
      this.phone, 
      this.phone2,
      this.email,
      this.image, 
      this.createdBy, 
      this.createdAt, 
      this.updatedAt, 
      this.status, 
      this.empName, 
      this.empPhone, 
      this.empEmail, 
      this.empImage,});

  ClientDetail.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    phone2 = json['phone2'];
    email = json['email'];
    image = json['image'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    empName = json['emp_name'];
    empPhone = json['emp_phone'];
    empEmail = json['emp_email'];
    empImage = json['emp_image'];
  }
  num? id;
  String? name;
  String? phone;
  String? phone2;
  String? email;
  String? image;
  num? createdBy;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? empName;
  String? empPhone;
  String? empEmail;
  String? empImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['phone'] = phone;
    map['phone2'] = phone2;
    map['email'] = email;
    map['image'] = image;
    map['created_by'] = createdBy;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['status'] = status;
    map['emp_name'] = empName;
    map['emp_phone'] = empPhone;
    map['emp_email'] = empEmail;
    map['emp_image'] = empImage;
    return map;
  }

}