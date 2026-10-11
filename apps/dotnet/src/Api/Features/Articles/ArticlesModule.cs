using Microsoft.AspNetCore.Mvc;
using Realworlddotnet.Api.Features;
using Realworlddotnet.Core.Dto;
using Realworlddotnet.Core.Entities;
using Realworlddotnet.Data.Contexts;
using System.Security.Claims;
using Microsoft.Data.Sqlite;

namespace Realworlddotnet.Api.Features.Articles;

public class ArticlesModule : ICarterModule
{
    public void AddRoutes(IEndpointRouteBuilder app)
    {
        var unAuthorizedGroup = app.MapGroup("articles")
            .WithTags("Articles")
            .IncludeInOpenApi();

        var authorizedGroup = app.MapGroup("articles")
            .RequireAuthorization()
            .WithTags("Articles")
            .IncludeInOpenApi();

        // -----------------------------Bilder zu einem Blogartikel hochladen----------------------------------
        // Dieser Endpunkt erlaubt es, ein Bild für einen bestimmten Artikel (erkannt über den 'slug') hochzuladen.
        // Die Bilder werden serverseitig gespeichert und die URL wird in der Datenbank mit dem Artikel verknüpft.
        authorizedGroup.MapPost("{slug}/images",
            async Task<IResult> (
                string slug,
                [FromForm] IFormFile file,
                ClaimsPrincipal user,
                ConduitContext db,
                HttpContext context,
                IWebHostEnvironment environment) =>
            {
                // Artikel anhand des Slugs aus der Datenbank laden
                var article = await db.Articles
                    .Include(a => a.Author)
                    .FirstOrDefaultAsync(a => a.Slug == slug, context.RequestAborted);
                if (article == null)
                    return Results.NotFound("Article not found");

                var username = user.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrWhiteSpace(username))
                    return Results.Unauthorized();

                if (!string.Equals(article.Author.Username, username, StringComparison.Ordinal))
                    return Results.Forbid();

                var extension = await ImageUploadValidator.ValidateAndGetExtensionAsync(
                    file,
                    context.RequestAborted);

                // Sicherstellen, dass der Upload-Ordner existiert
                var webRoot = environment.WebRootPath ?? Path.Combine(environment.ContentRootPath, "wwwroot");
                var uploadsPath = Path.Combine(webRoot, "uploads");
                if (!Directory.Exists(uploadsPath))
                    Directory.CreateDirectory(uploadsPath);

                // Eindeutigen Dateinamen für das Bild generieren
                var fileName = $"{Guid.NewGuid():N}{extension}";
                var filePath = Path.Combine(uploadsPath, fileName);

                // Die hochgeladene Datei speichern
                await using var stream = new FileStream(
                    filePath, FileMode.CreateNew, FileAccess.Write, FileShare.None, 81920, useAsync: true);
                await file.CopyToAsync(stream, context.RequestAborted);

                // Öffentliche URL des Bildes generieren
                var imageUrl =
                    $"{context.Request.Scheme}://{context.Request.Host}{context.Request.PathBase}/uploads/{fileName}";

                // Neues Bildobjekt erzeugen und mit dem Artikel verknüpfen
                var articleImage = new ArticleImage
                {
                    Url = imageUrl,
                    ArticleId = article.Id
                };

                // Bild-Objekt zur Datenbank hinzufügen
                db.ArticleImages.Add(articleImage);
                article.ImageUrls.Add(articleImage); // Auch die Navigationseigenschaft des Artikels aktualisieren

                await db.SaveChangesAsync(context.RequestAborted);

                // URL des hochgeladenen Bildes zurückgeben
                return Results.Ok(new { uploaded = imageUrl });
            })
        .Accepts<IFormFile>("multipart/form-data")
        .WithName("UploadArticleImages");
        //-----------------------------------------------------------------------------------------------------------------------

        unAuthorizedGroup.MapGet("/",
            async Task<Ok<ArticlesResponse>> ([AsParameters] ArticlesQuery query, IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                ArticlesResponseDto response;
                while (true)
                {
                    try
                    {
                        response = await articlesHandler.GetArticlesAsync(query, user, false,
                            new CancellationToken());
                        break;
                    }
                    catch (SqliteException)
                    {
                        Thread.Sleep(100);
                    }
                }

                var result = ArticlesMapper.MapFromArticles(response);
                return TypedResults.Ok(result);
            })
        .WithName("GetArticles");

        unAuthorizedGroup.MapGet("/{slug}",
            async Task<Ok<ArticleEnvelope<ArticleResponse>>> (string slug, IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                var article = await articlesHandler.GetArticleBySlugAsync(slug, user, new CancellationToken());
                var result = ArticlesMapper.MapFromArticleEntity(article);
                return TypedResults.Ok(new ArticleEnvelope<ArticleResponse>(result));
            })
        .WithName("GetArticle");

        unAuthorizedGroup.MapGet("/{slug}/comments",
            async Task<Ok<CommentsEnvelope<List<Comment>>>> (string slug, IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                var result = await articlesHandler.GetCommentsAsync(slug, user, new CancellationToken());
                var comments = result.Select(CommentMapper.MapFromCommentEntity);
                return TypedResults.Ok(new CommentsEnvelope<List<Comment>>(comments.ToList()));
            })
        .WithName("GetArticleComments");

        authorizedGroup.MapPost("/",
            async Task<Results<Ok<ArticleEnvelope<ArticleResponse>>, ValidationProblem>> (
                ArticleEnvelope<NewArticleDto> request,
                IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                if (!MiniValidator.TryValidate(request, out var errors))
                    return TypedResults.ValidationProblem(errors);

                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                var article = await articlesHandler.CreateArticleAsync(request.Article, user!, new CancellationToken());
                var result = ArticlesMapper.MapFromArticleEntity(article);
                return TypedResults.Ok(new ArticleEnvelope<ArticleResponse>(result));
            })
        .Produces(StatusCodes.Status401Unauthorized)
        .WithName("CreateArticle");

        authorizedGroup.MapPut("/{slug}",
            async Task<Results<Ok<ArticleEnvelope<ArticleResponse>>, ValidationProblem>> (
                string slug,
                ArticleEnvelope<ArticleUpdateDto> request,
                IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                if (!MiniValidator.TryValidate(request, out var errors))
                    return TypedResults.ValidationProblem(errors);

                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                var article =
                    await articlesHandler.UpdateArticleAsync(request.Article, slug, user!, new CancellationToken());
                var result = ArticlesMapper.MapFromArticleEntity(article);
                return TypedResults.Ok(new ArticleEnvelope<ArticleResponse>(result));
            })
        .Produces(StatusCodes.Status401Unauthorized)
        .WithName("UpdateArticle");

        authorizedGroup.MapDelete("/{slug}",
            async Task<Ok> (string slug, IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                await articlesHandler.DeleteArticleAsync(slug, user!, new CancellationToken());
                return TypedResults.Ok();
            })
        .Produces(StatusCodes.Status401Unauthorized)
        .WithName("DeleteArticle");

        authorizedGroup.MapPost("/{slug}/favorite",
            async Task<Ok<ArticleEnvelope<ArticleResponse>>> (string slug, IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                var article = await articlesHandler.AddFavoriteAsync(slug, user!, new CancellationToken());
                var result = ArticlesMapper.MapFromArticleEntity(article);
                return TypedResults.Ok(new ArticleEnvelope<ArticleResponse>(result));
            })
        .Produces(StatusCodes.Status401Unauthorized)
        .WithName("FavoriteBySlug");

        authorizedGroup.MapDelete("/{slug}/favorite",
            async Task<Ok<ArticleEnvelope<ArticleResponse>>> (string slug, IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                var article = await articlesHandler.DeleteFavorite(slug, user!, new CancellationToken());
                var result = ArticlesMapper.MapFromArticleEntity(article);
                return TypedResults.Ok(new ArticleEnvelope<ArticleResponse>(result));
            })
        .Produces(StatusCodes.Status401Unauthorized)
        .WithName("UnFavoriteBySlug");

        authorizedGroup.MapGet("/feed",
            async Task<Ok<ArticlesResponse>> ([AsParameters] FeedQuery query, IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                var articlesQuery = new ArticlesQuery(null, null, null, query.Limit, query.Offset);
                var response =
                    await articlesHandler.GetArticlesAsync(articlesQuery, user, false, new CancellationToken());
                var result = ArticlesMapper.MapFromArticles(response);
                return TypedResults.Ok(result);
            })
        .Produces(StatusCodes.Status401Unauthorized)
        .WithName("GetFeed");

        authorizedGroup.MapPost("{slug}/comments",
            async Task<Results<Ok<CommentEnvelope<Comment>>, ValidationProblem>> (
                string slug,
                CommentEnvelope<CommentDto> request,
                IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                if (!MiniValidator.TryValidate(request, out var errors))
                    return TypedResults.ValidationProblem(errors);

                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                var result =
                    await articlesHandler.AddCommentAsync(slug, user!, request.comment, new CancellationToken());
                var comment = CommentMapper.MapFromCommentEntity(result);
                return TypedResults.Ok(new CommentEnvelope<Comment>(comment));
            })
        .Produces(StatusCodes.Status401Unauthorized)
        .WithName("CreateComment");

        authorizedGroup.MapDelete("{slug}/comments/{commentId}",
            async Task<Ok> (
                string slug,
                int commentId,
                IArticlesHandler articlesHandler,
                ClaimsPrincipal claimsPrincipal) =>
            {
                var user = claimsPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
                await articlesHandler.RemoveCommentAsync(slug, commentId, user!, new CancellationToken());
                return TypedResults.Ok();
            })
        .Produces(StatusCodes.Status401Unauthorized)
        .WithName("DeleteArticleComment");
    }
}
