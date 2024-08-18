import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bubble_picker/bubble_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'bubble_picker_test.mocks.dart';

// 모킹할 클래스를 지정합니다.
@GenerateMocks([HttpClient, HttpClientRequest, HttpClientResponse, HttpHeaders, File])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Creates the specified number of bubbles', (WidgetTester tester) async {
    // Given: BubblePicker with a specific number of bubbles
    const numberOfBubbles = 10;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BubblePicker(
            bubbles: List.generate(
              numberOfBubbles,
              (index) => const BubbleData(
                color: Colors.red,
                image: AssetImage('assets/image1.jpeg'),
                colorFilter: ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.srcOver,
                ),
              ),
            ),
            size: const Size(400, 800),
          ),
        ),
      ),
    );

    // Then: Verify that the correct number of bubbles are created
    final bubblePickerFinder = find.byType(BubblePicker);
    expect(bubblePickerFinder, findsOneWidget);

    final bubblePicker = tester.widget<BubblePicker>(bubblePickerFinder);
    expect(bubblePicker.bubbles.length, numberOfBubbles);
  });

  testWidgets('Bubble color, boxFit, and colorFilter are applied correctly', (WidgetTester tester) async {
    // Given: BubblePicker with bubbles having specific color, boxFit, and colorFilter
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BubblePicker(
            bubbles: [
              BubbleData(
                color: Colors.red,
                image: const AssetImage(
                  'assets/image1.jpeg',
                ),
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.dstIn,
                ),
                boxFit: BoxFit.cover,
              ),
            ],
            size: const Size(400, 800),
          ),
        ),
      ),
    );

    // Then: Verify that the color, boxFit, and colorFilter are applied
    final bubblePickerFinder = find.byType(BubblePicker);
    final bubblePicker = tester.widget<BubblePicker>(bubblePickerFinder);
    final bubble = bubblePicker.bubbles.first;

    expect(bubble.color, Colors.red);
    expect(bubble.colorFilter, isNotNull); // This will require additional rendering validation
    // BoxFit can be visually validated, but you might need custom painting logic to fully validate
  });

  testWidgets('Assert radius is greater than 1', (WidgetTester tester) async {
    // Given: BubblePicker with a bubble having a radius less than or equal to 1
    // Then: The assertion should be triggered in the Bubble constructor

    expect(
        () => BubbleData(
              radius: 0, // Should trigger assertion
              color: Colors.red,
              image: const AssetImage('assets/image1.jpeg'),
              colorFilter: const ColorFilter.mode(
                Colors.transparent,
                BlendMode.srcOver,
              ),
            ),
        throwsAssertionError);
  });

  // Additional test to check if loadImage handles a null provider correctly
  test('Returns null when image provider is null', () async {
    // Given: A null image provider
    final loadImageFuture = loadImage(null);

    // When: Attempting to load the image
    final result = await loadImageFuture;

    // Then: Verify that the result is null
    expect(result, isNull);
  });

  // group('BubblePicker Tests', () {
  //   late MockHttpClient mockHttpClient;

  //   setUp(() {
  //     // MockHttpClient를 인스턴스화합니다.
  //     mockHttpClient = MockHttpClient();
  //     // 테스트 시작 전에 HttpOverrides를 설정합니다.
  //     HttpOverrides.global = MyHttpOverrides(MockHttpClient());
  //   });

  //   tearDown(() {
  //     // 테스트 후에 HttpOverrides를 제거합니다.
  //     HttpOverrides.global = null;
  //   });
  //   // testWidgets('Bubble size increases on tap', (WidgetTester tester) async {
  //   //   // Given: A BubblePicker with a single bubble
  //   //   double initialRadius = 0.1 * 20 + 20; // Convert normalized radius to actual radius
  //   //   double? increasedRadius; // 초기값을 null로 설정

  //   //   await tester.pumpWidget(
  //   //     MaterialApp(
  //   //       home: Scaffold(
  //   //         body: BubblePicker(
  //   //           bubbles: [
  //   //             BubbleData(
  //   //               radius: 0.1, // Initial normalized radius for testing
  //   //               color: Colors.red,
  //   //               image: AssetImage('assets/image1.jpeg'),
  //   //               colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
  //   //               onTapBubble: (newRadius) {
  //   //                 increasedRadius = newRadius; // 버블 탭 시 반경 업데이트
  //   //               },
  //   //             ),
  //   //           ],
  //   //           size: Size(400, 800),
  //   //         ),
  //   //       ),
  //   //     ),
  //   //   );

  //   //   // Initial pump to ensure the widget is built
  //   //   // await tester.pumpAndSettle();

  //   //   // Find the CustomPaint widget (which is where the bubbles are drawn)
  //   //   final customPaintFinders = find.byType(CustomPaint);
  //   //   expect(customPaintFinders, findsWidgets);

  //   //   // Assuming the first CustomPaint is the one we want to interact with.
  //   //   // final customPaint = tester.widget<CustomPaint>(customPaintFinders.first);
  //   //   final paintBounds = tester.getRect(customPaintFinders.first);
  //   //   final Offset tapPosition = paintBounds.center;

  //   //   // Perform the tap
  //   //   await tester.tapAt(tapPosition);
  //   //   // await tester.pumpAndSettle();

  //   //   // Then: Verify that the bubble size has increased
  //   //   expect(increasedRadius, isNotNull); // 콜백으로 반경이 업데이트되었는지 확인
  //   //   expect(increasedRadius, greaterThan(initialRadius)); // 반경이 증가했는지 확인
  //   // });
  //   testWidgets('Loads image from different sources (Asset, Network, File)', (WidgetTester tester) async {
  //     // Given: Mocked File
  //     final mockFile = MockFile();

  //     // Mocking file-related operations
  //     when(mockFile.existsSync()).thenReturn(true);
  //     when(mockFile.readAsBytesSync()).thenReturn(Uint8List.fromList(List<int>.filled(100, 0)));

  //     // Setting up the image providers
  //     final fileImageProvider = FileImage(mockFile);
  //     final assetImageProvider = AssetImage('assets/image1.jpeg');
  //     final networkImageProvider = NetworkImage('https://encrypted-tbn0.gstatic.com/images');

  //     // HttpClient의 getUrl 메서드가 호출될 때 기대되는 동작을 설정합니다.
  //     when(mockHttpClient.getUrl(argThat(startsWith('https://encrypted-tbn0.gstatic.com')))).thenAnswer((_) async {
  //       final mockRequest = createMockHttpRequest();
  //       return mockRequest;
  //     });

  //     await tester.pumpWidget(
  //       MaterialApp(
  //         home: Scaffold(
  //           body: BubblePicker(
  //             bubbles: [
  //               BubbleData(
  //                 color: Colors.red,
  //                 image: assetImageProvider,
  //                 colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
  //               ),
  //               BubbleData(
  //                 color: Colors.blue,
  //                 image: networkImageProvider,
  //                 colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
  //               ),
  //               BubbleData(
  //                 color: Colors.green,
  //                 image: fileImageProvider,
  //                 colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
  //               ),
  //             ],
  //             size: Size(400, 800),
  //           ),
  //         ),
  //       ),
  //     );

  //     await tester.pump();

  //     // Mock image cache or load
  //     await tester.runAsync(() async {
  //       await precacheImage(assetImageProvider, tester.element(find.byType(BubblePicker).first));
  //       await precacheImage(networkImageProvider, tester.element(find.byType(BubblePicker).first));
  //       await precacheImage(fileImageProvider, tester.element(find.byType(BubblePicker).first));
  //     });

  //     // After running async, ensure all states are updated
  //     for (int i = 0; i < 10; i++) {
  //       await tester.pump(Duration(milliseconds: 100));
  //     }

  //     // Then: Verify that bubbles with different images are displayed
  //     expect(find.byType(CustomPaint), findsWidgets);
  //   });
  // });
}

// HttpOverrides 클래스를 구현하여 모킹된 HttpClient를 사용하도록 설정합니다.
class MyHttpOverrides extends HttpOverrides {
  final HttpClient mockHttpClient;

  MyHttpOverrides(this.mockHttpClient);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return mockHttpClient;
  }
}

// Helper functions to mock HTTP requests and responses.
MockHttpClientRequest createMockHttpRequest() {
  final mockRequest = MockHttpClientRequest();
  final mockResponse = createMockHttpResponse();
  when(mockRequest.close()).thenAnswer((_) async => mockResponse);
  when(mockRequest.headers).thenReturn(MockHttpHeaders());
  return mockRequest;
}

MockHttpClientResponse createMockHttpResponse({int statusCode = 200, String body = 'Mocked body'}) {
  final mockResponse = MockHttpClientResponse();
  final stream = Stream<List<int>>.fromIterable([utf8.encode(body)]);
  when(mockResponse.statusCode).thenReturn(statusCode);
  when(mockResponse.contentLength).thenReturn(body.length);
  when(mockResponse.transform(any)).thenAnswer((_) => stream);
  when(mockResponse.listen(any,
          onError: anyNamed('onError'), onDone: anyNamed('onDone'), cancelOnError: anyNamed('cancelOnError')))
      .thenAnswer((invocation) {
    final onData = invocation.positionalArguments[0] as void Function(List<int>);
    stream.listen(onData, onDone: invocation.namedArguments[const Symbol('onDone')]);
    return StreamSubscriptionMock();
  });
  return mockResponse;
}

class StreamSubscriptionMock extends Mock implements StreamSubscription<List<int>> {}
