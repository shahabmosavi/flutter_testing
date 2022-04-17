import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService;
  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });
  group('get articles', () {
    final List<Article> articlesFromService = [
      Article(title: 'test 1', content: "test 1 content"),
      Article(title: 'test 2', content: "test 2 content"),
      Article(title: 'test 3', content: "test 3 content"),
    ];
    void arrangeNewsServiceReturns3Articles() {
      when(() => mockNewsService.getArticles())
          .thenAnswer((_) async => articlesFromService);
    }

    test('initial values are correct', () {
      expect(sut.articles, []);
      expect(sut.isLoading, false);
    });
    test("""indicates loading of data,
  sets articles to the ones from the serivce,
  indicates that data is not being loaded anymore""", () async {
      arrangeNewsServiceReturns3Articles();
      final future = sut.getArticles();
      expect(sut.isLoading, true);
      await future;
      expect(sut.isLoading, false);
      expect(sut.articles, articlesFromService);
    });
  });
}
