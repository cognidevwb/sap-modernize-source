using System.Globalization;
using Microsoft.Data.Sqlite;
using SapSettlement.Connectors;
using SapSettlement.Operations;

if (args.Length != 6)
{
    Console.Error.WriteLine("Usage: SapSettlement.Batch <extract.sqlite> <bank.csv> <company> <currency> <yyyy-MM-dd> <report-directory>");
    return 64;
}
using var cancellation = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) => { e.Cancel = true; cancellation.Cancel(); };
try
{
    var connection = new SqliteConnectionStringBuilder { DataSource = Path.GetFullPath(args[0]), Mode = SqliteOpenMode.ReadOnly };
    var ledger = new SqlInvoiceLedger(() => new SqliteConnection(connection.ConnectionString));
    var job = new SettlementJob(ledger);
    using var input = File.OpenText(args[1]);
    var report = await job.RunAsync(args[2], args[3], DateOnly.ParseExact(args[4], "yyyy-MM-dd", CultureInfo.InvariantCulture), input, cancellation.Token);
    var output = await ReportStore.SaveAsync(args[5], report, cancellation.Token);
    Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(new { report.ExceptionCount, report.DifferenceTotal, output }));
    return report.ExceptionCount == 0 ? 0 : 2;
}
catch (OperationCanceledException) { Console.Error.WriteLine("Settlement cancelled"); return 130; }
catch (Exception error) when (error is IOException or ArgumentException or FormatException or SqliteException)
{
    Console.Error.WriteLine($"Settlement failed: {error.GetType().Name}");
    return 1;
}
