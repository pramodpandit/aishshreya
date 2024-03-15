import 'LeadHistory.dart';

/// id : 2
/// e_id : 9
/// c_id : 1
/// name : "Aish"
/// phone : "1231212121"
/// email : "asdf@etst.sdo"
/// image : ""
/// requirement : "manicure"
/// created_by : 1
/// next_follow_up_on : ""
/// created_at : "2023-02-13 13:05:49"
/// updated_at : ""
/// status : "FollowUp"
/// emp_name : "Employee2"
/// emp_dialCode : "+91"
/// emp_phone : "1112223334"
/// emp_email : "Employee2"
/// emp_image : "Employee2"

class LeadDetail {
  LeadDetail({
      this.id, 
      this.eId, 
      this.cId, 
      this.name, 
      this.phone, 
      this.phone2,
      this.email,
      this.image, 
      this.requirement, 
      this.createdBy, 
      this.nextFollowUpOn, 
      this.createdAt, 
      this.updatedAt, 
      this.status, 
      this.empName, 
      this.empDialCode, 
      this.empPhone, 
      this.empEmail, 
      this.leadHistory = const [],
      this.empImage,});

  LeadDetail.fromJson(dynamic json) {
    id = json['id'];
    eId = json['e_id'];
    cId = json['c_id'];
    name = json['name'];
    phone = json['phone'];
    phone2 = json['phone2'];
    email = json['email'];
    image = json['image'];
    requirement = json['requirement'];
    createdBy = json['created_by'];
    nextFollowUpOn = json['next_follow_up_on'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    empName = json['emp_name'];
    empDialCode = json['emp_dialCode'];
    empPhone = json['emp_phone'];
    empEmail = json['emp_email'];
    empImage = json['emp_image'];
    leadHistory = [];
    if(json['history']!=null) {
      leadHistory = List.from((json['history'] ?? []).map((e) => LeadHistory.fromJson(e)));
    }

  }
  num? id;
  num? eId;
  num? cId;
  String? name;
  String? phone;
  String? phone2;
  String? email;
  String? image;
  String? requirement;
  num? createdBy;
  String? nextFollowUpOn;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? empName;
  String? empDialCode;
  String? empPhone;
  String? empEmail;
  String? empImage;
  late List<LeadHistory> leadHistory;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['e_id'] = eId;
    map['c_id'] = cId;
    map['name'] = name;
    map['phone'] = phone;
    map['phone2'] = phone2;
    map['email'] = email;
    map['image'] = image;
    map['requirement'] = requirement;
    map['created_by'] = createdBy;
    map['next_follow_up_on'] = nextFollowUpOn;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['status'] = status;
    map['emp_name'] = empName;
    map['emp_dialCode'] = empDialCode;
    map['emp_phone'] = empPhone;
    map['emp_email'] = empEmail;
    map['emp_image'] = empImage;
    map['history'] = leadHistory;
    return map;
  }

}