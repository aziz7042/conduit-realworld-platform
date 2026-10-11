[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/fwdwNvFC)
# Meilenstein 4

Nachdem Sie erfolgreich die Fehler und Probleme im Conduit-System behoben haben, sollen nun neue Features implementiert werden.

## Zusammenfassung

Nachdem die Fehler im Conduit-System erfolgreich behoben und die Lösungen getestet wurden, wünscht ihr Kunde für das Blogsystem noch weitere Features. Dabei sollen Nutzer nicht nur Links zu ihren Profilbildern angeben können, sondern eigene Bilder hochladen können. Als besonderes aber optionales Feature, soll auf eine Kamera zugegriffen und ein Profilbild aufgenommen und zugeschnitten werden können.

Des Weiteren werden die Blogartikel in den Frontends aktuell noch ohne eine Formatierung der Markdown-Syntax angezeigt. Dies soll im Folgenden Meilenstein für beide Frontends ergänzt werden. Zudem sollen auch Bilder für Blogbeiträge hochgeladen und in einem Artikel eingebunden werden. Beim Editieren von Artikeln soll es zudem eine Vorschau geben.

Die Aufgaben sind zu erledigen und im Repository hochzuladen. Dies erfolgt durch Commits **und** Push via Git an das jeweilige Projekt-Repository. Die Abgabefrist ist der *04.07.2025 23:59 Uhr (MESZ).*

Hinweis: Die Aufgaben, die als Optional gekennzeichnet sind, können als zusätzliche Leistung, die zur Verbesserung der Gesamtnote dienen, genutzt werden. Es besteht keine Pflicht diese Aufgaben zu erledigen. Um als solche Verbesserung angerechnet werden zu können, müssen *alle* optionalen Aufgaben gelöst werden und Fragen dazu im Meilensteingespräch beantwortet werden.  

## Meilensteinaufgaben

1. Entwicklungsprozess
	* Für alle Aufgaben in diesem Meilenstein soll der folgende Entwicklungsprozess gelten:
		* [ ] Teilen Sie die Aufgaben in einzelne Teilaufgaben auf und erstellen Sie für jede Teilaufgabe zugehörige Sub-Issues. Eine Variante wie dies in GitHub gemacht werden kann ist in [diesem Blogbeitrag](https://dev.to/keracudmore/create-sub-issues-in-github-issues-409m) beschrieben.
		* [ ] Erstellen Sie für jede (Teil-)Aufgabe einen eigenen Branch, der die Issue-ID enthält
		* [ ] Ein Mergen einer fertiggestellten Lösung in den Main-Branch erfolgt erst wenn
			+	diese durch die selbst erstellten automatisierten Tests erfolgreich getestet wurde und
			+	diese durch ein Code-Review via eines Pull-Requests in GitHub durch ein *anderes* Teammitglied akzeptiert wurde. Hierbei soll die Kommentarfunktion aktiv genutzt werden und Anmerkungen zum Code eingepflegt werden. Wir erwarten mindestens einen Review-Kommentar für jede größere Änderung in dem Pull-Request.
2. Profilbilder
	* Vue-Frontend
		* [ ] Es soll für authentifizierte Nutzer unter Settings möglich sein, beim Feld für das Profilbild über einen File-Dialog ein Bild auszuwählen.
		* [ ] Nach der Auswahl eines Bildes soll der lokale Dateipfad des Bildes im vue-Frontend angezeigt werden.
		* [ ] Erst mit Klick auf "Update Settings" soll das Bild über einen eigenständigen dedizierten Endpunkt für Bilder hochgeladen werden.
		* [ ] Zum Anzeigen des Bildes kann vereinfacht eine URL seitens des Backends zum Bild verwendet werden (bspw. `localhost:8081/api/images/123877631.jpg`).
	* Flutter-Frontend
		* [ ] Es soll für authentifizierte Nutzer unter Profile möglich sein, beim Feld für das Profilbild über einen File-Dialog ein Bild auszuwählen.
		* [ ] Nach der Auswahl eines Bildes soll der lokale Dateipfad des Bildes im flutter-Frontend angezeigt werden.
		* [ ] Erst mit Klick auf "Save" soll das Bild über einen eigenständigen dedizierten Endpunkt für Bilder hochgeladen werden.
		* [ ] Zum Anzeigen des Bildes kann vereinfacht eine URL seitens des Backends zum Bild verwendet werden (bspw. `localhost:8081/api/images/123877631.jpg`).
	* .Net-Backend
		* [ ] Um das Backend mit einem Endpunkt zum Hochladen von Bildern zu erweitern, lesen Sie sich vorab dazu den [Blogbeitrag von ASP.Net](https://learn.microsoft.com/de-de/aspnet/core/mvc/models/file-uploads?view=aspnetcore-7.0) durch, in dem beschrieben wird, wie Dateien in ASP.Net hochgeladen, gespeichert und abgerufen werden können.
		* [ ] Erstellen Sie einen Endpunkt, der nur für authentifzierte Nutzer verfügbar ist und über den Bilddateien (ausschließlich `*.jpg`/`*.jpeg`/`*.png`) via POST als `multipart/form-data` Encoding hochgeladen werden können .
		* [ ] Speichern Sie die Datei im lokalen File-System des Backends, so dass Dateien eindeutig benannt und gefunden werden können (d.h., eventuelle gleichnamige Dateien überschreiben sich nicht) und das diese über das Backend aufgerufen werden können (bspw. `localhost:8081/api/images/123877631.jpg`).
		* [ ] Beim Hochladen eines neuen Profilbildes eines Nutzers soll sein ursprüngliches Profilbild auf dem Server durch sein neues ersetzt werden, ohne das der Pfad angepasst wird.
		* [ ] Speichern Sie in der Datenbank zu den Nutzern jeweils den Link (bspw. `localhost:8081/api/images/123877631.jpg`) zu der hochgeladenen Bilddatei auf dem Server für die Spalte `Image`.
3. Formatierung von Blogartikeln
	* vue-Frontend
		* [ ] Blogartikel sollen im vue-Frontend als `HTML` gerendert werden. Hierzu muss die Markdown-Syntax in HTML umgewandelt werden. Nutzen Sie hierfür eine vorhandene Bibliothek. Eine mögliche Variante, wie dies in Vue3 umgesetzt werden kann ist [hier](https://dev.to/matijanovosel/rendering-markdown-in-vue-3-3maj) beschrieben.
		* [ ] Beim Editieren soll es möglich sein eine Preview des gerenderten Ergebnisses anzuzeigen. Dabei sollen bei der Preview sowohl der Text des Blogartikels im Markdown als auch das gerenderte Ergebnis angezeigt werden können.
		* [ ] Es soll möglich sein Bilder im Text zu integrieren. Der Einfachheit halber soll es möglich sein, Bilder beim Editieren hochzuladen und artikelbezogen die zugehörigen Links zu allen Bildern auf dem Server (bspw. `localhost:8081/api/images/123877631.jpg`) aufzulisten, damit diese dann mit folgender Markdown-Syntax `![alt text](localhost:8081/api/images/123877631.jpg "Title")` im Artikel integriert werden können. *Hinweis* Die Bilder müssen somit separat hochgeladen werden, ohne dass vorherige Bilder überschrieben werden. [Optional] können Sie noch das Löschen von Bildern implementieren.
	* flutter-Frontend
 		* [ ] Blogartikel sollen im vue-Frontend als `HTML` gerendert werden. Hierzu muss die Markdown-Syntax in HTML umgewandelt werden. Nutzen Sie hierfür eine vorhandene Bibliothek. Eine mögliche Variante, wie dies in flutter umgesetzt werden kann ist [hier](https://pub.dev/packages/flutter_markdown) beschrieben.
		* [ ] Beim Editieren soll es möglich sein, eine Preview des gerenderten Ergebnisses anzuzeigen. Dabei sollen bei der Preview sowohl der Text des Blogartikels im Markdown als auch das gerenderte Ergebnis angezeigt werden können.
		* [ ] Es soll möglich sein Bilder im Text zu integrieren. Der Einfachheit halber soll es möglich sein, Bilder beim Editieren hochzuladen und artikelbezogen die zugehörigen Links zu allen Bildern auf dem Server (bspw. `localhost:8081/api/images/123877631.jpg`) aufzulisten, damit diese dann mit folgender Markdown-Syntax `![alt text](localhost:8081/api/images/123877631.jpg "Title")` im Artikel integriert werden können. *Hinweis* Die Bilder müssen somit separat hochgeladen werden, ohne dass vorherige Bilder überschrieben werden. [Optional] können Sie noch das Löschen von Bildern implementieren.
	* .Net-Backend
		* [ ] Erweitern Sie die Datenbank so, dass zu Artikeln noch eine Menge an Bildern (d.h. Links zu Bildern bspw. `localhost:8081/api/images/123877631.jpg`) gespeichert werden, die im Artikel verwendet werden.
		* [ ] Der Endpunkt zur GET-Operation `articles` soll zusätzlich noch eine Liste an Bildern zurückgeben.
		* [ ] Das Backend soll Bilder, die in Blogartikeln anzeigt werden, über einen Endpunkt annehmen. Verwenden Sie hierzu den Endpunkt und die Funktionalität zum Verwalten von Bildern aus der Aufgabe 'Profilbilder'. Beachten Sie, dass für Artikel mehrere Bilder zulässig sind, während bei Profilbildern nur ein Bild zulässig ist und dieses bei Neu-Upload überschrieben werden soll. Bilden Sie dies im Endpunkt entsprechend ab.
4. [Optional] Aufnehmen von Profilbildern durch Kamera
	* vue-Frontend und/oder flutter-Frontend
		* [ ] Als ein optionales Feature sollen Profilbilder in den Frontends mittels einer Webcam aufgenommen werden können. Dazu soll im Menü Settings ein Button existieren, mit dem ein Menü zum Aufnehmen eines Bildes geöffnet werden soll. 
		* [ ] Innerhalb dieses Menüs soll 
			+ eine Kamera ausgewählt werden können,
	    + ein Foto mit der ausgewählten Kamera gemacht werden können (dies soll wiederholbar sein),
	    + das aufgenommene Bild zugeschnitten werden können,
	    + das aufgenommene und zugeschnittene Bild als temporäre lokale Datei gespeichert und über den vorhandenen Upload-Mechanismus aus Aufgabe "Profilbilder" hochgeladen werden können.
	   * *Hinweis* Möglichkeiten, um auf eine Kamera bzw. externe Devices via der Frontend-Appliaktion zuzugreifen finden Sie [hier](https://www.npmjs.com/package/simple-vue-camera) oder [hier für vue3](https://www.npmjs.com/package/vue-web-cam) bzw. [hier für flutter](https://docs.flutter.dev/cookbook/plugins/picture-using-camera).


Weitere Lesehinweise:
 
 - [Reading JSON and binary data from multipart/form-data sections in ASP.NET Core](https://andrewlock.net/reading-json-and-binary-data-from-multipart-form-data-sections-in-aspnetcore/)
 - [Markdown Basic Syntax](https://www.markdownguide.org/basic-syntax/)
 - [Vue 3 basics — Camera and screenshot component](https://dagomez.medium.com/vue-3-basics-camera-and-screenshot-component-ac9af7d902f2)
 - [Building a Camera App with Flutter and the Camera Package](https://dev.to/bishopeze/building-a-camera-app-with-flutter-and-the-camera-package-4i15)
