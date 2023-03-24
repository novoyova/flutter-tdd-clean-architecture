import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/core/error/exceptions.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';
import 'package:tdd_clean_architecture/core/network/network_info.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const testNumber = 1;
    const testNumberTriviaModel = NumberTriviaModel(
      number: testNumber,
      text: 'Test trivia',
    );
    const NumberTrivia testNumberTrivia = testNumberTriviaModel;

    test(
      'should check if the device is online',
      () async {
        // Arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => testNumberTriviaModel);
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel))
            .thenAnswer((_) async => Future<void>);

        // Act
        repository.getConcreteNumberTrivia(testNumber);
        // Assert
        // check if isConnected getter is called
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        '''should return remote data 
        when the call to remote data source is successfull''',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
              .thenAnswer((_) async => testNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(
                testNumberTriviaModel,
              )).thenAnswer((_) async => Future<void>);
          // Act
          final result = await repository.getConcreteNumberTrivia(testNumber);
          // Assert
          // check if remote data source was called with the proper number in the argument
          verify(
              () => mockRemoteDataSource.getConcreteNumberTrivia(testNumber));
          expect(result, equals(const Right(testNumberTrivia)));
        },
      );

      test(
        '''should cache data locally 
        when the call to remote data source is successfull''',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
              .thenAnswer((_) async => testNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(
                testNumberTriviaModel,
              )).thenAnswer((_) async => Future<void>);

          // Act
          await repository.getConcreteNumberTrivia(testNumber);
          // Assert
          verify(
              () => mockRemoteDataSource.getConcreteNumberTrivia(testNumber));
          verify(() =>
              mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel));
        },
      );

      test(
        '''should return ServerFailure 
        when the call to remote data source is unsuccessfull''',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
              .thenThrow(ServerException());
          // Act
          final result = await repository.getConcreteNumberTrivia(testNumber);
          // Assert
          verify(
              () => mockRemoteDataSource.getConcreteNumberTrivia(testNumber));
          // When fail, make sure cache data is not called
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        '''should return last locally cached data 
        when the cached data is present''',
        () async {
          // Arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);
          // Act
          final result = await repository.getConcreteNumberTrivia(testNumber);
          // Assert
          // make sure there is no interaction with remote data source
          verifyZeroInteractions(mockRemoteDataSource);
          // check if getLastNumberTrivia has been called once
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(const Right(testNumberTrivia)));
        },
      );

      test(
        '''should return CacheFailure
        when there is no cached data present''',
        () async {
          // Arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // Act
          final result = await repository.getConcreteNumberTrivia(testNumber);

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    const testNumberTriviaModel = NumberTriviaModel(
      number: 123,
      text: 'Test trivia',
    );
    const NumberTrivia testNumberTrivia = testNumberTriviaModel;

    test(
      'should check if the device is online',
      () async {
        // Arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => testNumberTriviaModel);
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel))
            .thenAnswer((_) async => Future<void>);

        // Act
        repository.getRandomNumberTrivia();
        // Assert
        // check if isConnected getter is called
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        '''should return remote data 
        when the call to remote data source is successfull''',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(
                testNumberTriviaModel,
              )).thenAnswer((_) async => Future<void>);
          // Act
          final result = await repository.getRandomNumberTrivia();
          // Assert
          // check if remote data source was called with the proper number in the argument
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          expect(result, equals(const Right(testNumberTrivia)));
        },
      );

      test(
        '''should cache data locally 
        when the call to remote data source is successfull''',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(
                testNumberTriviaModel,
              )).thenAnswer((_) async => Future<void>);

          // Act
          await repository.getRandomNumberTrivia();
          // Assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verify(() =>
              mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel));
        },
      );

      test(
        '''should return ServerFailure 
        when the call to remote data source is unsuccessfull''',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          // Act
          final result = await repository.getRandomNumberTrivia();
          // Assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          // When fail, make sure cache data is not called
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        '''should return last locally cached data 
        when the cached data is present''',
        () async {
          // Arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);
          // Act
          final result = await repository.getRandomNumberTrivia();
          // Assert
          // make sure there is no interaction with remote data source
          verifyZeroInteractions(mockRemoteDataSource);
          // check if getLastNumberTrivia has been called once
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(const Right(testNumberTrivia)));
        },
      );

      test(
        '''should return CacheFailure
        when there is no cached data present''',
        () async {
          // Arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // Act
          final result = await repository.getRandomNumberTrivia();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
