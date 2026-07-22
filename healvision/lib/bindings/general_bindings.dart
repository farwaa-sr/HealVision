import 'package:get/get.dart';
import '../feature/personalization/controllers/user_controller.dart';
import '../utilis/helpers/network_manager.dart';
import '../utilis/services/notification_service.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(UserController());
    Get.put(NotificationService());
  }
}
