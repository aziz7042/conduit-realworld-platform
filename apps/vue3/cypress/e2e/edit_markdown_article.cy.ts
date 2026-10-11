// End-to-End Test: Artikelbearbeitung mit Live Markdown-Vorschau & Bild-Upload
//
// Idee & Ablauf:
// - Login als Testnutzer mit gültigen Zugangsdaten
// - Vorhandenen Artikel im Editor öffnen
// - Markdown-Inhalt eingeben und prüfen, ob die Live-Vorschau korrekt gerendert wird
// - Bild-Upload simulieren, API-Abfrage abfangen und erfolgreichen Upload sicherstellen
// - Prüfen, ob das Bild automatisch im Markdown-Text eingebunden wird
// - Kontrollieren, ob das hochgeladene Bild in der Live-Vorschau angezeigt wird


describe('Edit Markdown Article - Live Preview & Image Upload', () => {

  // Testdaten für Login und bestehenden Artikel
  const testEmail = Cypress.config('env').TEST_EMAIL || 'testuser@example.com';
  const testPassword = Cypress.config('env').TEST_PASSWORD || 'ExampleOnly123!';
  const articleSlug = Cypress.config('env').TEST_ARTICLE_SLUG || 'example-article';
  const testImagePath = 'cypress/test_assets/sample.jpg'; // Testbild im Projektverzeichnis

  it('renders live preview and uploads image during article edit', () => {

    // ---------- LOGIN ----------
    cy.visit('/login', { 
      // Umgehen von möglichen Caching-Effekten beim fetch
      onBeforeLoad(win) { (win as any).fetch = undefined; } 
    });
    
    // Login mit gültigen Testdaten
    cy.get('input[placeholder="Email"]').type(testEmail);
    cy.get('input[placeholder="Password"]').type(testPassword);
    cy.get('button[type="submit"]').click();
    
    // Sicherstellen, dass wir eingeloggt sind
    cy.url().should('not.include', '/login');

    // ---------- ARTIKEL BEARBEITEN ----------
    cy.visit(`/article/editor/${articleSlug}`);

    // Beispiel-Markdown in das Textfeld schreiben
    const markdownText = '# Test Title\n**bold text**\n- item1\n- item2';
    cy.get('textarea[name="body"]').clear().type(markdownText);

    // Vorschau prüfen: Überschrift, Fettdruck, Liste
    cy.contains('Live Preview').parent().within(() => {
      cy.contains('Test Title');
      cy.contains('bold text');
      cy.get('li').should('have.length', 2); // Zwei Listenelemente
    });

    // ---------- BILD-UPLOAD SIMULIEREN ----------

    // API-Abfrage zum Bild-Upload abfangen
    cy.intercept('POST', `/api/articles/${articleSlug}/images`).as('uploadImage');

    // Testbild auswählen und Upload triggern
    cy.get('input[type="file"]').selectFile(testImagePath, { force: true });

    // Sicherstellen, dass der Upload erfolgreich war
    cy.wait('@uploadImage').its('response.statusCode').should('eq', 200);

    // Prüfen, ob der Markdown-Text automatisch das Bild enthält
    cy.get('textarea[name="body"]')
      .invoke('val')
      .should('contain', '![alt text](')
      .and('contain', '/uploads/');

    // Vorschau prüfen: Das hochgeladene Bild wird angezeigt
    cy.contains('Live Preview').parent().within(() => {
      cy.get('img')
        .should('have.attr', 'src')
        .and('include', '/uploads/');
    });
  });
});
