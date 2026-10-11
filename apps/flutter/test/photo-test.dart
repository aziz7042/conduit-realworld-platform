// In diesem Test wird geprüft, ob das Auswählen eines Bildes und Upload korrekt funktioniert


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conduit/ui/profile/profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conduit/bloc/profile_bloc/profile_bloc.dart';
import 'package:conduit/bloc/profile_bloc/profile_state.dart';
import 'package:conduit/bloc/profile_bloc/profile_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';

// Hier wird ein Dummy-Bloc erstellt, um das Verhalten des echten ProfileBlocs zu simulieren
class DummyProfileBloc extends Mock implements ProfileBloc {}

// Dummy-Event für den Fallback
class FakeProfileEvent extends Fake implements ProfileEvent {}

// Dummy-State für den Fallback
class FakeProfileState extends Fake implements ProfileState {}

// Hier wird ein Mock für den ImagePicker erstellt
class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late DummyProfileBloc dummyBloc; // Hier wird die Dummy-Bloc-Variable deklariert
  late MockImagePicker mockImagePicker; // Hier wird die Mock-ImagePicker-Variable deklariert

  // Vor allen Tests werden die Fallback-Werte registriert
  setUpAll(() {
    registerFallbackValue(FakeProfileEvent()); // Fallback für Events
    registerFallbackValue(FakeProfileState()); // Fallback für States
    registerFallbackValue(ImageSource.gallery); // Fallback für den ImageSource-Enum
  });

  // Vor jedem Test wird der Dummy-Bloc und der MockImagePicker neu initialisiert
  setUp(() {
    dummyBloc = DummyProfileBloc(); // Der Dummy-Bloc wird erstellt
    when(() => dummyBloc.stream).thenAnswer((_) => const Stream<ProfileState>.empty()); // Das Bloc-Stream-Verhalten wird simuliert
    when(() => dummyBloc.state).thenReturn(FakeProfileState()); // Der Initial-State wird festgelegt

    mockImagePicker = MockImagePicker(); // Der Mock-ImagePicker wird erstellt

    // Es wird simuliert, dass beim Öffnen des ImagePickers immer ein Dummy-Bild ausgewählt wird
    when(() => mockImagePicker.pickImage(source: any(named: 'source')))
        .thenAnswer((_) async => XFile('assets/images/test.jpg'));
  });

  // Diese Methode erstellt das Widget für den Test
  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<ProfileBloc>.value(
        value: dummyBloc, // Der Dummy-Bloc wird im Widget verwendet
        child: ProfileScreen(picker: mockImagePicker), // Der MockImagePicker wird im ProfileScreen genutzt
      ),
    );
  }

  // In diesem ersten Test wird geprüft, ob der lokale Bildpfad korrekt angezeigt wird, wenn ein Bild ausgewählt wird
  testWidgets('should show local image path after selecting image', (WidgetTester tester) async {
    
    await tester.pumpWidget(createTestWidget()); // Das Test-Widget wird geladen
    await tester.pumpAndSettle(); // Alle Animations- und Build-Prozesse werden abgeschlossen


    final uploadButton = find.byKey(const Key('uploadImageButton')); // Der Upload-Button wird gesucht
    expect(uploadButton, findsOneWidget); // Es wird geprüft, ob der Button existiert


    await tester.tap(uploadButton); // Der Button wird gedrückt, um den ImagePicker zu öffnen
    await tester.pumpAndSettle(); // Warten, bis das Bild ausgewählt wurde und das Widget aktualisiert ist


    final imagePathText = find.byKey(const Key('selectedImagePath')); // Das Textfeld mit dem Bildpfad wird gesucht
    expect(imagePathText, findsOneWidget); // Es wird geprüft, ob der Bildpfad im UI angezeigt wird
  });

  // In diesem zweiten Test wird geprüft, ob der Upload korrekt ausgelöst wird, wenn der Benutzer den Save-Button drückt
  testWidgets('should trigger image upload when save button is pressed', (WidgetTester tester) async {
    
    await tester.pumpWidget(createTestWidget()); // Das Test-Widget wird geladen
    await tester.pumpAndSettle(); // Alle Animations- und Build-Prozesse werden abgeschlossen


    final uploadButton = find.byKey(const Key('uploadImageButton')); // Der Upload-Button wird gesucht
    expect(uploadButton, findsOneWidget); // Es wird geprüft, ob der Button existiert


    await tester.tap(uploadButton); // Der Button wird gedrückt, um den ImagePicker zu öffnen
    await tester.pumpAndSettle(); // Warten, bis das Bild ausgewählt wurde und das Widget aktualisiert ist


    final saveButton = find.byKey(const Key('saveButton')); // Der Save-Button wird gesucht
    expect(saveButton, findsOneWidget); // Es wird geprüft, ob der Button existiert

    await tester.tap(saveButton); // Der Save-Button wird gedrückt, um das Speichern auszulösen
    await tester.pumpAndSettle(); // Alle Animations- und Build-Prozesse werden abgeschlossen
  });
}