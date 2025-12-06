import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/admin_models.dart';

/// Admin Settings Service
///
/// Provides methods for system settings management (Super Admin only):
/// - Get all system settings
/// - Get cart processing fee
/// - Update cart processing fee
class KgitonAdminSettingsService {
  final KgitonApiClient _client;

  KgitonAdminSettingsService(this._client);

  /// Get all system settings
  ///
  /// Returns [SystemSettingsData] containing all settings
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonAuthorizationException] if not Super Admin
  /// - [KgitonApiException] for other errors
  Future<SystemSettingsData> getAllSettings() async {
    final response = await _client.get<SystemSettingsData>(
      KgitonApiEndpoints.getAllSettings,
      requiresAuth: true,
      fromJsonT: (json) => SystemSettingsData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to get system settings: ${response.message}');
    }

    return response.data!;
  }

  /// Get cart processing fee value
  ///
  /// Returns [CartProcessingFeeData] containing the current fee
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonAuthorizationException] if not Super Admin
  /// - [KgitonApiException] for other errors
  Future<CartProcessingFeeData> getCartProcessingFee() async {
    final response = await _client.get<CartProcessingFeeData>(
      KgitonApiEndpoints.getCartProcessingFee,
      requiresAuth: true,
      fromJsonT: (json) => CartProcessingFeeData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to get cart processing fee: ${response.message}');
    }

    return response.data!;
  }

  /// Update cart processing fee
  ///
  /// [fee] - New processing fee amount (in currency)
  ///
  /// Returns [UpdateSettingData] containing the updated setting
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonAuthorizationException] if not Super Admin
  /// - [KgitonValidationException] if fee value is invalid
  /// - [KgitonApiException] for other errors
  Future<UpdateSettingData> updateCartProcessingFee(double fee) async {
    if (fee < 0) {
      throw ArgumentError('Fee cannot be negative');
    }

    final request = UpdateCartProcessingFeeRequest(fee: fee);

    final response = await _client.put<UpdateSettingData>(
      KgitonApiEndpoints.updateCartProcessingFee,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => UpdateSettingData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to update cart processing fee: ${response.message}');
    }

    return response.data!;
  }
}
