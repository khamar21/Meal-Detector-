import 'dart:io';

import '../../../core/api_service.dart';

class FoodScanRepository {
  const FoodScanRepository();

  Future<Map<String, dynamic>> predictFoodImage(File imageFile) {
    return ApiService.predictFood(imageFile);
  }
}
