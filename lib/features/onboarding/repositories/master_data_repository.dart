import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/helpers/logger_helper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/config/api_config.dart';
import '../models/all_master_data_model.dart';

abstract class MasterDataRepository {
  Future<AllMasterData> getAllMasterData();
}

class ApiMasterDataRepository implements MasterDataRepository {
  final DioClient _dioClient;
  AllMasterData? _cachedMasterData;

  ApiMasterDataRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient(baseUrl: ApiConfig.baseUrl);

  @override
  Future<AllMasterData> getAllMasterData() async {
    if (_cachedMasterData != null) {
      Logger.info('Returning cached Master Data', 'MasterDataRepository');
      return _cachedMasterData!;
    }

    const String fullUrl = '${ApiConfig.baseUrl}${ApiConfig.masterAllData}';
    Logger.info('==================================================', 'MasterDataAPI');
    Logger.info('📡 HTTP REQUEST: GET $fullUrl', 'MasterDataAPI');

    try {
      final response = await _dioClient.get(ApiConfig.masterAllData);

      Logger.info('📥 RESPONSE Status Code: [${response.statusCode}]', 'MasterDataAPI');
      Logger.info('📦 Response Data Type: ${response.data.runtimeType}', 'MasterDataAPI');

      final dynamic responseData = response.data;
      if (responseData != null) {
        if (responseData is Map<String, dynamic>) {
          Logger.info('📦 Response Body: ${jsonEncode(responseData)}', 'MasterDataAPI');
        } else if (responseData is String) {
          Logger.debug('Raw String Body: $responseData', 'MasterDataAPI');
        }
      }

      final Map<String, dynamic> jsonMap = responseData is Map<String, dynamic>
          ? responseData
          : jsonDecode(responseData.toString());

      final masterData = AllMasterData.fromJson(jsonMap);
      _cachedMasterData = masterData;

      // Parsed model summary log
      final data = masterData.data;
      Logger.info('✅ PARSED MASTER DATA SUMMARY:', 'MasterDataAPI');
      Logger.info(' - Genders: ${data?.genders?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Show Me: ${data?.showMe?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Relationship Goals: ${data?.relationshipGoals?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Zodiac Signs: ${data?.zodiacSigns?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Education Levels: ${data?.educationLevels?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Smoking Habits: ${data?.smokingHabits?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Drinking Habits: ${data?.drinkingHabits?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Fitness Levels: ${data?.fitnessLevels?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Sleep Schedules: ${data?.sleepSchedules?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Dietary Preferences: ${data?.dietaryPreferences?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Family Plans: ${data?.familyPlans?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Pet Preferences: ${data?.petPreferences?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Communication Styles: ${data?.communicationStyles?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Love Languages: ${data?.loveLanguages?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Religions: ${data?.religions?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Political Views: ${data?.politicalViews?.length ?? 0}', 'MasterDataAPI');
      Logger.info(' - Opening Moves: ${data?.openingMoves?.length ?? 0}', 'MasterDataAPI');
      Logger.info('==================================================', 'MasterDataAPI');

      return masterData;
    } catch (e, stackTrace) {
      Logger.error('❌ MASTER DATA API ERROR: Failed to fetch/parse master data', e, stackTrace, 'MasterDataAPI');
      rethrow;
    }
  }
}

// Riverpod Providers
final masterDataRepositoryProvider = Provider<MasterDataRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ApiMasterDataRepository(dioClient: dioClient);
});

final masterDataProvider = FutureProvider<AllMasterData>((ref) async {
  final repo = ref.watch(masterDataRepositoryProvider);
  return repo.getAllMasterData();
});
