using BulkExcelProcessor.Data;
using BulkExcelProcessor.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace BulkExcelProcessor.Repositories;

public class DataRepository : IDataRepository
{
    private readonly AppDbContext _db;
    private readonly ILogger<DataRepository> _logger;
    private readonly IConfiguration config;

    public DataRepository(AppDbContext db, ILogger<DataRepository> logger,IConfiguration config)
    {
        _db = db;
        _logger = logger;
        this.config = config;
    }

    public async Task<Guid> CreateOrGetBatchAsync(string fileName, int totalChunks)
    {
        // Create new batch
        var batch = new Batch
        {
            BatchId = Guid.NewGuid(),
            FileName = fileName,
            TotalChunks = totalChunks,
            ReceivedChunks = 0,
            ProcessedChunks = 0,
            ReadyForProcess = false,
            Status = "Created",
            CreatedAt = DateTime.UtcNow
        };
        _db.Batches.Add(batch);
        await _db.SaveChangesAsync();
        _logger.LogInformation("Created batch {BatchId}", batch.BatchId);
        return batch.BatchId;
    }

    public async Task SaveChunkAsync(Guid batchId, int chunkNumber, Stream chunkStream, string storageRoot)
    {
        // Ensure batch exists
        var batch = await _db.Batches.FirstOrDefaultAsync(b => b.BatchId == batchId);
        if (batch == null) throw new KeyNotFoundException("Batch not found");

        // Save chunk to disk
        var dir = Path.Combine(storageRoot, batchId.ToString());
        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        var filePath = Path.Combine(dir, $"chunk_{chunkNumber}.bin");
        using (var fs = File.Create(filePath))
        {
            await chunkStream.CopyToAsync(fs);
        }

        var chunk = new BatchChunk
        {
            ID = Guid.NewGuid(),
            BatchId = batchId,
            ChunkNumber = chunkNumber,
            Status = "Received",
            FilePath = filePath,
            ReceivedAt = DateTime.UtcNow,
            IsCompleted = false
        };
        _db.BatchChunks.Add(chunk);

        batch.ReceivedChunks += 1;
        _db.Batches.Update(batch);

        await _db.SaveChangesAsync();
    }

    public async Task MarkBatchReadyAsync(Guid batchId)
    {
        var batch = await _db.Batches.FirstOrDefaultAsync(b => b.BatchId == batchId);
        if (batch == null) throw new KeyNotFoundException("Batch not found");
        batch.ReadyForProcess = true;
        batch.Status = "Ready";
        _db.Batches.Update(batch);
        await _db.SaveChangesAsync();
    }

    public  List<BatchChunk> GetPendingChunksAsync(Guid batchId)
    {
        return  _db.BatchChunks
            .Where(c => c.BatchId == batchId && !c.IsCompleted)
            .OrderBy(c => c.ChunkNumber)
            .ToList();
    }

    public async Task MarkChunkProcessedAsync(Guid chunkId)
    {
        var chunk = await _db.BatchChunks.FirstOrDefaultAsync(c => c.ID == chunkId);
        if (chunk == null) throw new KeyNotFoundException("Chunk not found");
        chunk.Status = "Processed";
        chunk.IsCompleted = true;
        chunk.ProcessedAt = DateTime.UtcNow;
        chunk.CompletedAt = DateTime.UtcNow;
        _db.BatchChunks.Update(chunk);
        await _db.SaveChangesAsync();
    }

    public async Task IncrementProcessedChunksAsync(Guid batchId)
    {
        var batch = await _db.Batches.FirstOrDefaultAsync(b => b.BatchId == batchId);
        if (batch == null) throw new KeyNotFoundException("Batch not found");
        batch.ProcessedChunks += 1;
        if (batch.ProcessedChunks >= batch.TotalChunks)
        {
            batch.Status = "Processed";
            batch.CompletedAt = DateTime.UtcNow;
        }
        _db.Batches.Update(batch);
        await _db.SaveChangesAsync();
    }

    public async Task MarkBatchCompletedAsync(Guid batchId)
    {
        var batch = await _db.Batches.FirstOrDefaultAsync(b => b.BatchId == batchId);
        if (batch == null) throw new KeyNotFoundException("Batch not found");
        batch.Status = "Completed";
        batch.CompletedAt = DateTime.UtcNow;
        _db.Batches.Update(batch);
        await _db.SaveChangesAsync();
    }

    public async Task BulkInsertInvestorNotificationsAsync(IEnumerable<InvestorNotification> notifications)
    {
        var dataTable = new DataTable();
        dataTable.Columns.Add("ID", typeof(Guid));
        dataTable.Columns.Add("BatchId", typeof(Guid));
        dataTable.Columns.Add("ChunkNumber", typeof(int));
        dataTable.Columns.Add("LoanNumber", typeof(string));
        dataTable.Columns.Add("LetterId", typeof(string));
        dataTable.Columns.Add("OldInvNum", typeof(string));
        dataTable.Columns.Add("NewInvNum", typeof(string));
        dataTable.Columns.Add("CreatedDate", typeof(DateTime));

        foreach (var n in notifications)
        {
            dataTable.Rows.Add(
                n.ID,
                n.BatchId,
                n.ChunkNumber,
                n.LoanNumber ?? (object)DBNull.Value,
                n.LetterId ?? (object)DBNull.Value,
                n.OldInvNum ?? (object)DBNull.Value,
                n.NewInvNum ?? (object)DBNull.Value,
                n.CreatedDate
            );
        }

        using var connection = new SqlConnection(config.GetConnectionString("DefaultConnection"));
        await connection.OpenAsync();

        using var bulkCopy = new SqlBulkCopy(connection)
        {
            DestinationTableName = "InvestorNotification",
            BatchSize = 1000, // adjust as needed
            BulkCopyTimeout = 120
        };

        bulkCopy.ColumnMappings.Add("ID", "ID");
        bulkCopy.ColumnMappings.Add("BatchId", "BatchId");
        bulkCopy.ColumnMappings.Add("ChunkNumber", "ChunkNumber");
        bulkCopy.ColumnMappings.Add("LoanNumber", "LoanNumber");
        bulkCopy.ColumnMappings.Add("LetterId", "LetterId");
        bulkCopy.ColumnMappings.Add("OldInvNum", "OldInvNum");
        bulkCopy.ColumnMappings.Add("NewInvNum", "NewInvNum");
        bulkCopy.ColumnMappings.Add("CreatedDate", "CreatedDate");

        await bulkCopy.WriteToServerAsync(dataTable);
    }

}
