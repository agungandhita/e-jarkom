import 'lib/services/url_service.dart';

void main() {
  print('Testing URL construction fixes...');
  
  // Test the problematic URL from user
  String problematicPath = 'tools/tools/yW2mL8eyFnISAkmUv1rPwyssS6wPuFxXFD2cjibM.jpg';
  String fixedUrl = UrlService.constructImageUrl(problematicPath);
  
  print('\nProblematic path: $problematicPath');
  print('Fixed URL: $fixedUrl');
  print('Expected: https://63fca316627b.ngrok-free.app/storage/tools/yW2mL8eyFnISAkmUv1rPwyssS6wPuFxXFD2cjibM.jpg');
  
  // Run comprehensive test
  UrlService.testUrlConstruction();
}