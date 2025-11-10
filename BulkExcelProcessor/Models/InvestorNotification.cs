using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BulkExcelProcessor.Models;

public class InvestorNotification
{
    [Key]
    public Guid ID { get; set; }
    [ForeignKey("Batch")]
    public Guid BatchId { get; set; }
    public int ChunkNumber { get; set; }
    public string? LoanNumber { get; set; }
    public string? LetterId { get; set; }
    public string? OldInvNum { get; set; }
    public string? NewInvNum { get; set; }
    public DateTime CreatedDate { get; set; }
}
