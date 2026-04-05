import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// Settings section provider
final settingsSectionProvider =
    StateProvider<String>((ref) => 'معلومات المولد');

// Subscription status providers
final subscriptionStatusProvider = StateProvider<bool>((ref) => false);
final subscriptionEndDateProvider = StateProvider<DateTime?>((ref) => null);
final subscriptionLoadingProvider = StateProvider<bool>((ref) => false);

// Logo path provider
final logoPathProvider = StateProvider<String>((ref) => '');

// Generator info providers (for persistent editing)
final generatorNameProvider = StateProvider<String>((ref) => 'Smart_gen');
final generatorPhoneProvider = StateProvider<String>((ref) => '07701234567');
final generatorAddressProvider =
    StateProvider<String>((ref) => 'بغداد - المنصور - شارع الحرية');

// Settings loading state
final settingsLoadingProvider = StateProvider<bool>((ref) => false);

// Printer settings providers
final printerNameProvider = StateProvider<String>((ref) => 'default');
final paperSizeProvider = StateProvider<String>((ref) => 'a4');
final documentTitleProvider =
    StateProvider<String>((ref) => 'مولد الدين الإسلامي');
final documentPhoneProvider = StateProvider<String>((ref) => '07701234567');

// Notification settings providers
final paymentRemindersProvider = StateProvider<bool>((ref) => true);
final reminderDaysProvider = StateProvider<int>((ref) => 1);
final syncNotificationsProvider = StateProvider<bool>((ref) => true);
final systemAlertsProvider = StateProvider<bool>((ref) => true);
final whatsappNotificationsProvider = StateProvider<bool>((ref) => false);

// Security settings providers
final autoLockProvider = StateProvider<bool>((ref) => true);
final autoLockMinutesProvider = StateProvider<int>((ref) => 5);

// Backup settings providers
final cloudBackupEnabledProvider = StateProvider<bool>((ref) => true);
final autoBackupFrequencyProvider = StateProvider<String>((ref) => 'daily');

// Image picker instance
final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());
