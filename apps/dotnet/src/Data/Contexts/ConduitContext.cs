using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Realworlddotnet.Core.Entities;

namespace Realworlddotnet.Data.Contexts;

public class ConduitContext : DbContext
{
    public ConduitContext(DbContextOptions<ConduitContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; } = null!;
    public DbSet<Article> Articles { get; set; } = null!;
    public DbSet<Comment> Comments { get; set; } = null!;
    public DbSet<Tag> Tags { get; set; } = null!;

    public DbSet<UserLink> FollowedUsers { get; set; } = null!;

    public DbSet<ArticleFavorite> ArticleFavorites { get; set; } = null!;

    public DbSet<SearchCount> SearchCount { get; set; } = null!;
    //--------------------------------------------------------------------------------------------
    // NEU: Tabelle für die hochgeladenen Bilder pro Artikel
    public DbSet<ArticleImage> ArticleImages { get; set; } = null!;
    //--------------------------------------------------------------------------------------------

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Username);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasMany(x => x.ArticleComments)
                .WithOne(x => x.Author);
        });

        modelBuilder.Entity<Article>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Slug).IsUnique();
            entity.Ignore(e => e.Favorited);
            entity.Ignore(e => e.FavoritesCount);
        });

        modelBuilder.Entity<ArticleFavorite>(entity =>
        {
            entity.HasKey(e => new { e.ArticleId, UserId = e.Username });
            entity.HasOne(x => x.Article).WithMany(x => x.ArticleFavorites)
                .HasForeignKey(x => x.ArticleId);
            entity.HasOne(x => x.User).WithMany(x => x.ArticleFavorites);
        });

        modelBuilder.Entity<Comment>(entity =>
        {
            entity.HasOne(x => x.Article)
                .WithMany(x => x.Comments)
                .HasForeignKey(x => x.ArticleId);
            entity.HasOne(x => x.Author)
                .WithMany(x => x.ArticleComments)
                .HasForeignKey(x => x.Username);
        });

        modelBuilder.Entity<UserLink>(entity =>
        {
            entity.HasKey(x => new { x.Username, x.FollowerUsername });
            entity.HasOne(x => x.User)
                .WithMany(x => x.Followers)
                .HasForeignKey(x => x.Username);

            entity.HasOne(x => x.FollowerUser)
                .WithMany(x => x.FollowedUsers)
                .HasForeignKey(x => x.FollowerUsername);
        });

        modelBuilder.Entity<SearchCount>(entity =>
        {
            entity.HasKey(x => x.KeywordId);
        });
        //--------------------------------------------------------------------------------------------
        //  Konfiguration der Tabelle für die Bilder
        modelBuilder.Entity<ArticleImage>(entity =>
        {
            entity.HasKey(x => x.Id); // Primärschlüssel für Bild
            entity.Property(x => x.Url).IsRequired(); // Die Bild-URL muss vorhanden sein
            entity.HasOne(x => x.Article)
                .WithMany(x => x.ImageUrls) // Die Navigationseigenschaft im Artikel heißt "ImageUrls"
                .HasForeignKey(x => x.ArticleId); // Fremdschlüssel zur Verknüpfung mit Artikel
        });
        
    }
}
