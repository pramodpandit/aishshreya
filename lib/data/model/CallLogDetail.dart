class CallLogDetail {
  CallLogDetail({
      this.id, 
      this.leadId, 
      this.callDuration, 
      this.callRecord, 
      this.callStatus, 
      this.otherNumber,
      this.createdAt,
      this.updatedAt, 
      this.status, 
      this.leadName, 
      this.leadPhone, 
      this.leadEmail, 
      this.leadImage, 
      this.empName, 
      this.empDialCode, 
      this.empPhone, 
      this.empEmail, 
      this.empImage,});

  CallLogDetail.fromJson(dynamic json) {
    id = json['id'];
    leadId = json['lead_id'];
    callDuration = json['call_duration'];
    callRecord = json['call_record'];
    otherNumber = json['other_number'];
    callStatus = json['call_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    leadName = json['lead_name'];
    leadPhone = json['lead_phone'];
    leadEmail = json['lead_email'];
    leadImage = json['lead_image'];
    empName = json['emp_name'];
    empDialCode = json['emp_dialCode'];
    empPhone = json['emp_phone'];
    empEmail = json['emp_email'];
    empImage = json['emp_image'];
  }
  num? id;
  num? leadId;
  String? callDuration;
  String? callRecord;
  String? callStatus;
  String? otherNumber;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? leadName;
  String? leadPhone;
  String? leadEmail;
  String? leadImage;
  String? empName;
  String? empDialCode;
  String? empPhone;
  String? empEmail;
  String? empImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['lead_id'] = leadId;
    map['call_duration'] = callDuration;
    map['call_record'] = callRecord;
    map['call_status'] = callStatus;
    map['other_number'] = otherNumber;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['status'] = status;
    map['lead_name'] = leadName;
    map['lead_phone'] = leadPhone;
    map['lead_email'] = leadEmail;
    map['lead_image'] = leadImage;
    map['emp_name'] = empName;
    map['emp_dialCode'] = empDialCode;
    map['emp_phone'] = empPhone;
    map['emp_email'] = empEmail;
    map['emp_image'] = empImage;
    return map;
  }

}