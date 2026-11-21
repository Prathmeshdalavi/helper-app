/// App-wide constants. Statuses and error codes mirror shared/contracts/*.json.
abstract final class AppConstants {
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);
  static const currencySymbol = '₹';
}

enum UserRole { customer, helper, admin }

enum BookingStatus {
  pending,
  confirmed,
  assigned,
  inProgress,
  completed,
  cancelled,
}
