import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/product_model.dart';

class AIService {
  // Use the key you copied from Google AI Studio
  static const String _apiKey = 'AIzaSyBgpYLyP9IgMsjCZmGGEThKOIeREdl_7TM';

  Future<String> getProductRecommendation(
    List<Product> products,
    String query,
  ) async {
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      // We give the AI a list of your products so it knows what you are selling
      final productList = products
          .map((p) => "${p.name} for \$${p.price}")
          .join(", ");

      final prompt =
          "You are a shopping assistant for FYNDO. "
          "Here are our products: $productList. "
          "The user is asking: '$query'. "
          "Give a very short, friendly recommendation in 1-2 sentences.";

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? "I couldn't find a recommendation right now.";
    } catch (e) {
      return "AI Error: $e";
    }
  }
}
