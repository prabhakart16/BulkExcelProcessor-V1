namespace BulkExcelProcessor.Services;

public interface IProcessingService
{
    Task ProcessBatchAsync(Guid batchId);
    Task GenerateReportAsync(Guid batchId);
    Task<int> ProcessExcelChunkAsync(string excelFilePath, Guid batchId, int chunkNumber);
}
