import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/core/network/network_info.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfoImpl;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(mockInternetConnectionChecker);
  });

  group('isConnected', () {
    test(
      'should foward the call to InternetConnectionChecker.hasConnection',
      () async {
        // Arrange
        final testHasConnectionFuture = Future.value(true);
        when(() => mockInternetConnectionChecker.hasConnection)
            .thenAnswer((_) => testHasConnectionFuture);
        // Act
        final result = networkInfoImpl.isConnected;

        // Assert
        // check if the call only FOWARDED and nothing more
        expect(result, testHasConnectionFuture);
      },
    );
  });
}
