USE [master]
GO
/****** Object:  Database [BulkExcelDb]    Script Date: 11-11-2025 19:45:54 ******/
CREATE DATABASE [BulkExcelDb]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BulkExcelDb', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\BulkExcelDb.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'BulkExcelDb_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\BulkExcelDb_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [BulkExcelDb] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BulkExcelDb].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BulkExcelDb] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BulkExcelDb] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BulkExcelDb] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BulkExcelDb] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BulkExcelDb] SET ARITHABORT OFF 
GO
ALTER DATABASE [BulkExcelDb] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BulkExcelDb] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BulkExcelDb] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BulkExcelDb] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BulkExcelDb] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BulkExcelDb] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BulkExcelDb] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BulkExcelDb] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BulkExcelDb] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BulkExcelDb] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BulkExcelDb] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BulkExcelDb] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BulkExcelDb] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BulkExcelDb] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BulkExcelDb] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BulkExcelDb] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BulkExcelDb] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BulkExcelDb] SET RECOVERY FULL 
GO
ALTER DATABASE [BulkExcelDb] SET  MULTI_USER 
GO
ALTER DATABASE [BulkExcelDb] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BulkExcelDb] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BulkExcelDb] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BulkExcelDb] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BulkExcelDb] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BulkExcelDb] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'BulkExcelDb', N'ON'
GO
ALTER DATABASE [BulkExcelDb] SET QUERY_STORE = OFF
GO
USE [BulkExcelDb]
GO
/****** Object:  Schema [HangFire]    Script Date: 11-11-2025 19:45:54 ******/
CREATE SCHEMA [HangFire]
GO
/****** Object:  Table [dbo].[BatchChunks]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchChunks](
	[ID] [uniqueidentifier] NOT NULL,
	[BatchId] [uniqueidentifier] NOT NULL,
	[ChunkNumber] [int] NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[FilePath] [nvarchar](512) NULL,
	[ReceivedAt] [datetime2](7) NOT NULL,
	[ProcessedAt] [datetime2](7) NULL,
	[IsCompleted] [bit] NOT NULL,
	[CompletedAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Batches]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Batches](
	[BatchId] [uniqueidentifier] NOT NULL,
	[FileName] [nvarchar](260) NOT NULL,
	[TotalChunks] [int] NOT NULL,
	[ReceivedChunks] [int] NOT NULL,
	[ProcessedChunks] [int] NOT NULL,
	[ReadyForProcess] [bit] NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[CompletedAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[BatchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvestorNotification]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvestorNotification](
	[ID] [uniqueidentifier] NOT NULL,
	[BatchId] [uniqueidentifier] NOT NULL,
	[ChunkNumber] [int] NOT NULL,
	[LoanNumber] [nvarchar](100) NULL,
	[LetterId] [nvarchar](100) NULL,
	[OldInvNum] [nvarchar](100) NULL,
	[NewInvNum] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[AggregatedCounter]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[AggregatedCounter](
	[Key] [nvarchar](100) NOT NULL,
	[Value] [bigint] NOT NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_CounterAggregated] PRIMARY KEY CLUSTERED 
(
	[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Counter]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Counter](
	[Key] [nvarchar](100) NOT NULL,
	[Value] [int] NOT NULL,
	[ExpireAt] [datetime] NULL,
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_HangFire_Counter] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Hash]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Hash](
	[Key] [nvarchar](100) NOT NULL,
	[Field] [nvarchar](100) NOT NULL,
	[Value] [nvarchar](max) NULL,
	[ExpireAt] [datetime2](7) NULL,
 CONSTRAINT [PK_HangFire_Hash] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Field] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Job]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Job](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[StateId] [bigint] NULL,
	[StateName] [nvarchar](20) NULL,
	[InvocationData] [nvarchar](max) NOT NULL,
	[Arguments] [nvarchar](max) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_Job] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[JobParameter]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[JobParameter](
	[JobId] [bigint] NOT NULL,
	[Name] [nvarchar](40) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_HangFire_JobParameter] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[JobQueue]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[JobQueue](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[JobId] [bigint] NOT NULL,
	[Queue] [nvarchar](50) NOT NULL,
	[FetchedAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_JobQueue] PRIMARY KEY CLUSTERED 
(
	[Queue] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[List]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[List](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Key] [nvarchar](100) NOT NULL,
	[Value] [nvarchar](max) NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_List] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Schema]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Schema](
	[Version] [int] NOT NULL,
 CONSTRAINT [PK_HangFire_Schema] PRIMARY KEY CLUSTERED 
(
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Server]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Server](
	[Id] [nvarchar](200) NOT NULL,
	[Data] [nvarchar](max) NULL,
	[LastHeartbeat] [datetime] NOT NULL,
 CONSTRAINT [PK_HangFire_Server] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Set]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Set](
	[Key] [nvarchar](100) NOT NULL,
	[Score] [float] NOT NULL,
	[Value] [nvarchar](256) NOT NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_Set] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Value] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[State]    Script Date: 11-11-2025 19:45:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[State](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[JobId] [bigint] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Reason] [nvarchar](100) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[Data] [nvarchar](max) NULL,
 CONSTRAINT [PK_HangFire_State] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_BatchChunks_BatchId_ChunkNumber]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_BatchChunks_BatchId_ChunkNumber] ON [dbo].[BatchChunks]
(
	[BatchId] ASC,
	[ChunkNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_InvestorNotification_BatchId]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_InvestorNotification_BatchId] ON [dbo].[InvestorNotification]
(
	[BatchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_AggregatedCounter_ExpireAt]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_AggregatedCounter_ExpireAt] ON [HangFire].[AggregatedCounter]
(
	[ExpireAt] ASC
)
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_Hash_ExpireAt]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Hash_ExpireAt] ON [HangFire].[Hash]
(
	[ExpireAt] ASC
)
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_Job_ExpireAt]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Job_ExpireAt] ON [HangFire].[Job]
(
	[ExpireAt] ASC
)
INCLUDE([StateName]) 
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_HangFire_Job_StateName]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Job_StateName] ON [HangFire].[Job]
(
	[StateName] ASC
)
WHERE ([StateName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_List_ExpireAt]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_List_ExpireAt] ON [HangFire].[List]
(
	[ExpireAt] ASC
)
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_Server_LastHeartbeat]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Server_LastHeartbeat] ON [HangFire].[Server]
(
	[LastHeartbeat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_Set_ExpireAt]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Set_ExpireAt] ON [HangFire].[Set]
(
	[ExpireAt] ASC
)
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_HangFire_Set_Score]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Set_Score] ON [HangFire].[Set]
(
	[Key] ASC,
	[Score] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_State_CreatedAt]    Script Date: 11-11-2025 19:45:54 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_State_CreatedAt] ON [HangFire].[State]
(
	[CreatedAt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchChunks] ADD  DEFAULT ('Received') FOR [Status]
GO
ALTER TABLE [dbo].[BatchChunks] ADD  DEFAULT (sysutcdatetime()) FOR [ReceivedAt]
GO
ALTER TABLE [dbo].[BatchChunks] ADD  DEFAULT ((0)) FOR [IsCompleted]
GO
ALTER TABLE [dbo].[Batches] ADD  DEFAULT ((0)) FOR [ReceivedChunks]
GO
ALTER TABLE [dbo].[Batches] ADD  DEFAULT ((0)) FOR [ProcessedChunks]
GO
ALTER TABLE [dbo].[Batches] ADD  DEFAULT ((0)) FOR [ReadyForProcess]
GO
ALTER TABLE [dbo].[Batches] ADD  DEFAULT ('Pending') FOR [Status]
GO
ALTER TABLE [dbo].[Batches] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[InvestorNotification] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[BatchChunks]  WITH CHECK ADD  CONSTRAINT [FK_BatchChunks_Batches] FOREIGN KEY([BatchId])
REFERENCES [dbo].[Batches] ([BatchId])
GO
ALTER TABLE [dbo].[BatchChunks] CHECK CONSTRAINT [FK_BatchChunks_Batches]
GO
ALTER TABLE [dbo].[InvestorNotification]  WITH NOCHECK ADD  CONSTRAINT [FK_InvestorNotification_Batches] FOREIGN KEY([BatchId])
REFERENCES [dbo].[Batches] ([BatchId])
GO
ALTER TABLE [dbo].[InvestorNotification] CHECK CONSTRAINT [FK_InvestorNotification_Batches]
GO
ALTER TABLE [HangFire].[JobParameter]  WITH CHECK ADD  CONSTRAINT [FK_HangFire_JobParameter_Job] FOREIGN KEY([JobId])
REFERENCES [HangFire].[Job] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [HangFire].[JobParameter] CHECK CONSTRAINT [FK_HangFire_JobParameter_Job]
GO
ALTER TABLE [HangFire].[State]  WITH CHECK ADD  CONSTRAINT [FK_HangFire_State_Job] FOREIGN KEY([JobId])
REFERENCES [HangFire].[Job] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [HangFire].[State] CHECK CONSTRAINT [FK_HangFire_State_Job]
GO
USE [master]
GO
ALTER DATABASE [BulkExcelDb] SET  READ_WRITE 
GO
