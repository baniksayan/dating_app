class VerifyOtp {
  String? status;
  String? message;
  Data? data;

  VerifyOtp({this.status, this.message, this.data});

  VerifyOtp.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? registrationToken;

  Data({this.registrationToken});

  Data.fromJson(Map<String, dynamic> json) {
    registrationToken = json['registration_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['registration_token'] = registrationToken;
    return data;
  }
}
