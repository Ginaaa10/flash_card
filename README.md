# flash_card — Whiteboard OCR & Question Generation

This commit adds a whiteboard drawing widget, on-device OCR integration, and a small server to generate questions (optionally using OpenAI).

What I added
- lib/widgets/whiteboard.dart — simple drawable whiteboard widget (RepaintBoundary)
- lib/widgets/whiteboard_capture.dart — button to capture whiteboard, run OCR, and call backend
- lib/services/ocr_service.dart — on-device OCR using google_mlkit_text_recognition
- lib/services/question_generator_service.dart — sends recognized text to backend
- server/index.js & server/package.json — minimal Express server that calls OpenAI if OPENAI_API_KEY is set; otherwise returns dummy questions
- updated pubspec.yaml to include necessary packages

How to run (Flutter app)
1. Install packages: flutter pub get
2. Use the Whiteboard widget in your app. Example quick usage:

```dart
final wbKey = GlobalKey();

Column(
  children: [
    Expanded(child: Whiteboard(repaintKey: wbKey)),
    WhiteboardCaptureButton(repaintKey: wbKey),
  ],
)
```

3. Run the app on device/emulator. Note: for Android emulator the default backend URL in the Flutter code points to http://10.0.2.2:8080/generate. If you run the server elsewhere, set the environment variable QUESTION_BACKEND_URL when building or change the string in code.

How to run the server (node)
1. cd server
2. npm install
3. (Optional) Set OPENAI_API_KEY environment variable to enable real question generation using OpenAI.
4. npm start

Security & notes
- Do NOT commit your OpenAI API key. Set it in the environment on your server or machine.
- The server attempts to parse the assistant output as JSON; prompt the model to return valid JSON only for best results.

If you want, I can open a PR from branch `feature/whiteboard-ocr` into `main` and/or tweak the prompt templates and JSON schema.
