using Realworlddotnet.Core.Dto;

namespace Realworlddotnet.Api.Features.Articles;

public static class ArticlesMapper
{
    public static ArticleResponse MapFromArticleEntity(Article article)
    {
        var tags = article.Tags.Select(tag => tag.Id);
        var author = article.Author;
        //  Collect image URLs from associated ArticleImage entities
        var imageUrls = article.ImageUrls.Select(img => img.Url).ToList();

        var result = new ArticleResponse(
            article.Slug,
            article.Title,
            article.Description,
            article.Body,
            article.CreatedAt,
            article.UpdatedAt,
            tags,
            new Author(
                author.Username,
                author.Image,
                author.Bio,
                author.Followers.Any()),
            article.Favorited,
            article.FavoritesCount,
            article.ReadCount,
            
            imageUrls //  Add image URLs here
        );
        return result;
    }

    public static ArticlesResponse MapFromArticles(ArticlesResponseDto articlesResponseDto)
    {
        var articles = articlesResponseDto.Articles
            .Select(articleEntity => MapFromArticleEntity(articleEntity))
            .ToList();
        return new ArticlesResponse(articles, articlesResponseDto.ArticlesCount);
    }
}
