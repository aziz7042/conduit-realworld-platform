using Realworlddotnet.Core.Dto;
using Realworlddotnet.Core.Repositories;

namespace Realworlddotnet.Api.Features.Search;

public class SearchHandler : ISearchHandler
{
    private readonly IConduitRepository _repository;

    public SearchHandler(IConduitRepository repository)
    {
        _repository = repository;
    }

    public async Task<(ArticlesResponseDto, IEnumerable<SearchCount>)> GetArticlesAsync(
        SearchQuery query,
        CancellationToken cancellationToken)
    {
        var searchResult = await _repository.GetArticlesAsync(query, cancellationToken);
        string[] keywords = query.query?.Split(' ', StringSplitOptions.RemoveEmptyEntries) ?? [];
        var counts = await _repository.UpsertKeywordCountsAsync(keywords, cancellationToken);

        await _repository.SaveChangesAsync(cancellationToken);

        return (searchResult, counts);
    }
}
