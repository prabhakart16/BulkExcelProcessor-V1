# Bulk Excel Processor - .NET 9 API

This is a minimal example .NET 9 Web API that supports chunked Excel uploads and Hangfire background processing.

## Setup

1. Install .NET 9 SDK.
2. Create a SQL Server database and run `sql/schema.sql`.
3. Update connection string in `appsettings.Development.json`.
4. From the `dotnet` folder, run:
   dotnet restore
   dotnet ef database update   # optional if you prefer EF migrations
   dotnet run

This sample uses EF Core for simple persistence and Hangfire for background jobs. Configure Hangfire to use SQL Server storage by setting `Hangfire:ConnectionString` in appsettings.
