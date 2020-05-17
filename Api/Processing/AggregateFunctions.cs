using RaspberryPool.Api.Extensions;
using RaspberryPool.Api.Model;
using RaspberryPool.Api.Storage;
using System;
using System.Collections.Generic;

namespace RaspberryPool.Api.Processing
{
    public static class AggregateFunctions
    {
        public static Dictionary<Precision, Func<LogEntry, string>> PrecisionAggregates = new Dictionary<Precision, Func<LogEntry, string>>
        {
            { Precision.Day, Day },
            { Precision.HalfHour, HalfHour },
            { Precision.Hour, Hour },
            { Precision.Minute, Minute },
            { Precision.TenMinutes, TenMinutes }
        };

        private static string Day(LogEntry e)
        {
            var stamp = new DateTime(e.LogTime.Year, e.LogTime.Month, e.LogTime.Day, 0, 0, 0);
            return stamp.ToJsLocal();
        }

        private static string HalfHour(LogEntry e)
        {
            var stamp = e.LogTime;
            stamp = stamp.AddMinutes(-(stamp.Minute % 30));
            stamp = stamp.AddMilliseconds(-stamp.Millisecond - 1000 * stamp.Second);
            return stamp.ToJsLocal();
        }

        private static string Hour(LogEntry e)
        {
            var stamp = new DateTime(e.LogTime.Year, e.LogTime.Month, e.LogTime.Day, e.LogTime.Hour, 0, 0);
            return stamp.ToJsLocal();
        }

        private static string Minute(LogEntry e)
        {
            var stamp = new DateTime(e.LogTime.Year, e.LogTime.Month, e.LogTime.Day, e.LogTime.Hour, e.LogTime.Minute, 0);
            return stamp.ToJsLocal();
        }

        private static string TenMinutes(LogEntry e)
        {
            var stamp = e.LogTime;
            stamp = stamp.AddMinutes(-(stamp.Minute % 10));
            stamp = stamp.AddMilliseconds(-stamp.Millisecond - 1000 * stamp.Second);
            return stamp.ToJsLocal();
        }
    }
}
