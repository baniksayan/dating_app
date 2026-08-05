class UploadPhoto {
  String? status;
  String? message;
  Data? data;

  UploadPhoto({this.status, this.message, this.data});

  UploadPhoto.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  List<String>? filenames;

  Data({this.filenames});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['filenames'] != null) {
      if (json['filenames'] is List) {
        filenames = (json['filenames'] as List).map((e) => e.toString()).toList();
      } else {
        filenames = [json['filenames'].toString()];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['filenames'] = filenames;
    return dataMap;
  }
}
