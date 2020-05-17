using Microsoft.Azure.Cosmos.Table;
using System;

namespace RaspberryPool.Api.Storage
{
    public class LogEntry : TableEntity
    {
        public LogEntry(DateTime timeStamp, string sensor)
        {
            PartitionKey = timeStamp.ToString("yyyyMMdd-HH");
            RowKey = sensor.ToUpperInvariant() + timeStamp.ToString("yyyyMMdd-HHmmss");
            LogTime = timeStamp;
        }

        public LogEntry()
        { }

        public DateTime LogTime { get; set; }

        public string SensorId { get; set; }

        public double Value { get; set; }

        public bool IsOn { get; set; }
    }
}
