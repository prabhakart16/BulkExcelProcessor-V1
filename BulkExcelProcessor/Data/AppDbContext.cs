using BulkExcelProcessor.Models;
using Microsoft.EntityFrameworkCore;

namespace BulkExcelProcessor.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Batch> Batches { get; set; } = null!;
    public DbSet<BatchChunk> BatchChunks { get; set; } = null!;
    public DbSet<InvestorNotification> InvestorNotification { get; set; } = null!;
}
