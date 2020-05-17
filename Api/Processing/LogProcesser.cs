using Microsoft.AspNetCore.Mvc.Formatters;
using RaspberryPool.Api.Extensions;
using RaspberryPool.Api.Model;
using RaspberryPool.Api.Storage;
using System;
using System.Collections.Generic;
using System.Linq;

namespace RaspberryPool.Api.Processing
{
    public class LogProcesser
    {
        public static IEnumerable<SensorValue> GetSensorData(IEnumerable<LogEntry> logs, Precision precision)
        {
            return from e in logs
                   group e by AggregateFunctions.PrecisionAggregates[precision](e) into g
                   select new SensorValue(g.Key, g.Average(v => Convert.ToDouble(v.Value)));
        }

        public static IEnumerable<SensorValue> GetApplianceData(IEnumerable<LogEntry> logs)
        {
            foreach (var log in logs)
            {
                yield return new SensorValue(log.LogTime, log.IsOn ? 0 : 1);
                yield return new SensorValue(log.LogTime, log.IsOn ? 1 : 0);
            }
        }
    }
}
