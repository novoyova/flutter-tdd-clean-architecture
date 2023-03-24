import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/core/error/exceptions.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
    // If it is not Dart's built-in data types, need to register it
    // like int, String no need to register it
    registerFallbackValue(Uri());
  });

  void setUpMockHttpClientSuccess200() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    const testNumber = 1;
    final testNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number 
      being the endpoint and with application/json header''',
      () async {
        // Arrange
        setUpMockHttpClientSuccess200();
        // Act
        dataSource.getConcreteNumberTrivia(testNumber);
        // Assert
        verify(
          () => mockHttpClient.get(
            Uri.parse('http://numbersapi.com/$testNumber'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      '''should return NumberTrivia 
      when the response code is 200 (success)''',
      () async {
        // Arrange
        setUpMockHttpClientSuccess200();
        // Act
        final result = await dataSource.getConcreteNumberTrivia(testNumber);
        // Assert
        expect(result, testNumberTriviaModel);
      },
    );

    test(
      '''should throw a ServerException 
      when the response code is 404 or other''',
      () async {
        // Arrange
        setUpMockHttpClientFailure404();
        // Act
        final call = dataSource.getConcreteNumberTrivia;
        // Assert
        expect(call(testNumber), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final testNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number 
      being the endpoint and with application/json header''',
      () async {
        // Arrange
        setUpMockHttpClientSuccess200();
        // Act
        dataSource.getRandomNumberTrivia();
        // Assert
        verify(
          () => mockHttpClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      '''should return NumberTrivia 
      when the response code is 200 (success)''',
      () async {
        // Arrange
        setUpMockHttpClientSuccess200();
        // Act
        final result = await dataSource.getRandomNumberTrivia();
        // Assert
        expect(result, testNumberTriviaModel);
      },
    );

    test(
      '''should throw a ServerException 
      when the response code is 404 or other''',
      () async {
        // Arrange
        setUpMockHttpClientFailure404();
        // Act
        final call = dataSource.getRandomNumberTrivia;
        // Assert
        expect(call, throwsA(isA<ServerException>()));
      },
    );
  });
}
