import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import 'package:conduit/utils/AppColors.dart';
import 'package:conduit/bloc/article_bloc/article_bloc.dart';
import 'package:conduit/bloc/article_bloc/article_event.dart';
import 'package:conduit/model/new_article_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conduit/config/hive_store.dart';
import 'package:conduit/model/user_model.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddArticleScreen extends StatefulWidget {
  static const addArticleUrl = '/addArticle';
  final bool isUpdateArticle;
  final String? slug;

  const AddArticleScreen({
    Key? key,
    required this.isUpdateArticle,
    this.slug,
  }) : super(key: key);

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late TextEditingController titleCtr, aboutTitleCtr, articleCtr;
  final List<String> tags = [];
  bool isUploading = false;
  late ArticleBloc articleBloc;

  @override
  void initState() {
    super.initState();
    articleBloc = context.read<ArticleBloc>();
    titleCtr = TextEditingController();
    aboutTitleCtr = TextEditingController();
    articleCtr = TextEditingController();
  }

  // Upload-Image logik und Bild automatisch Markdown einfügen
  //--1/4-------------------------------------
  // Diese Methode öffnet einen Dateiauswahldialog, damit der Benutzer ein Bild auswählen kann.
  // Nach erfolgreichem Upload wird die Bild-URL automatisch im Markdown-Format in das Textfeld eingefügt,
  // sodass das Bild anschließend in der Markdown-Vorschau gerendert wird.
  Future<void> uploadImageAndInsertMarkdown() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Nur Bilddateien dürfen ausgewählt werden
        withData:
            true, // Die Bilddaten sollen direkt als Bytes mitgeliefert werden
      );

      if (result == null || result.files.single.bytes == null) {
        debugPrint(
            " No image selected or no bytes found."); // Fehlermeldung in der Konsole
        return; // Methode abbrechen, wenn kein Bild ausgewählt wurde
      }

      final fileBytes = result.files.single.bytes!; // Bilddaten als Byte-Array
      final fileName =
          result.files.single.name; // Ursprünglicher Dateiname des Bildes

      final box = await hiveStore
          .isExistUserAccessData(); // Benutzer-Daten (inkl. Auth-Token) aus Hive holen
      final token =
          box?.values.first.token; // Authentifizierungs-Token extrahieren
      final slug = widget.slug; // Slug des aktuellen Artikels

      if (token == null || slug == null) {
        // Wenn Token oder Slug fehlen, Fehlermeldung anzeigen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token or slug is missing.")),
        );
        return;
      }

      setState(() => isUploading =
          true); // Lade-Status aktivieren (z.B. Button deaktivieren, Spinner anzeigen)

      final uri = Uri.parse(
          "http://localhost:8081/articles/$slug/images"); // Ziel-URL für den Bild-Upload
      final request = http.MultipartRequest("POST", uri)
        ..headers['Authorization'] =
            'Token $token' // Authentifizierung per Token im Header mitschicken
        ..files.add(http.MultipartFile.fromBytes('file', fileBytes,
            filename: fileName)); // Bild als Multipart anhängen

      debugPrint(" Uploading to $uri"); // Debug-Ausgabe zur Kontrolle

      final response = await request.send(); // Anfrage an Backend senden
      final body = await response.stream
          .bytesToString(); // Antwort-Body in lesbaren Text umwandeln

      debugPrint(
          " Backend response: $body"); // Debug-Ausgabe der Backend-Antwort

      if (response.statusCode == 200) {
        // Wenn Upload erfolgreich
        final json = jsonDecode(body); // Antwort als JSON parsen
        final imageUrl = json['uploaded']; // Bild-URL auslesen

        if (imageUrl is String && imageUrl.trim().isNotEmpty) {
          debugPrint("Final image URL to embed: $imageUrl");

          setState(() {
            // Bild-URL im Markdown-Syntax ans Textfeld anhängen
            articleCtr.text += '\n\n![Image]($imageUrl "Uploaded")\n\n';
          });

          // Erfolgreiche Meldung anzeigen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image uploaded and added.")),
          );
        } else {
          // Ungültige Bild-URL vom Backend erhalten
          debugPrint("Invalid imageUrl returned: $imageUrl");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid image URL returned.")),
          );
        }
      } else {
        // Upload fehlgeschlagen, Statuscode anzeigen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      // Allgemeiner Fehlerfall
      debugPrint(" Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error occurred.")),
      );
    } finally {
      setState(() => isUploading = false); // Lade-Status wieder deaktivieren
    }
  }
  //---------------------------------------

  void submit() {
    if (_form.currentState!.validate()) {
      final model = ArticleModel(
        article: Article(
          title: titleCtr.text.trim(),
          description: aboutTitleCtr.text.trim(),
          body: articleCtr.text.trim(),
          tagList: tags,
        ),
      );

      if (widget.isUpdateArticle) {
        articleBloc
            .add(UpdateArticleEvent(articleModel: model, slug: widget.slug!));
      } else {
        articleBloc.add(SubmitArticleEvent(articleModel: model));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(widget.isUpdateArticle ? 'Update Article' : 'Add Article'),

        // Upload-Image button UI
        //--2/4-------------------------------
        actions: [
          IconButton(
            key: const Key('uploadImageButton'),
            icon: const Icon(Icons.image),
            onPressed: isUploading ? null : uploadImageAndInsertMarkdown,
          ),
        ],
        //---------------------------------
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _form,
            child: Column(
              children: [
                TextFormField(
                  controller: titleCtr,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: aboutTitleCtr,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a description' : null,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Raw-Markdown feld für den Artikelinhalt
                      //--3/4--------------------------------
                      TextFormField(
                        key: const Key('markdownTextField'),
                        controller: articleCtr,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'Markdown Editor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      //----------------------------------
                      const SizedBox(height: 12),
                      const Text(
                        "Preview:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      // Live Markdown Vorschau
                      //--4/4-------------------------------------
                      // Anzeige-Widget (MarkdownBody), das den Inhalt aus dem Textfeld articleCtr live umwandelt und rendert.
                      // Änderungen am Textfeld werden über den ValueListenableBuilder automatisch erkannt und die Vorschau wird direkt aktualisiert.
                      // Zusätzlich werden Bilder korrekt gerendert, mit Fallback-Anzeige bei Ladefehlern.
                      Expanded(
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable:
                              articleCtr, // Lauscht auf Änderungen im Markdown-Eingabefeld
                          builder: (context, value, _) {
                            return SingleChildScrollView(
                              // Ermöglicht Scrollen, falls Vorschau länger ist

                              child: MarkdownBody(
                                data: value.text, // Markdown live rendering
                                imageBuilder: (uri, title, alt) {
                                  return Image.network(
                                    uri.toString(), // Zeigt eingebettete Bilder aus dem Markdown an
                                    fit: BoxFit.contain,
                                    height: 200,
                                    errorBuilder: (ctx, error, stack) => const Text(
                                        "[Image failed to load]"), // Fehlermeldung, falls Bild nicht geladen werden kann
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      //---------------------------------------
                    ],
                  ),
                ),
                if (isUploading) const CircularProgressIndicator(),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: AppColors.primaryColor,
                    child: Text(widget.isUpdateArticle ? 'Update' : 'Publish'),
                    onPressed: submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
