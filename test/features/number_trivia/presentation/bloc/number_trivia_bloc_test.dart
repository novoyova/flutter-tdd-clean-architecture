import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';
import 'package:tdd_clean_architecture/core/usecases/usecase.dart';
import 'package:tdd_clean_architecture/core/util/input_converter.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
    registerFallbackValue(const Params(number: 1));
    registerFallbackValue(NoParams());
  });

  // Check bloc initial state [I think not needed in new version of bloc]
  test('initialState should be Empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const testNumberString = '1';
    const testNumberParsed = 1;
    const testNumberTrivia = NumberTrivia(
      number: 1,
      text: 'Test trivia',
    );

    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(const Right(testNumberParsed));

    void setUpMockGetConcreteNumberTriviaSuccess() =>
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(testNumberTrivia));

    test(
      '''should call the InputConverter to validate and 
      convert the string to an unsigned integer''',
      () async {
        // Arrange
        // Synchronous use thenReturn
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        // Act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
        /*
        Executing the logic present inside [map event to state] takes some time,
        so if we don't wait, the verify inside this test will be executed
        before the stringToUnsignedInteger had chance to run within
        [map event to state]
        */
        await untilCalled(
            () => mockInputConverter.stringToUnsignedInteger(any()));
        // Assert
        verify(
            () => mockInputConverter.stringToUnsignedInteger(testNumberString));
      },
    );

    test(
      'should emit [Error] when the input is invalid',
      () {
        // Arrange
        // when(() => mockInputConverter.stringToUnsignedInteger(any()))
        //     .thenReturn(Left(InvalidInputFailure()));
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Left(InvalidInputFailure()));
        // Assert later
        /* 
          Is it safe to add an event before registering expectation?
          what if the logic run faster than expectLater?
          so we are going to register expectLater before adding an event
        */
        final expected = [
          // The initial state is always emitted first, so we can omit Empty()
          // Empty(),
          const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
        ];
        // This will make all the values which we are trying to test
        // are actually emitted, this test will be put onhold up to 30 sec
        expectLater(bloc.stream, emitsInOrder(expected));
        // Act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
      },
    );

    test(
      'should get data from the concrete use case',
      () async {
        // Arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        // Act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
        await untilCalled(() => mockGetConcreteNumberTrivia(any()));
        // Assert
        verify(() => mockGetConcreteNumberTrivia(
            const Params(number: testNumberParsed)));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () {
        // Arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        // Testing with stream so it is better to write assert first then act
        // Assert later
        final expected = [
          // Empty(),
          Loading(),
          const Loaded(trivia: testNumberTrivia),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // Act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // Arrange
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        // Assert later
        final expected = [
          // Empty(),
          Loading(),
          const Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // Act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
      },
    );

    test(
      '''should emit [Loading, Error] with a proper message for the error
      when getting data fails''',
      () async {
        // Arrange
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
        // Assert later
        final expected = [
          // Empty(),
          Loading(),
          const Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // Act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    const testNumberTrivia = NumberTrivia(
      number: 1,
      text: 'Test trivia',
    );

    void setUpMockGetRandomNumberTriviaSuccess() =>
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => const Right(testNumberTrivia));

    test(
      'should get data from the random use case',
      () async {
        // Arrange
        setUpMockGetRandomNumberTriviaSuccess();
        // Act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(() => mockGetRandomNumberTrivia(any()));
        // Assert
        verify(() => mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () {
        // Arrange
        setUpMockGetRandomNumberTriviaSuccess();
        // Testing with stream so it is better to write assert first then act
        // Assert later
        final expected = [
          // Empty(),
          Loading(),
          const Loaded(trivia: testNumberTrivia),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // Act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // Arrange
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        // Assert later
        final expected = [
          // Empty(),
          Loading(),
          const Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // Act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      '''should emit [Loading, Error] with a proper message for the error
      when getting data fails''',
      () async {
        // Arrange
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
        // Assert later
        final expected = [
          // Empty(),
          Loading(),
          const Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // Act
        bloc.add(GetTriviaForRandomNumber());
      },
    );
  });
}
