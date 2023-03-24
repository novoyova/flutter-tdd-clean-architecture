import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
      'should return an integer when the string represents an unsigned integer',
      () async {
        // Arrange
        const str = '123';
        // Act
        final result = inputConverter.stringToUnsignedInteger(str);
        // Assert
        expect(result, const Right(123));
      },
    );

    test(
      'should return a Failure when the string is not an integer',
      () async {
        // Arrange
        const str = 'abc';
        // Act
        final result = inputConverter.stringToUnsignedInteger(str);
        // Assert
        expect(result, Left(InvalidInputFailure()));
      },
    );

    test(
      'should return Failure when the string is a negative integer',
      () async {
        // Arrange
        const str = '-123';
        // Act
        final result = inputConverter.stringToUnsignedInteger(str);
        // Assert
        expect(result, Left(InvalidInputFailure()));
      },
    );
  });
}
