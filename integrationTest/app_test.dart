import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/article_page.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';

import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;
  setUp(() {
    mockNewsService = MockNewsService();
  });
  final List<Article> articlesFromService = [
    Article(title: 'test 1', content: "test 1 content"),
    Article(title: 'test 2', content: "test 2 content"),
    Article(title: 'test 3', content: "test 3 content"),
  ];
  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles())
        .thenAnswer((_) async => articlesFromService);
  }

  MaterialApp createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  testWidgets("""Tapping on the first article excerpt opens the article page
  where the full article content is displayed""", (WidgetTester tester) async {
    arrangeNewsServiceReturns3Articles();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.tap(find.text('test 1 content'));
    await tester.pumpAndSettle();

    expect(find.byType(NewsPage), findsNothing);
    expect(find.byType(ArticlePage), findsOneWidget);

    expect(find.text('test 1 content'), findsOneWidget);
    expect(find.text('test 1'), findsOneWidget);
  });
}
