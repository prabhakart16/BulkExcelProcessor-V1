using System.ComponentModel.DataAnnotations;

namespace BulkExcelProcessor.Models;

public class Batch
{
    [Key]
    public Guid BatchId { get; set; }
    public string FileName { get; set; } = null!;
    public int TotalChunks { get; set; }
    public int ReceivedChunks { get; set; }
    public int ProcessedChunks { get; set; }
    public bool ReadyForProcess { get; set; }
    public string Status { get; set; } = "Pending";
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public ICollection<BatchChunk>? Chunks { get; set; }
}
