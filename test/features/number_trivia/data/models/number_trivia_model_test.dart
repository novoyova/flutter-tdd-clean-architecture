import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const testNumberTriviaModel = NumberTriviaModel(
    number: 1,
    text: 'Test text',
  );

  test(
    "should be a subclass of NumberTrivia entity",
    () async {
      // Assert
      expect(testNumberTriviaModel, isA<NumberTrivia>());
    },
  );

  group('fromJson', () {
    test(
      "should return a valid model when the JSON number is an integer",
      () async {
        // Arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('trivia.json'));
        // Act
        final result = NumberTriviaModel.fromJson(jsonMap);
        // Assert
        expect(result, testNumberTriviaModel);
      },
    );

    test(
      "should return a valid model when the JSON number is regarded as a double",
      () async {
        // Arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('trivia_double.json'));
        // Act
        final result = NumberTriviaModel.fromJson(jsonMap);
        // Assert
        expect(result, testNumberTriviaModel);
      },
    );
  });

  group('toJson', () {
    test(
      'should return a JSON map containing the proper data',
      () async {
        // Arrange

        // Act
        final result = testNumberTriviaModel.toJson();
        // Assert
        final expectedMap = {
          "text": "Test text",
          "number": 1,
        };
        expect(result, expectedMap);
      },
    );
  });
}
