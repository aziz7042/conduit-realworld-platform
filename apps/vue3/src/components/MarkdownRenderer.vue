/**
 * Komponente zum Rendern von Markdown-Text mit Erweiterungen
 * 
 * Idee & Ablauf:
 * - Nimmt über das Prop 'source' den reinen Markdown-Text entgegen
 * - Initialisiert Markdown-It mit Plugins für:
 *   - Abkürzungen, Fußnoten, Anker-Links, ToDo-Listen, Inhaltsverzeichnis
 *   - Hoch-/Tiefstellung & Syntax-Highlighting von Code
 * - Wandelt den Markdown-Text in HTML um (v-html Ausgabe, bewusst verwendet)
 * - Ermöglicht Vorschau von formatiertem Text, Listen, Tabellen, Code-Blöcken etc.
 */


<template>
  <!-- Gerendertes HTML wird hier eingefügt (Achtung: v-html ist "unsicher", aber gewollt für Markdown) -->
  <div v-html="renderedMarkdown" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import MarkdownIt from 'markdown-it'

//  Erweiterungen für MarkdownIt hinzufügen (erlauben spezielle Features)
import MarkdownItAbbr from 'markdown-it-abbr'            // Abkürzungen
import MarkdownItAnchor from 'markdown-it-anchor'        // Anker-Links für Überschriften
import MarkdownItFootnote from 'markdown-it-footnote'    // Fußnoten
import MarkdownItHighlightjs from 'markdown-it-highlightjs' // Syntax-Highlighting für Code
import MarkdownItSub from 'markdown-it-sub'              // Tiefgestellte Zeichen (z. B. H₂O)
import MarkdownItSup from 'markdown-it-sup'              // Hochgestellte Zeichen (z. B. x²)
import MarkdownItTasklists from 'markdown-it-task-lists' // ToDo-Listen im Markdown
import MarkdownItTOC from 'markdown-it-toc-done-right'   // Inhaltsverzeichnis automatisch generieren

// Prop 'source' enthält den Markdown-Text, den die Komponente rendert
const props = defineProps<{ source: string }>()

// Initialisierung des Markdown-It-Parsers mit Plugins
const md = new MarkdownIt()
  .use(MarkdownItAbbr)
  .use(MarkdownItAnchor)
  .use(MarkdownItFootnote)
  .use(MarkdownItHighlightjs)
  .use(MarkdownItSub)
  .use(MarkdownItSup)
  .use(MarkdownItTasklists)
  .use(MarkdownItTOC)

//  Berechnetes Property für das fertige HTML aus dem Markdown-Text
const renderedMarkdown = computed(() => {
  return md.render(props.source)
})
</script>
