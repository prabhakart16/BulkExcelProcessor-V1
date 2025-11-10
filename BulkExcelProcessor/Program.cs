using BulkExcelProcessor.Data;
using BulkExcelProcessor.Repositories;
using BulkExcelProcessor.Services;
using Hangfire;
using Hangfire.SqlServer;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Configuration
var configuration = builder.Configuration;
var connectionString = configuration.GetConnectionString("DefaultConnection") ?? "Server=.;Database=BulkExcelDb;Trusted_Connection=True;";
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAngularApp",
        policy =>
        {
            policy.WithOrigins("http://localhost:4200")
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .WithExposedHeaders("Content-Disposition");
        });
});
// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// EF Core
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

// Repositories & Services
builder.Services.AddScoped<IDataRepository, DataRepository>();
builder.Services.AddScoped<IProcessingService, ProcessingService>();

// Hangfire - configure to use SQL Server storage (recommended for production)
builder.Services.AddHangfire(hf => hf.UseSqlServerStorage(connectionString));
builder.Services.AddHangfireServer();

builder.Services.AddLogging();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseAuthorization();
app.MapControllers();

// Simple dashboard
app.UseHangfireDashboard("/hangfire");
app.UseCors("AllowAngularApp");
app.Run();
