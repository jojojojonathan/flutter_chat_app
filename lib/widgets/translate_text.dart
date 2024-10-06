import 'package:googleapis/translate/v3.dart' as translate;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class TranslationService {
  final auth.AuthClient _client;

  TranslationService(this._client);

  Future<String> translateText(String text, String sourceLanguage, String targetLanguage) async {
    final translationService = translate.TranslateApi(_client);

    final translationRequest = translate.TranslateTextRequest(
      contents: [text],
      sourceLanguageCode: sourceLanguage,
      targetLanguageCode: targetLanguage,
    );

    final translationResponse = await translationService.projects.translateText(
      translationRequest,
      'projects/arboreal-melody-437809-a4',
    );

    return translationResponse.translations![0].translatedText!;
  }
}
