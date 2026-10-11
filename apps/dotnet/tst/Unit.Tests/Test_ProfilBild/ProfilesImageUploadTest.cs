using System.Threading;
using System.Threading.Tasks;

namespace Unit.Tests.Assignment_4_Test_Cases;

using FluentAssertions;
using Hellang.Middleware.ProblemDetails;
using Moq;
using Realworlddotnet.Api.Features.Profiles;
using Realworlddotnet.Core.Entities;
using Realworlddotnet.Core.Repositories;
using Xunit;

public class ProfilesHandlerImageTest
{
    [Fact(DisplayName = "Assignment 4 - Unit Test Image URL Update"),
     Trait("Number", "4.1")]

    // In diesem Test wird geprüft, ob das Profilbild eines existierenden Benutzers korrekt aktualisiert wird
    public async Task CheckProfileImageUrlUpdate()
    {
        string username = "testuser"; // Es wird ein Beispielbenutzername festgelegt
        string newImageUrl = "http://localhost:8081/uploads/testuser.jpg"; // Die neue Bild-URL wird definiert
        var cancellationToken = CancellationToken.None; // Ein Abbruch-Token wird vorbereitet

        var mockRepository = new Mock<IConduitRepository>(); // Das Repository wird gemockt
        var user = new User { Username = username, Image = "oldImage.jpg" }; // Ein Benutzer mit altem Profilbild wird erstellt

        // Das Repository wird so vorbereitet, dass es den Benutzer korrekt zurückgibt
        mockRepository.Setup(r => r.GetUserByUsernameAsync(username, cancellationToken))
                      .ReturnsAsync(user);

        var handler = new ProfilesHandler(mockRepository.Object); // Der Profile-Handler wird mit dem Mock-Repository erstellt

        await handler.UpdateUserImageAsync(username, newImageUrl, cancellationToken); // Die Bild-URL wird aktualisiert

        user.Image.Should().Be(newImageUrl); // Es wird geprüft, ob das neue Bild korrekt im Benutzerobjekt gespeichert wurde

        mockRepository.Verify(r => r.SaveChangesAsync(cancellationToken), Times.Once); // und, ob SaveChangesAsync genau einmal aufgerufen wurde
    }

    [Fact(DisplayName = "Assignment 4 - Unit Test User Not Found Exception"),
     Trait("Number", "4.2")]

    // In diesem Test wird geprüft, ob eine korrekte Exception geworfen wird, wenn der Benutzer nicht existiert
    public async Task CheckUserNotFoundException()
    {
        string username = "nonexistentuser"; // Es wird ein Benutzername definiert, der nicht existiert
        string newImageUrl = "http://localhost:8081/uploads/nonexistentuser.jpg"; // Eine Bild-URL wird definiert
        var cancellationToken = CancellationToken.None; // Ein Abbruch-Token wird vorbereitet

        var mockRepository = new Mock<IConduitRepository>(); // Das Repository wird gemockt
        mockRepository.Setup(r => r.GetUserByUsernameAsync(username, cancellationToken))
                      .ReturnsAsync((User)null!); // und wird so vorbereitet, dass kein Benutzer gefunden wird

        var handler = new ProfilesHandler(mockRepository.Object); // Der Profile-Handler wird mit dem Mock-Repository erstellt

        var act = async () => await handler.UpdateUserImageAsync(username, newImageUrl, cancellationToken); // Die Methode wird vorbereitet, um die Exception zu prüfen

        var exception = await Assert.ThrowsAsync<ProblemDetailsException>(act); // Hier wird geprüft, ob die Methode die erwartete Exception wirft
        exception.Details.Status.Should().Be(404); // ob der Statuscode der Exception korrekt ist
        exception.Details.Title.Should().Be("User not found"); // und, ob die Fehlermeldung korrekt ist

        mockRepository.Verify(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never); // Am Ende wird es auch geprüft, dass SaveChangesAsync nicht aufgerufen wurde
    }
}
