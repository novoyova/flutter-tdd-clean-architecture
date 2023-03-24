import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  const testNumber = 1;
  const testNumberTrivia = NumberTrivia(number: testNumber, text: 'test');

  test(
    'should get trivia number from the repository',
    () async {
      // Arrange
      /*
        Mockito: Error with 'any'

        when(mockNumberTriviaRepository.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(testNumberTrivia));

        verify(mockNumberTriviaRepository.getConcreteNumberTrivia(testNumber));
      */

      /*
        Mocktail
        
        when(() => mockNumberTriviaRepository.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(testNumberTrivia));

        verify(() => mockNumberTriviaRepository.getConcreteNumberTrivia(testNumber));
      */

      when(() => mockNumberTriviaRepository.getConcreteNumberTrivia(any()))
          .thenAnswer((_) async => const Right(testNumberTrivia));

      // Act
      final result = await usecase(const Params(number: testNumber));

      // Assert
      expect(result, const Right(testNumberTrivia));
      // verify that a method on a mock object was called with the given arguments
      verify(
          () => mockNumberTriviaRepository.getConcreteNumberTrivia(testNumber));
      // ensure no redundant invocations occur
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    },
  );
}
