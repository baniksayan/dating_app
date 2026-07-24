class VerifyOtp {
  String? status;
  String? message;
  VerifyOtpData? data;

  VerifyOtp({this.status, this.message, this.data});

  VerifyOtp.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? VerifyOtpData.fromJson(json['data']) : null;
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

class VerifyOtpData {
  String? registrationToken;

  VerifyOtpData({this.registrationToken});

  VerifyOtpData.fromJson(Map<String, dynamic> json) {
    registrationToken = json['registration_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['registration_token'] = registrationToken;
    return dataMap;
  }
}
