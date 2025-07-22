// lib/services/openai_service.dart
import 'package:dart_openai/dart_openai.dart';

class OpenAiService {
  OpenAiService() {
    // Set your OpenAI API key here.
    // IMPORTANT: In a real app, use environment variables or a secure secret manager.
    OpenAI.apiKey = "OPEN_AI_KEY";
  }

  Future<String> getChatResponse(String prompt) async {
    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      return chatCompletion.choices.first.message.content?.first.text ??
          "Sorry, I couldn't get a response.";
    } catch (e) {
      print("Error fetching response: $e");
      return "An error occurred while fetching the response.";
    }
  }
}