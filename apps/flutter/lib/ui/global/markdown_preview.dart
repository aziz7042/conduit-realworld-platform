// Die Datei markdown_preview.dart enthält ein wiederverwendbares Widget, das einen Markdown-Editor mit Live-Vorschau kombiniert.
// Während der Benutzer Markdown-Syntax eingibt, wird der formatierte Text darunter direkt gerendert angezeigt.
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Markdown-Vorschau-Komponente
//---------------------------------------
// Dieses Widget kombiniert ein Markdown-Eingabefeld mit einer Live-Vorschau.
// Sobald der Benutzer Text mit Markdown-Syntax eingibt, wird darunter die
// formatierte Vorschau direkt aktualisiert angezeigt.
class MarkdownPreview extends StatefulWidget {
  final TextEditingController
      controller; // Der Controller verwaltet den eingegebenen Text

  const MarkdownPreview({Key? key, required this.controller}) : super(key: key);

  @override
  State<MarkdownPreview> createState() => _MarkdownPreviewState();
}
//---------------------------------------

class _MarkdownPreviewState extends State<MarkdownPreview> {
  late String
      currentMarkdown; // Speichert den aktuellen Markdown-Text zur Vorschau

  @override
  void initState() {
    super.initState();
    currentMarkdown = widget.controller.text; // Initialer Text wird übernommen
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          currentMarkdown = widget
              .controller.text; // Aktualisiert die Vorschau bei Änderungen
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //--------------------------------------------------
        // Markdown Editor-Eingabefeld
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: widget
                  .controller, // Verknüpft das Eingabefeld mit dem Controller
              maxLines: null, // Keine feste Zeilenbegrenzung
              expands: true, // Das Eingabefeld füllt den verfügbaren Platz aus
              decoration: const InputDecoration(
                border: OutlineInputBorder(), // Rahmen um das Textfeld
                labelText: 'Markdown Editor', // Beschriftung des Eingabefelds
                hintText:
                    'Write your article in Markdown...', // Platzhaltertext als Hinweis
              ),
            ),
          ),
        ),
        //----------------------------------------------------

        const Divider(), // Optische Trennung zwischen Editor und Vorschau
        const Text(
          'Preview:', // Überschrift für die Vorschau
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8), // Kleiner Abstand vor der Vorschau

        //--------------------------------------------------
        // Live gerenderte Markdown-Vorschau
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MarkdownBody(
              data:
                  currentMarkdown, // Der aktuelle Markdown-Text wird gerendert
              selectable:
                  true, // Benutzer kann den gerenderten Text markieren/kopieren
              onTapLink: (text, href, title) {
                if (href != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped on link: $href')),
                  ); // Zeigt eine Snackbar an, wenn auf einen Link geklickt wird
                }
              },
            ),
          ),
        ),
        //----------------------------------------------------
      ],
    );
  }
}
