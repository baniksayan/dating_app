class FinalRegister {
  String? status;
  String? message;
  Data? data;

  FinalRegister({this.status, this.message, this.data});

  FinalRegister.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['status'] = status;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class Data {
  String? userId;
  String? email;
  String? authToken;
  Map<String, dynamic>? errors;

  Data({this.userId, this.email, this.authToken, this.errors});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']?.toString();
    email = json['email']?.toString();
    authToken = json['auth_token']?.toString();
    if (json['errors'] is Map) {
      errors = Map<String, dynamic>.from(json['errors'] as Map);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['user_id'] = userId;
    dataMap['email'] = email;
    dataMap['auth_token'] = authToken;
    if (errors != null) {
      dataMap['errors'] = errors;
    }
    return dataMap;
  }
}
