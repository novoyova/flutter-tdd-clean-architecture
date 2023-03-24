import 'package:dartz/dartz.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      int number = int.parse(str);
      if (number < 0) {
        throw const FormatException();
      }
      return Right(number);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure {
  @override
  List<Object?> get props => [];
}
