USE [BulkExcelDb]
GO
/****** Object:  Table [dbo].[BatchChunks]    Script Date: 11-11-2025 09:25:07 ******/
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
/****** Object:  Table [dbo].[Batches]    Script Date: 11-11-2025 09:25:07 ******/
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
/****** Object:  Table [dbo].[InvestorNotification]    Script Date: 11-11-2025 09:25:07 ******/
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
