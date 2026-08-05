import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';
import '../../../core/helpers/logger_helper.dart';
import '../../../core/network/dio_client.dart';
import '../models/upload_photo_model.dart';

abstract class PhotoRepository {
  /// Upload profile photos to server endpoint
  Future<UploadPhoto> uploadPhotos(List<String> filePaths);
}

class ApiPhotoRepository implements PhotoRepository {
  final DioClient _dioClient;

  ApiPhotoRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient(baseUrl: ApiConfig.baseUrl);

  @override
  Future<UploadPhoto> uploadPhotos(List<String> filePaths) async {
    const String endpoint = ApiConfig.uploadPhoto;
    const String fullUrl = '${ApiConfig.baseUrl}$endpoint';

    Logger.info('==================================================', 'PhotoUploadAPI');
    Logger.info('📡 HTTP REQUEST: POST $fullUrl', 'PhotoUploadAPI');
    Logger.info('📋 Request Headers: {Content-Type: multipart/form-data}', 'PhotoUploadAPI');
    Logger.info('📦 Request Payload: Uploading ${filePaths.length} photo file(s)', 'PhotoUploadAPI');
    for (int i = 0; i < filePaths.length; i++) {
      Logger.info('   📷 [$i] Path: ${filePaths[i]}', 'PhotoUploadAPI');
    }

    try {
      final List<MultipartFile> multipartFiles = [];

      for (final path in filePaths) {
        final file = File(path);
        if (await file.exists()) {
          final String filename = path.split('/').last;
          multipartFiles.add(
            await MultipartFile.fromFile(
              path,
              filename: filename,
            ),
          );
        } else {
          Logger.warning('⚠️ Skipping non-existent file path: $path', 'PhotoUploadAPI');
        }
      }

      if (multipartFiles.isEmpty) {
        const errorMsg = 'No valid physical photo files found to upload.';
        Logger.error('❌ $errorMsg', null, null, 'PhotoUploadAPI');
        return UploadPhoto(status: 'error', message: errorMsg);
      }

      final formData = FormData.fromMap({
        'photos[]': multipartFiles,
      });

      Logger.info('🚀 Sending FormData multipart request with ${multipartFiles.length} file payload(s)...', 'PhotoUploadAPI');

      final response = await _dioClient.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      Logger.info('📥 RESPONSE Status Code: [${response.statusCode}]', 'PhotoUploadAPI');
      Logger.info('📦 Raw Response Data Type: ${response.data.runtimeType}', 'PhotoUploadAPI');
      Logger.info('📄 Full Response Body: ${response.data}', 'PhotoUploadAPI');

      Map<String, dynamic> jsonMap;
      if (response.data is Map<String, dynamic>) {
        jsonMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        jsonMap = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        jsonMap = Map<String, dynamic>.from(response.data as Map);
      }

      final uploadPhotoResponse = UploadPhoto.fromJson(jsonMap);

      Logger.info('✅ PARSED UPLOAD PHOTO MODEL SUMMARY:', 'PhotoUploadAPI');
      Logger.info(' - Status: "${uploadPhotoResponse.status}"', 'PhotoUploadAPI');
      Logger.info(' - Message: "${uploadPhotoResponse.message}"', 'PhotoUploadAPI');
      Logger.info(' - Uploaded Filenames Count: ${uploadPhotoResponse.data?.filenames?.length ?? 0}', 'PhotoUploadAPI');
      if (uploadPhotoResponse.data?.filenames != null) {
        for (final fn in uploadPhotoResponse.data!.filenames!) {
          Logger.info('   ✨ Server Filename: $fn', 'PhotoUploadAPI');
        }
      }
      Logger.info('==================================================', 'PhotoUploadAPI');

      return uploadPhotoResponse;
    } on ApiException catch (e) {
      Logger.error('❌ PHOTO UPLOAD API ERROR [ApiException]: Status ${e.statusCode}', e.message, null, 'PhotoUploadAPI');
      if (e.errorData != null) {
        Logger.error('📄 Error Response Data: ${e.errorData}', null, null, 'PhotoUploadAPI');
        if (e.errorData is Map<String, dynamic>) {
          return UploadPhoto.fromJson(e.errorData as Map<String, dynamic>);
        }
      }
      return UploadPhoto(status: 'error', message: e.message);
    } catch (e, stackTrace) {
      Logger.error('💥 PHOTO UPLOAD UNEXPECTED ERROR: Failed to process photo upload request', e, stackTrace, 'PhotoUploadAPI');
      return UploadPhoto(status: 'error', message: e.toString());
    }
  }
}

// Riverpod Provider for PhotoRepository
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ApiPhotoRepository(dioClient: dioClient);
});
