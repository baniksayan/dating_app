import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/helpers/logger_helper.dart';

abstract class LocationRepository {
  Future<List<String>> getCitySuggestions(String query);
  Future<Position?> getCurrentLocation();
  Future<String?> getCityFromCoordinates(double latitude, double longitude);
}

class PhotonLocationRepository implements LocationRepository {
  final Dio _dio;

  PhotonLocationRepository({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<List<String>> getCitySuggestions(String query) async {
    if (query.trim().isEmpty) return const [];

    try {
      Logger.info('GET https://photon.komoot.io/api/ | Query: "$query"', 'PhotonLocationRepository');
      final response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': query.trim(),
          'limit': 5,
          'layer': 'city',
        },
        options: Options(
          headers: {
            'User-Agent': 'FlutterDatingApp/1.0 (contact@yourdomain.com)',
            'Accept': 'application/json',
          },
        ),
      );

      Logger.info('RESPONSE Code: ${response.statusCode} | Data: ${response.data}', 'PhotonLocationRepository');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List<dynamic> features = data['features'] as List<dynamic>? ?? [];
        final List<String> suggestions = [];

        for (final feature in features) {
          final properties = feature['properties'] as Map<String, dynamic>?;
          if (properties != null) {
            final String name = properties['name'] as String? ?? '';
            final String? state = properties['state'] as String?;
            final String? country = properties['country'] as String?;

            final List<String> parts = [];
            if (name.isNotEmpty) parts.add(name);
            if (state != null && state.isNotEmpty && state != name) {
              parts.add(state);
            }
            if (country != null && country.isNotEmpty) {
              parts.add(country);
            }

            final String fullSuggestion = parts.join(', ');
            if (fullSuggestion.isNotEmpty && !suggestions.contains(fullSuggestion)) {
              suggestions.add(fullSuggestion);
            }
          }
        }
        return suggestions;
      }
    } catch (e, stack) {
      Logger.error('Failed to retrieve geocoding suggestions for query: "$query"', e, stack, 'PhotonLocationRepository');
    }
    return const [];
  }

  @override
  Future<Position?> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Logger.info('Location services are disabled.', 'PhotonLocationRepository');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Logger.info('Location permissions are denied.', 'PhotonLocationRepository');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Logger.info('Location permissions are permanently denied.', 'PhotonLocationRepository');
        return null;
      }

      Logger.info('Fetching current position...', 'PhotonLocationRepository');
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e, stack) {
      Logger.error('Failed to get current location', e, stack, 'PhotonLocationRepository');
      return null;
    }
  }

  @override
  Future<String?> getCityFromCoordinates(double latitude, double longitude) async {
    try {
      Logger.info('GET https://photon.komoot.io/reverse | Lat: $latitude, Lon: $longitude', 'PhotonLocationRepository');
      final response = await _dio.get(
        'https://photon.komoot.io/reverse',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
        },
        options: Options(
          headers: {
            'User-Agent': 'FlutterDatingApp/1.0 (contact@yourdomain.com)',
            'Accept': 'application/json',
          },
        ),
      );

      Logger.info('REVERSE RESPONSE Code: ${response.statusCode} | Data: ${response.data}', 'PhotonLocationRepository');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List<dynamic> features = data['features'] as List<dynamic>? ?? [];
        if (features.isNotEmpty) {
          final properties = features.first['properties'] as Map<String, dynamic>?;
          if (properties != null) {
            final String? city = properties['city'] as String? ?? 
                                 properties['town'] as String? ?? 
                                 properties['village'] as String? ??
                                 properties['name'] as String?;
            final String? state = properties['state'] as String?;
            final String? country = properties['country'] as String?;

            final List<String> parts = [];
            if (city != null && city.isNotEmpty) parts.add(city);
            if (state != null && state.isNotEmpty && state != city) {
              parts.add(state);
            }
            if (country != null && country.isNotEmpty) {
              parts.add(country);
            }
            return parts.isNotEmpty ? parts.join(', ') : null;
          }
        }
      }
    } catch (e, stack) {
      Logger.error('Failed reverse geocoding coordinates: $latitude, $longitude', e, stack, 'PhotonLocationRepository');
    }
    return null;
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return PhotonLocationRepository();
});
