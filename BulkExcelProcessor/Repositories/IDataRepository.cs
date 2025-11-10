using BulkExcelProcessor.Models;

namespace BulkExcelProcessor.Repositories;

public interface IDataRepository
{
    Task<Guid> CreateOrGetBatchAsync(string fileName, int totalChunks);
    Task SaveChunkAsync(Guid batchId, int chunkNumber, Stream chunkStream, string storageRoot);
    Task MarkBatchReadyAsync(Guid batchId);
    List<BatchChunk> GetPendingChunksAsync(Guid batchId);
    Task MarkChunkProcessedAsync(Guid chunkId);
    Task IncrementProcessedChunksAsync(Guid batchId);
    Task MarkBatchCompletedAsync(Guid batchId);

    Task BulkInsertInvestorNotificationsAsync(IEnumerable<InvestorNotification> notifications);
}
