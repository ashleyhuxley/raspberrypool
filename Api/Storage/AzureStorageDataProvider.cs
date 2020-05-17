using Microsoft.Azure.Cosmos.Table;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace RaspberryPool.Api.Storage
{
    public class AzureStorageDataProvider
    {
        private static string connectionString = "";

        public static async Task<double> GetLatest(string sensor)
        {
            var table = GetTable("Setting");

            var filter = TableQuery.CombineFilters(
                TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.Equal, "latest"),
                TableOperators.And,
                TableQuery.GenerateFilterCondition("RowKey", QueryComparisons.Equal, sensor));

            var query = new TableQuery<Setting>().Where(filter);

            TableContinuationToken continuationToken = null;

            var result = await table.ExecuteQuerySegmentedAsync(query, continuationToken);
            return result.Results[0].Value;
        }

        public static async Task<bool> IsOn(string appliance)
        {
            var table = GetTable("Setting");

            var filter = TableQuery.CombineFilters(
                TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.Equal, "latest"),
                TableOperators.And,
                TableQuery.GenerateFilterCondition("RowKey", QueryComparisons.Equal, appliance));

            var query = new TableQuery<Setting>().Where(filter);

            TableContinuationToken continuationToken = null;

            var result = await table.ExecuteQuerySegmentedAsync(query, continuationToken);
            return result.Results[0].IsOn;
        }

        public static async Task<List<LogEntry>> GetLogs(DateTime from, DateTime to, string sensor)
        {
            var logs = new List<LogEntry>();

            var table = GetTable("Data");

            var partitionFilter = TableQuery.CombineFilters(
                TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.GreaterThan, from.ToString("yyyyMMdd-HH")),
                TableOperators.And,
                TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.LessThanOrEqual, to.ToString("yyyyMMdd-HH")));

            var rowFilter = TableQuery.CombineFilters(
                TableQuery.GenerateFilterCondition("RowKey", QueryComparisons.GreaterThan, sensor.ToUpperInvariant() + from.ToString("yyyyMMdd-HHmmss")),
                TableOperators.And,
                TableQuery.GenerateFilterCondition("RowKey", QueryComparisons.LessThanOrEqual, sensor.ToUpperInvariant() + to.ToString("yyyyMMdd-HHmmss")));

            var query = new TableQuery<LogEntry>().Where(TableQuery.CombineFilters(partitionFilter, TableOperators.And, rowFilter));

            TableContinuationToken continuationToken = null;

            do
            {
                var result = await table.ExecuteQuerySegmentedAsync(query, continuationToken);
                continuationToken = result.ContinuationToken;

                if (result.Results != null)
                {
                    foreach (var entity in result.Results)
                    {
                        logs.Add(entity);
                    }
                }

            } while (continuationToken != null);

            return logs;
        }

        public static async Task SetTimer(int desiredTemperature, DateTime startTime, DateTime endTime)
        {
            var table = GetTable("Setting");

            var setting = new TimerSetting
            {
                PartitionKey = "heater",
                RowKey = "heater",
                StartTime = startTime,
                EndTime = endTime,
                DesiredTemp = desiredTemperature
            };

            var operation = TableOperation.InsertOrMerge(setting);

            await table.ExecuteAsync(operation);
        }

        public static async Task<TimerSetting> GetTimerSetting()
        {
            var table = GetTable("Setting");

            var partitionFilter = TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.Equal, "heater");
            var rowFilter = TableQuery.GenerateFilterCondition("RowKey", QueryComparisons.Equal, "heater");

            var query = new TableQuery<TimerSetting>().Where(TableQuery.CombineFilters(partitionFilter, TableOperators.And, rowFilter));

            TableContinuationToken continuationToken = null;

            var result = await table.ExecuteQuerySegmentedAsync(query, continuationToken);
            return result.Results[0];
        }

        private static CloudTable GetTable(string table)
        {
            var account = CloudStorageAccount.Parse(connectionString);
            var client = account.CreateCloudTableClient();
            return client.GetTableReference(table);
        }
    }
}
