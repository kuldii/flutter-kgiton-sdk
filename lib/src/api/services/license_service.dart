import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/license_models.dart';

/// License Service
///
/// Provides methods for license management (Super Admin only):
/// - Create single license
/// - Bulk create licenses
/// - List all licenses
/// - Get license detail
/// - Upload licenses from CSV
/// - Download licenses as CSV
class KgitonLicenseService {
  final KgitonApiClient _client;

  KgitonLicenseService(this._client);

  /// Create a single license
  ///
  /// [licenseKey] - Optional custom license key. If not provided, will be auto-generated
  ///
  /// Returns the created [License]
  ///
  /// Throws:
  /// - [KgitonAuthorizationException] if not Super Admin
  /// - [KgitonConflictException] if license key already exists
  /// - [KgitonApiException] for other errors
  Future<License> createLicense({String? licenseKey}) async {
    final request = CreateLicenseRequest(licenseKey: licenseKey);

    final response = await _client.post<License>(
      KgitonApiEndpoints.createLicense,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => License.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to create license: ${response.message}');
    }

    return response.data!;
  }

  /// Bulk create multiple licenses
  ///
  /// [count] - Number of licenses to create (min: 1, max: 1000)
  ///
  /// Returns [BulkLicenseData] containing created licenses count and list
  ///
  /// Throws:
  /// - [KgitonAuthorizationException] if not Super Admin
  /// - [KgitonValidationException] if count is invalid
  /// - [KgitonApiException] for other errors
  Future<BulkLicenseData> bulkCreateLicenses({required int count}) async {
    if (count < 1 || count > 1000) {
      throw ArgumentError('Count must be between 1 and 1000');
    }

    final request = BulkCreateLicensesRequest(count: count);

    final response = await _client.post<BulkLicenseData>(
      KgitonApiEndpoints.bulkCreateLicenses,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => BulkLicenseData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to bulk create licenses: ${response.message}');
    }

    return response.data!;
  }

  /// List all licenses with filters and pagination
  ///
  /// [status] - Filter by status: 'all', 'used', or 'unused' (default: 'all')
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 50)
  ///
  /// Returns [LicenseListData] containing licenses and pagination info
  ///
  /// Throws:
  /// - [KgitonAuthorizationException] if not Super Admin
  /// - [KgitonApiException] for other errors
  Future<LicenseListData> listLicenses({String status = 'all', int page = 1, int limit = 50}) async {
    final queryParams = {'status': status, 'page': page.toString(), 'limit': limit.toString()};

    final response = await _client.get<LicenseListData>(
      KgitonApiEndpoints.listLicenses,
      queryParameters: queryParams,
      requiresAuth: true,
      fromJsonT: (json) => LicenseListData.fromJson(json),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to list licenses: ${response.message}');
    }

    return response.data!;
  }

  /// Get license detail by ID
  ///
  /// [licenseId] - The license ID
  ///
  /// Returns the [License] detail
  ///
  /// Throws:
  /// - [KgitonAuthorizationException] if not Super Admin
  /// - [KgitonNotFoundException] if license not found
  /// - [KgitonApiException] for other errors
  Future<License> getLicenseDetail(String licenseId) async {
    final response = await _client.get<License>(
      KgitonApiEndpoints.getLicenseById(licenseId),
      requiresAuth: true,
      fromJsonT: (json) => License.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to get license detail: ${response.message}');
    }

    return response.data!;
  }

  /// Upload licenses from CSV file
  ///
  /// [filePath] - Path to the CSV file
  ///
  /// CSV Format:
  /// - Delimiter: Semicolon (;)
  /// - Header: license_key
  /// - Leave license_key empty for auto-generation
  ///
  /// Returns a response with upload results
  ///
  /// Throws:
  /// - [KgitonAuthorizationException] if not Super Admin
  /// - [KgitonValidationException] if CSV format is invalid
  /// - [KgitonApiException] for other errors
  Future<Map<String, dynamic>> uploadLicensesFromCsv(String filePath) async {
    final response = await _client.postMultipart<Map<String, dynamic>>(
      KgitonApiEndpoints.uploadLicensesFromCsv,
      fields: {},
      fileFieldName: 'file',
      filePath: filePath,
      requiresAuth: true,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    return response.data ?? {};
  }

  /// Download licenses as CSV
  ///
  /// [status] - Filter by status: 'all', 'used', or 'unused' (default: 'all')
  ///
  /// Returns the CSV file content as String
  ///
  /// Note: This method returns raw CSV data. Save it to a file as needed.
  ///
  /// Throws:
  /// - [KgitonAuthorizationException] if not Super Admin
  /// - [KgitonApiException] for other errors
  Future<String> downloadLicensesAsCsv({String status = 'all'}) async {
    final queryParams = {'status': status};

    // For CSV download, we need to handle the response differently
    // This is a simplified version - you may want to enhance this
    final uri = Uri.parse(
      '${_client.baseUrl}${KgitonApiConfig.apiVersion}${KgitonApiEndpoints.downloadLicensesAsCsv}',
    ).replace(queryParameters: queryParams);

    // Note: This would need a different implementation for actual file download
    // For now, we'll throw an exception to indicate manual implementation needed
    throw UnimplementedError(
      'CSV download requires platform-specific implementation. '
      'Use the endpoint: ${uri.toString()} with Authorization header.',
    );
  }
}
