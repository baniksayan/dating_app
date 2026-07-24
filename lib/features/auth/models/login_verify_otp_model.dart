class LoginVerifyOtp {
  String? status;
  String? message;
  LoginVerifyOtpData? data;

  LoginVerifyOtp({this.status, this.message, this.data});

  LoginVerifyOtp.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? LoginVerifyOtpData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['status'] = status;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class LoginVerifyOtpData {
  String? authToken;
  int? userId;

  LoginVerifyOtpData({this.authToken, this.userId});

  LoginVerifyOtpData.fromJson(Map<String, dynamic> json) {
    authToken = json['auth_token'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['auth_token'] = authToken;
    dataMap['user_id'] = userId;
    return dataMap;
  }
}
