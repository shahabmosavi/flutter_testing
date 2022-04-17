import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
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

  void arrangeNewsServiceReturns3ArticlesAfter2Seconds() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return articlesFromService;
    });
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

  testWidgets(
    "title is displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('News'), findsOneWidget);
    },
  );
  testWidgets(
    "loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3ArticlesAfter2Seconds();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    "articles are displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      for (final article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
