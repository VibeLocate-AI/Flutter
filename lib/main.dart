import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/app_bindings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppBindings().dependencies();
  Get.config(enableLog: false);
  runApp(const VibeLocateApp());
}
