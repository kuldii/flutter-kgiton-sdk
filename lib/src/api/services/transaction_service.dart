import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/transaction_models.dart';

/// Transaction Service
///
/// Provides methods for transaction operations:
/// - List transactions
/// - Get transaction detail
class KgitonTransactionService {
  final KgitonApiClient _client;

  KgitonTransactionService(this._client);

  /// List all transactions with filters and pagination
  ///
  /// [licenseKey] - Filter transactions by license key
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 50)
  /// [startDate] - Filter transactions from this date (optional)
  /// [endDate] - Filter transactions until this date (optional)
  ///
  /// Returns [TransactionListData] containing transactions and pagination info
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if license not found
  /// - [KgitonApiException] for other errors
  Future<TransactionListData> listTransactions({
    required String licenseKey,
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{'license_key': licenseKey, 'page': page.toString(), 'limit': limit.toString()};

    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }

    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }

    final response = await _client.get<TransactionListData>(
      KgitonApiEndpoints.listTransactions,
      queryParameters: queryParams,
      requiresAuth: true,
      fromJsonT: (json) => TransactionListData.fromJson(json),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to list transactions: ${response.message}');
    }

    return response.data!;
  }

  /// Get transaction detail by ID
  ///
  /// [transactionId] - The transaction ID
  ///
  /// Returns [TransactionDetail] containing transaction and all items
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if transaction not found
  /// - [KgitonAuthorizationException] if transaction doesn't belong to owner
  /// - [KgitonApiException] for other errors
  Future<TransactionDetail> getTransactionDetail(String transactionId) async {
    final response = await _client.get<TransactionDetail>(
      KgitonApiEndpoints.getTransactionById(transactionId),
      requiresAuth: true,
      fromJsonT: (json) => TransactionDetail.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to get transaction detail: ${response.message}');
    }

    return response.data!;
  }

  /// Get transaction summary for a specific license
  ///
  /// [licenseKey] - The license key
  /// [startDate] - Start date for summary period (optional)
  /// [endDate] - End date for summary period (optional)
  ///
  /// Returns transaction summary data
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if license not found
  /// - [KgitonApiException] for other errors
  Future<Map<String, dynamic>> getTransactionSummary({required String licenseKey, DateTime? startDate, DateTime? endDate}) async {
    final queryParams = <String, String>{'license_key': licenseKey};

    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }

    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/api/owner/transactions/summary',
      queryParameters: queryParams,
      requiresAuth: true,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to get transaction summary: ${response.message}');
    }

    return response.data!;
  }
}
