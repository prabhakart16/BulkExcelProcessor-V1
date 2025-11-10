using System.Runtime.CompilerServices;

namespace BulkExcelProcessor.Services;

public interface IProcessingService
{
    Task ProcessBatchAsync(Guid batchId);
    Task GenerateReportAsync(Guid batchId);
    Task<int> ProcessExcelChunkAsync(string excelFilePath, Guid batchId, int chunkNumber);
    Task<string> ProcessCombinedExcelAsync(Guid batchId, string combinedFilePath);
}
