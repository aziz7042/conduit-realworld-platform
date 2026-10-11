// Dieser Unit-Test überprüft, ob beim Mapping eines Artikels:
// 1. Die Bild-URL korrekt in das Response-DTO übernommen wird
// 2. Der Markdown-Text des Artikels korrekt dargestellt wird
// Der Test simuliert ein hochgeladenes Bild, eine Beispiel-Markdown-Struktur und prüft das Verhalten des Article-Mappers.

using System.Collections.Generic;
using Xunit;
using FluentAssertions;
using Realworlddotnet.Api.Features.Articles;
using Realworlddotnet.Core.Entities;

namespace Unit.Tests
{
    public class ArticleMapperImageTest
    {
        [Fact(DisplayName = "Assignment 4.1 - Unit Test Simulated Image Upload and Markdown Body"),
         Trait("Number", "4.1")]
        public void MapFromArticleEntity_ShouldReflectSimulatedImageUpload()
        {

            // Simulierte öffentliche URL eines hochgeladenen Bildes
            var uploadedImageUrl = "http://localhost:8081/uploads/fakeUploadedImage.jpg";

            // Bild-Objekt erstellen, wie es nach dem Upload in der Datenbank gespeichert wäre
            var image = new ArticleImage 
            { 
                Url = uploadedImageUrl 
            };

            // Beispiel-Markdown-Text für den Artikel mit Bild-Placeholder
            // Der Text enthält eine Überschrift und einen Bildlink im Markdown-Format
            var markdownBody = @"# Article with Image Placeholder  
Image below:  
![alt text](" + uploadedImageUrl + @" ""Uploaded Image"")";

            // Artikel-Objekt simulieren:
            // - Titel und Beschreibung gesetzt
            // - Markdown-Text enthält das Bild
            // - Author ist ein User-Objekt mit Username, Profilbild und Bio
            // - ImageUrls-Liste enthält das hochgeladene Bild
            var article = new Article("Test Title", "Test Description", markdownBody)
            {
                Author = new User 
                { 
                    Username = "testuser", 
                    Image = "profile.jpg", 
                    Bio = "Test Bio" 
                },
                
                ImageUrls = new List<ArticleImage> { image }
            };


            // Mapper-Funktion aufrufen, die das Article-Entity in ein DTO umwandelt
            var response = ArticlesMapper.MapFromArticleEntity(article);


            // Prüfen, ob die Bild-URLs im DTO vorhanden sind und die simulierte URL enthalten
            response.ImageUrls.Should().NotBeNull();
            response.ImageUrls.Should().Contain(uploadedImageUrl);

            // Prüfen, ob der Body-Text im DTO das Bild korrekt im Markdown enthält
            response.Body.Should().Contain("![alt text](" + uploadedImageUrl);
            response.Body.Should().Contain("# Article with Image Placeholder");
        }
    }
}
