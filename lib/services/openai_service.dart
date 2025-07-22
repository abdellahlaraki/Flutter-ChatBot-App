import 'package:dart_openai/dart_openai.dart';
import '../models/chat_message.dart';

class OpenAiService {
  OpenAiService() {
    OpenAI.apiKey = "OPEN_AI_KEY";
  }
  
  Future<String> getChatResponse(List<ChatMessage> messages) async {
    try {
      final openAiMessages = messages
          .map((message) => OpenAIChatCompletionChoiceMessageModel(
                content: [
                  OpenAIChatCompletionChoiceMessageContentItemModel.text(message.text),
                ],
                role: message.isUser
                    ? OpenAIChatMessageRole.user
                    : OpenAIChatMessageRole.assistant,
              ))
          .toList();

      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: openAiMessages.reversed.toList(),
      );
      
      return chatCompletion.choices.first.message.content?.first.text ??
          "Désolé, une erreur de réponse est survenue.";
    } catch (e) {
      print("Erreur API: $e");
      return "Une erreur est survenue lors de la connexion à l'API.";
    }
  }
}