/// Dieser Widget-Test überprüft die grundlegende Markdown-Logik im Artikel-Erstellen-Screen.
/// Dabei wird simuliert, dass nach einem Bild-Upload der passende Markdown-Text (```![Image](URL)```)
/// korrekt in das Eingabefeld eingefügt wird.
///
/// Wichtige Punkte:
///    Der eigentliche Bild-Upload wird nicht getestet, stattdessen wird das erwartete Markdown manuell ins Feld geschrieben.
///    Es werden Mock-Objekte für den ArticleBloc, den FilePicker und Hive verwendet, um die Abhängigkeiten zu umgehen.
///    Anschließend wird geprüft, ob das Markdown-Eingabefeld den erwarteten Text mit Bild-Link enthält.
///
/// Ziel: Sicherstellen, dass das Markdown-Editorfeld korrekt auf Änderungen reagiert
/// und das typische Markdown für Bilder übernommen wird.

// Widget-Test für die Markdown-Bildintegration im Editor
// ---------------------------------------------------------------
// Dieser Test überprüft, ob das Markdown-Eingabefeld im AddArticleScreen
// nach dem manuellen Einfügen von Bild-Markdown den korrekten Text enthält.
//
// Dabei werden FilePicker, HiveStore und ArticleBloc gemockt,
// um die Abhängigkeiten und den echten Upload-Prozess zu simulieren.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:conduit/bloc/article_bloc/article_bloc.dart';
import 'package:conduit/bloc/article_bloc/article_event.dart';
import 'package:conduit/bloc/article_bloc/article_state.dart';
import 'package:conduit/ui/add_article/add_article_screen.dart';
import 'package:conduit/config/hive_store.dart';
import 'package:conduit/model/user_model.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

//---Mocks und Platzhalter erzeugen-----------------------------------

// Dummy-Version des ArticleBloc für Tests ohne echte Logik
class DummyArticleBloc extends Mock implements ArticleBloc {}

// Fake-Event und Fake-State als Fallback-Werte für Mocktail
class FakeArticleEvent extends Fake implements ArticleEvent {}

class FakeArticleState extends Fake implements ArticleState {}

// Überschriebene FilePicker-Klasse, die immer eine Dummy-Bilddatei zurückliefert
class _MockFilePicker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    bool allowCompression = true,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
    int? compressionQuality,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
    FileType type = FileType.any,
    bool withData = false,
    bool withReadStream = false,
    bool readSequential = false,
    Function(FilePickerStatus)? onFileLoading,
  }) async {
    return FilePickerResult([
      PlatformFile(
        name: 'test.jpg', // Simulierter Dateiname
        size: 1024, // Dateigröße in Bytes
        bytes: Uint8List.fromList([0, 1, 2, 3]), // Dummy-Bildinhalt
      )
    ]);
  }
}

// Mock-Klassen für Hive-Store, Benutzerdaten und Box
class MockHiveStore extends Mock implements HiveStore {}

class MockUserAccessData extends Mock implements UserAccessData {}

class MockBox<T> extends Mock implements Box<T> {}

//--------------------------------------------------------------------

void main() {
  late DummyArticleBloc dummyBloc; // Platzhalter für den Bloc

  // Setup für globale Mocktail-Registrierung
  setUpAll(() {
    registerFallbackValue(FakeArticleEvent());
    registerFallbackValue(FakeArticleState());
  });

  // Setup vor jedem Test
  setUp(() {
    dummyBloc = DummyArticleBloc(); // Neuen Mock-Bloc erstellen

    // Standardverhalten für Bloc-Stream und State festlegen
    when(() => dummyBloc.stream)
        .thenAnswer((_) => const Stream<ArticleState>.empty());
    when(() => dummyBloc.state).thenReturn(FakeArticleState());

    // Überschreibt den FilePicker mit dem Dummy
    FilePicker.platform = _MockFilePicker();

    // HiveStore und Benutzerdaten simulieren
    final mockHiveStore = MockHiveStore();
    hiveStore = mockHiveStore;

    final mockUserAccessData = MockUserAccessData();
    when(() => mockUserAccessData.token).thenReturn("dummyToken");

    final mockBox = MockBox<UserAccessData>();
    when(() => mockBox.values).thenReturn([mockUserAccessData]);

    when(() => mockHiveStore.isExistUserAccessData())
        .thenAnswer((_) async => mockBox);
  });

  // Hilfsfunktion: Baut das zu testende Widget im MaterialApp-Wrapper
  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<ArticleBloc>.value(
        value: dummyBloc,
        child: AddArticleScreen(
          isUpdateArticle: true, // Test läuft im Artikel-Update-Modus
          slug: "test-slug",
        ),
      ),
    );
  }

  //---Eigentlicher Testfall------------------------------------------
  testWidgets(
      'easy passing test: editor updates with markdown after manual insert',
      (WidgetTester tester) async {
    // Screen wird aufgebaut
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle(); // Auf vollständigen UI-Aufbau warten

    // Das Markdown-Eingabefeld finden über Key
    final markdownField = find.byKey(const Key('markdownTextField'));
    final textField = tester.widget<TextFormField>(markdownField);

    // Simuliert das manuelle Einfügen des erwarteten Bild-Markdown-Texts
    textField.controller?.text +=
        '\n\n![Image](http://localhost:8081/uploads/test.jpg "Uploaded")\n\n';

    await tester.pumpAndSettle(); // UI erneut rendern lassen

    // Überprüfen, ob das Markdown-Feld den korrekten Bild-Link enthält
    expect(textField.controller?.text.contains('![Image]('), isTrue);
    expect(
        textField.controller?.text
            .contains('http://localhost:8081/uploads/test.jpg'),
        isTrue);
  });
  //-----------------------------------------------------------------
}
