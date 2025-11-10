using BulkExcelProcessor.Repositories;
using BulkExcelProcessor.Services;
using Hangfire;
using Microsoft.AspNetCore.Mvc;

namespace BulkExcelProcessor.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UploadController : ControllerBase
{
    private readonly IDataRepository _repo;
    private readonly IConfiguration _config;
    private readonly ILogger<UploadController> _logger;
    private readonly IBackgroundJobClient _backgroundJobs;
    private readonly IProcessingService _service;

    public UploadController(IDataRepository repo, IConfiguration config, ILogger<UploadController> logger, IBackgroundJobClient backgroundJobs, IProcessingService service)
    {
        _repo = repo;
        _config = config;
        _logger = logger;
        _backgroundJobs = backgroundJobs;
        this._service = service;
    }

    /// <summary>
    /// Uploads a chunk. The first call (chunkNumber = 0) should include file metadata and totalChunks, the API will create the batch and return BatchId.
    /// Subsequent calls must pass batchId.
    /// </summary>
    [HttpPost("upload")]
    public async Task<IActionResult> UploadChunk([FromForm] IFormFile chunkFile, [FromForm] string fileName, [FromForm] int totalChunks, [FromForm] int chunkNumber, [FromForm] Guid? batchId, [FromForm] bool readyForProcess = false)
    {

        try
        {

       
        if (chunkFile == null) return BadRequest("Missing chunk file");

        Guid createdBatchId;
        if (chunkNumber == 0 && (batchId == null || batchId == Guid.Empty))
        {
            // Create new batch
            createdBatchId = await _repo.CreateOrGetBatchAsync(fileName, totalChunks);
        }
        else
        {
            if (batchId == null || batchId == Guid.Empty) return BadRequest("batchId is required for non-first chunks");
            createdBatchId = batchId.Value;
        }

        var storageRoot = _config.GetValue<string>("StorageRoot") ?? Path.Combine(Directory.GetCurrentDirectory(), "Storage");
        using (var stream = chunkFile.OpenReadStream())
        {
            await _repo.SaveChunkAsync(createdBatchId, chunkNumber, stream, storageRoot);
        }

        if (readyForProcess)
        {
            await _repo.MarkBatchReadyAsync(createdBatchId);
            // Enqueue Hangfire job to process
            _backgroundJobs.Enqueue<IProcessingService>(s => s.ProcessBatchAsync(createdBatchId));
        }

        return Ok(new { batchId = createdBatchId });

        }
        catch (Exception ex)
        {

            throw ex;
        }
    }
    [HttpPost("process-chunk")]
    public async Task<IActionResult> ProcessChunk([FromQuery] Guid batchId, [FromQuery] int chunkNumber, IFormFile file)
    {
        var tempPath = Path.Combine(Path.GetTempPath(), $"{Guid.NewGuid()}.xlsx");

        await using (var stream = new FileStream(tempPath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        var count = await _service.ProcessExcelChunkAsync(tempPath, batchId, chunkNumber);
        System.IO.File.Delete(tempPath);

        return Ok(new { RecordsProcessed = count });
    }
}
