using BulkExcelProcessor.Data;
using BulkExcelProcessor.Models;
using BulkExcelProcessor.Repositories;
using ClosedXML.Excel;
using Hangfire;
using Microsoft.Extensions.Logging;

namespace BulkExcelProcessor.Services;

public class ProcessingService : IProcessingService
{
    private readonly IDataRepository _repo;
    private readonly ILogger<ProcessingService> _logger;
    private readonly AppDbContext _db;
    private readonly string _storageRoot;

    public ProcessingService(IDataRepository repo, ILogger<ProcessingService> logger, IConfiguration configuration, AppDbContext db)
    {
        _repo = repo;
        _logger = logger;
        this._db = db;
        _storageRoot = configuration.GetValue<string>("StorageRoot") ?? Path.Combine(Directory.GetCurrentDirectory(), "Storage");
    }

    // This method will be executed by Hangfire
    public async Task ProcessBatchAsync(Guid batchId)
    {
        _logger.LogInformation("Start processing batch {BatchId}", batchId);

        var pendingChunks =  _repo.GetPendingChunksAsync(batchId);

        if (pendingChunks == null || !pendingChunks.Any())
        {
            _logger.LogWarning("No chunks found for batch {BatchId}", batchId);
            return;
        }

        try
        {
            // Combine chunks into one file
            var combinedFilePath = await CombineChunksAsync(pendingChunks, batchId);

            _logger.LogInformation("Combined {Count} chunks into {FilePath}", pendingChunks.Count, combinedFilePath);

            // Enqueue Hangfire background job to process the Excel file
            BackgroundJob.Enqueue<IProcessingService>(s => s.ProcessCombinedExcelAsync(batchId, combinedFilePath));

            _logger.LogInformation("Enqueued Hangfire job to process combined Excel for batch {BatchId}", batchId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error combining chunks for batch {BatchId}", batchId);
            throw;
        }
    }
    public async Task<string> CombineChunksAsync(IEnumerable<BatchChunk> chunks, Guid batchId)
    {
        // Sort chunks by ChunkNumber to maintain correct order
        var orderedChunks = chunks.OrderBy(c => c.ChunkNumber).ToList();

        var combinedFilePath = Path.Combine(Path.GetTempPath(), $"{batchId}_combined.xlsx");

        await using (var destinationStream = File.Create(combinedFilePath))
        {
            foreach (var chunk in orderedChunks)
            {
                await using var sourceStream = File.OpenRead(chunk.FilePath);
                await sourceStream.CopyToAsync(destinationStream);
            }
        }

        return combinedFilePath;
    }
    public async Task<string> ProcessCombinedExcelAsync(Guid batchId, string filePath)
    {
        _logger.LogInformation("Started background job to process Excel for batch {BatchId}", batchId);

        using var workbook = new ClosedXML.Excel.XLWorkbook(filePath);
        var worksheet = workbook.Worksheets.First();

        var rows = worksheet.RangeUsed().RowsUsed().Skip(1); // assuming first row is header
        var notifications = new List<InvestorNotification>();

        foreach (var row in rows)
        {
            notifications.Add(new InvestorNotification
            {
                ID = Guid.NewGuid(),
                BatchId = batchId,
                ChunkNumber = 0, // Not needed now, but can map later if necessary
                LoanNumber = row.Cell(1).GetString(),
                LetterId = row.Cell(2).GetString(),
                OldInvNum = row.Cell(3).GetString(),
                NewInvNum = row.Cell(4).GetString(),
                CreatedDate = DateTime.UtcNow
            });
        }

        await _repo.BulkInsertInvestorNotificationsAsync(notifications);

        _logger.LogInformation("Inserted {Count} notifications for batch {BatchId}", notifications.Count, batchId);

        await _repo.MarkBatchCompletedAsync(batchId);
        _logger.LogInformation("Batch {BatchId} marked as completed", batchId);

        // Optionally enqueue report generation
       var jobId =  BackgroundJob.Enqueue<IProcessingService>(s => s.GenerateReportAsync(batchId));
        //retrun jobId;     
        return jobId;

    }

    public async Task<int> ProcessExcelChunkAsync(string excelFilePath, Guid batchId, int chunkNumber)
    {
        if (!File.Exists(excelFilePath))
            throw new FileNotFoundException($"Excel file not found: {excelFilePath}");

        var investorRecords = new List<InvestorNotification>();

        try
        {
            using var workbook = new XLWorkbook(excelFilePath);
            var worksheet = workbook.Worksheet(1); // First worksheet
            var rows = worksheet.RangeUsed().RowsUsed().Skip(1); // Skip header

            foreach (var row in rows)
            {
                var record = new InvestorNotification
                {
                    ID = Guid.NewGuid(),
                    BatchId = batchId,
                    ChunkNumber = chunkNumber,
                    LoanNumber = row.Cell(4).GetString(),
                    LetterId = row.Cell(5).GetString(),
                    OldInvNum = row.Cell(6).GetString(),
                    NewInvNum = row.Cell(7).GetString(),
                    CreatedDate = DateTime.UtcNow
                };
                investorRecords.Add(record);
            }

            await _db.InvestorNotification.AddRangeAsync(investorRecords);
            await _db.SaveChangesAsync();

            _logger.LogInformation($"✅ Processed {investorRecords.Count} records for BatchId={batchId}, Chunk={chunkNumber}");
            return investorRecords.Count;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"❌ Error processing Excel chunk for BatchId={batchId}, Chunk={chunkNumber}");
            throw;
        }
    }
    public async Task GenerateReportAsync(Guid batchId)
    {
        _logger.LogInformation("Generating report for batch {BatchId}", batchId);
        // Build an Excel or CSV report based on processed data; here we simulate creating a file.
        var dir = Path.Combine(_storageRoot, batchId.ToString());
        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        var reportPath = Path.Combine(dir, "report.csv");
        await File.WriteAllTextAsync(reportPath, "LoanNumber,OldInv,NewInv\nSIMULATED,OLD123,NEW123");
        _logger.LogInformation("Report created at {ReportPath}", reportPath);
    }

   
}
