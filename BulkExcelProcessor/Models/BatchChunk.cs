using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BulkExcelProcessor.Models;

public class BatchChunk
{
    [Key]
    public Guid ID { get; set; }
    [ForeignKey("Batch")]
    public Guid BatchId { get; set; }
    public int ChunkNumber { get; set; }
    public string Status { get; set; } = "Received";
    public string? FilePath { get; set; }
    public DateTime ReceivedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? CompletedAt { get; set; }

    public Batch? Batch { get; set; }
}
