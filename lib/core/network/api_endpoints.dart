class ApiEndpoints {
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'muslimku-bce48',
  );
  static const firebaseFunctionsRegion = String.fromEnvironment(
    'FIREBASE_FUNCTIONS_REGION',
    defaultValue: 'asia-southeast1',
  );

  static const equranBaseUrl = 'https://equran.id';
  static const equranApiBaseUrl = 'https://equran.id/api';
  static const firebaseFunctionsBaseUrl = String.fromEnvironment(
    'FIREBASE_FUNCTIONS_BASE_URL',
    defaultValue:
        'https://$firebaseFunctionsRegion-$firebaseProjectId.cloudfunctions.net',
  );

  static const surahList = '/api/v2/surat';

  static String surahDetail(int number) => '/api/v2/surat/$number';
  static String tafsir(int number) => '/api/v2/tafsir/$number';

  static const vectorSearch = '/vector';

  static String authFunction(String name) => '$firebaseFunctionsBaseUrl/$name';
}
