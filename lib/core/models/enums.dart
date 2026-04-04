/// Subscriber status enum — matches Convex union literals
enum SubscriberStatus {
  inactive('inactive'),
  active('active'),
  suspended('suspended'),
  disconnected('disconnected');

  final String value;
  const SubscriberStatus(this.value);

  static SubscriberStatus fromString(String value) {
    return SubscriberStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SubscriberStatus.inactive,
    );
  }

  static SubscriberStatus fromInt(int value) {
    switch (value) {
      case 0:
        return SubscriberStatus.inactive;
      case 1:
        return SubscriberStatus.active;
      case 2:
        return SubscriberStatus.suspended;
      case 3:
        return SubscriberStatus.disconnected;
      default:
        return SubscriberStatus.active;
    }
  }

  int toInt() {
    switch (this) {
      case SubscriberStatus.inactive:
        return 0;
      case SubscriberStatus.active:
        return 1;
      case SubscriberStatus.suspended:
        return 2;
      case SubscriberStatus.disconnected:
        return 3;
    }
  }
}
