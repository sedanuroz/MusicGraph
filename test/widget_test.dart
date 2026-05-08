import 'package:flutter_test/flutter_test.dart';
import 'package:music_graph_app/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MusicGraphApp());
  });
}