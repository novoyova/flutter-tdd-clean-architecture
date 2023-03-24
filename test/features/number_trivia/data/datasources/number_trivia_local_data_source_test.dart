import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_architecture/core/error/exceptions.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSourceImpl;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSourceImpl = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final testNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    /*
      If you need fixed return value on method call 
      then we should use thenReturn(…)

      If you need to perform some operation or 
      the value need to be computed at run time 
      then we should use thenAnswer(…)
    */
    test(
      '''should return NumberTrivia from SharedPreferences
      when there is one in the cache''',
      () async {
        // Arrange
        when(() => mockSharedPreferences.getString(any()))
            .thenReturn(fixture('trivia_cached.json'));
        // Act
        final result = await dataSourceImpl.getLastNumberTrivia();
        // Assert
        // verify that we actually gotten the number trivia from shared preferences
        verify(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, testNumberTriviaModel);
      },
    );

    test(
      'should throw a CacheException when there is not a cached value',
      () async {
        // Arrange
        when(() => mockSharedPreferences.getString(any())).thenReturn(null);
        // Act
        final call = dataSourceImpl.getLastNumberTrivia;
        // Assert
        expect(call, throwsA(isA<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    const testNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'Test text');

    test(
      'should call SharedPreferences to cache the data',
      () async {
        // Assert
        when(() => dataSourceImpl.cacheNumberTrivia(testNumberTriviaModel))
            .thenAnswer((_) async => true);
        // Act
        dataSourceImpl.cacheNumberTrivia(testNumberTriviaModel);
        // Assert
        final expectedJsonString = json.encode(testNumberTriviaModel.toJson());
        // check if the mockSharedPreferences was called
        // with the proper json string
        verify(() => mockSharedPreferences.setString(
            CACHED_NUMBER_TRIVIA, expectedJsonString));
      },
    );
  });
}
