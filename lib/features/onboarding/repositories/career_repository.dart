import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/logger_helper.dart';

abstract class CareerRepository {
  Future<List<String>> getJobSuggestions(String query);
  Future<List<CompanySuggestion>> getCompanySuggestions(String query);
}

class CompanySuggestion {
  final String name;
  final String? logoUrl;
  final String? domain;

  CompanySuggestion({
    required this.name,
    this.logoUrl,
    this.domain,
  });

  factory CompanySuggestion.fromJson(Map<String, dynamic> json) {
    final domain = json['domain'] as String?;
    // Fallback logo generation using Google's free high-res favicon service since Clearbit sunset their Logo API
    final logoUrl = domain != null && domain.isNotEmpty
        ? 'https://www.google.com/s2/favicons?sz=128&domain=$domain'
        : null;

    return CompanySuggestion(
      name: json['name'] as String? ?? '',
      logoUrl: logoUrl,
      domain: domain,
    );
  }
}

class CareerRepositoryImpl implements CareerRepository {
  final Dio _dio;
  List<String> _localJobTitles = [];
  bool _isJobTitlesLoaded = false;

  CareerRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio();

  Future<void> _loadJobTitlesIfNeeded() async {
    if (_isJobTitlesLoaded) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/job_titles.json');
      final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
      _localJobTitles = jsonList.map((e) => e as String).toList();
      _isJobTitlesLoaded = true;
      Logger.info('Successfully loaded ${_localJobTitles.length} job titles from local asset.', 'CareerRepository');
    } catch (e, stack) {
      Logger.error('Failed to load local job titles assets', e, stack, 'CareerRepository');
    }
  }

  @override
  Future<List<String>> getJobSuggestions(String query) async {
    if (query.trim().isEmpty) return const [];
    await _loadJobTitlesIfNeeded();

    try {
      final matches = _localJobTitles
          .where((title) => title.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .toList();
      return matches;
    } catch (e) {
      // Fail silently
    }
    return const [];
  }

  @override
  Future<List<CompanySuggestion>> getCompanySuggestions(String query) async {
    if (query.trim().isEmpty) return const [];

    try {
      Logger.info('GET https://autocomplete.clearbit.com/v1/companies/suggest | Query: "$query"', 'CareerRepository');
      final response = await _dio.get(
        'https://autocomplete.clearbit.com/v1/companies/suggest',
        queryParameters: {'query': query.trim()},
      );

      Logger.info('RESPONSE Code: ${response.statusCode} | Data: ${response.data}', 'CareerRepository');

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data as List<dynamic>? ?? [];
        final List<CompanySuggestion> suggestions = [];

        for (final item in list) {
          final map = item as Map<String, dynamic>?;
          if (map != null && map['name'] != null) {
            suggestions.add(CompanySuggestion.fromJson(map));
          }
        }
        return suggestions.take(5).toList();
      }
    } catch (e, stack) {
      Logger.error('Failed to retrieve company suggestions for query: "$query"', e, stack, 'CareerRepository');
    }
    return const [];
  }
}

final careerRepositoryProvider = Provider<CareerRepository>((ref) {
  return CareerRepositoryImpl();
});
