using Microsoft.Azure.Cosmos.Table;
using Microsoft.OData.Edm;
using System;

namespace RaspberryPool.Api.Storage
{
    public class TimerSetting : TableEntity
    {
        public double DesiredTemp { get; set; }

        public DateTime StartTime { get; set; }

        public DateTime EndTime { get; set; }
    }
}
