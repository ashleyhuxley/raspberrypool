using Microsoft.Azure.Cosmos.Table;
using System;

namespace RaspberryPool.Api.Storage
{
    public class Setting : TableEntity
    {
        public Setting(string partitionKey, string rowKey)
        {
            PartitionKey = partitionKey;
            RowKey = rowKey;
        }

        public Setting()
        { }

        public double Value { get; set; }

        public Boolean IsOn { get; set; }
    }
}