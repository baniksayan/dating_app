import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';
import '../../../core/helpers/logger_helper.dart';
import '../../../core/network/dio_client.dart';
import '../models/final_register_model.dart';

abstract class RegistrationRepository {
  /// Submit final onboarding registration data to backend endpoint
  Future<FinalRegister> registerUser(Map<String, dynamic> payload);
}

class ApiRegistrationRepository implements RegistrationRepository {
  final DioClient _dioClient;

  ApiRegistrationRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient(baseUrl: ApiConfig.baseUrl);

  @override
  Future<FinalRegister> registerUser(Map<String, dynamic> payload) async {
    const String endpoint = ApiConfig.register;
    const String fullUrl = '${ApiConfig.baseUrl}$endpoint';

    Logger.info('==================================================', 'RegistrationAPI');
    Logger.info('📡 HTTP REQUEST: POST $fullUrl', 'RegistrationAPI');
    Logger.info('📋 Request Headers: {Content-Type: application/json}', 'RegistrationAPI');
    Logger.info('📦 Request Body Payload Summary (${payload.length} fields):', 'RegistrationAPI');
    payload.forEach((key, value) {
      Logger.info('   🔑 $key: $value', 'RegistrationAPI');
    });
    Logger.info('📄 Full JSON Payload: ${jsonEncode(payload)}', 'RegistrationAPI');

    try {
      final response = await _dioClient.post(
        endpoint,
        data: payload,
      );

      Logger.info('📥 RESPONSE Status Code: [${response.statusCode}]', 'RegistrationAPI');
      Logger.info('📦 Response Data Type: ${response.data.runtimeType}', 'RegistrationAPI');
      Logger.info('📄 Full Response Body: ${response.data}', 'RegistrationAPI');

      Map<String, dynamic> jsonMap;
      if (response.data is Map<String, dynamic>) {
        jsonMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        jsonMap = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        jsonMap = Map<String, dynamic>.from(response.data as Map);
      }

      final finalRegisterResponse = FinalRegister.fromJson(jsonMap);

      Logger.info('✅ PARSED FINAL REGISTER MODEL SUMMARY:', 'RegistrationAPI');
      Logger.info(' - Status: "${finalRegisterResponse.status}"', 'RegistrationAPI');
      Logger.info(' - Message: "${finalRegisterResponse.message}"', 'RegistrationAPI');
      Logger.info(' - User ID: ${finalRegisterResponse.data?.userId}', 'RegistrationAPI');
      Logger.info(' - Email: ${finalRegisterResponse.data?.email}', 'RegistrationAPI');
      Logger.info(' - Auth Token: "${finalRegisterResponse.data?.authToken}"', 'RegistrationAPI');
      Logger.info('==================================================', 'RegistrationAPI');

      return finalRegisterResponse;
    } on ApiException catch (e) {
      Logger.error('❌ REGISTRATION API ERROR [ApiException]: Status ${e.statusCode}', e.message, null, 'RegistrationAPI');
      if (e.errorData != null) {
        Logger.error('📄 Error Response Data: ${e.errorData}', null, null, 'RegistrationAPI');
        if (e.errorData is Map<String, dynamic>) {
          return FinalRegister.fromJson(e.errorData as Map<String, dynamic>);
        }
      }
      return FinalRegister(status: 'error', message: e.message);
    } catch (e, stackTrace) {
      Logger.error('💥 REGISTRATION API UNEXPECTED ERROR: Failed to submit registration data', e, stackTrace, 'RegistrationAPI');
      return FinalRegister(status: 'error', message: e.toString());
    }
  }
}

// Riverpod Provider for RegistrationRepository
final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ApiRegistrationRepository(dioClient: dioClient);
});
