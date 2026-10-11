// Dieser Test prüft, ob ein Benutzer ein Profilbild auswählen, lokal anzeigen und anschließend erfolgreich hochladen kann

describe('E2E Tests: Profilbild hochladen', () => {

  // Hier werden die Testdaten für E-Mail, Passwort und das Testbild definiert
  const testEmail = Cypress.config('env').TEST_EMAIL || 'testuser@example.com';
  const testPassword = Cypress.config('env').TEST_PASSWORD || 'ExampleOnly123!';
  const testImagePath = 'testImages/testbild.jpg'; // Ein Dummy-Testbild im cypress/fixtures Verzeichnis

  // Dieser Test prüft die vollständige Bild-Upload-Funktion inklusive Vorschau und Server-Upload
  it('zeigt die lokale Vorschau des Profilbildes und lädt das Bild erst bei Klick hoch', () => {

    // Zuerst wird die Login-Seite geöffnet
    cy.visit('/login');

    // Dann werden die Login-Felder mit der E-Mail und dem Passwort ausgefüllt
    cy.get('input[placeholder="Email"]').type(testEmail);
    cy.get('input[placeholder="Password"]').type(testPassword);

    // Der Login-Button wird geklickt
    cy.get('button[type="submit"]').click();

    // Es wird überprüft, ob die Startseite nach dem Login erfolgreich geladen wurde
    cy.url().should('include', '/');

    // Danach wird die Einstellungsseite aufgerufen
    cy.visit('/settings');

    // Anschließend wird ein Bild im Dateiupload-Feld ausgewählt
    cy.get('input[type="file"]').selectFile(`cypress/fixtures/${testImagePath}`, { force: true });

    // Es wird geprüft, ob der Dateiname des ausgewählten Bildes korrekt angezeigt wird
    cy.contains('testbild.jpg').should('be.visible');

    // Außerdem wird kontrolliert, ob das ausgewählte Bild direkt in der Vorschau sichtbar ist
    cy.get('img.img-preview').should('be.visible');

    // Hier wird der API-Request zum Bild-Upload überwacht
    cy.intercept('POST', 'http://localhost:8081/api/profiles/image').as('uploadRequest');

    // Der Button zum Speichern der Einstellungen wird angeklickt
    cy.get('button').contains('Update Settings').click();

    // Nach dem Speichern wird geprüft, ob das Bild in der Vorschau weiterhin korrekt angezeigt wird
    cy.get('img.img-preview')
      .should('have.attr', 'src')
      .and('include', '/uploads/'); // Die Bildquelle muss aus dem Upload-Verzeichnis stammen

    // Es wird geprüft, ob der Bild-Upload-Request erfolgreich mit Status 200 abgeschlossen wurde
    cy.wait('@uploadRequest').its('response.statusCode').should('eq', 200);

    // Am Ende wird überprüft, ob der Benutzer korrekt auf sein Profil weitergeleitet wurde
    cy.url().should('include', '/profile/');
  });

});
