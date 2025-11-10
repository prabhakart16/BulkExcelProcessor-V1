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
        var pending = await _repo.GetPendingChunksAsync(batchId);
        foreach (var chunk in pending)
        {
            try
            {
                // Simulate processing:
                _logger.LogInformation("Processing chunk {ChunkNumber}", chunk.ChunkNumber);
                // Here you would load the file chunk.FilePath and parse Excel rows, insert into InvestorNotification etc.

                ProcessExcelChunkAsync(chunk.FilePath!, batchId, chunk.ChunkNumber).Wait();
                //await Task.Delay(500); // simulate I/O/CPU work

                // Mark chunk processed
                await _repo.MarkChunkProcessedAsync(chunk.ID);
                await _repo.IncrementProcessedChunksAsync(batchId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing chunk {ChunkId}", chunk.ID);
            }
        }

        // After processing all chunks, mark batch completed and enqueue report generation
        await _repo.MarkBatchCompletedAsync(batchId);
        BackgroundJob.Enqueue<IProcessingService>(s => s.GenerateReportAsync(batchId));
        _logger.LogInformation("Enqueued report generation for batch {BatchId}", batchId);
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
