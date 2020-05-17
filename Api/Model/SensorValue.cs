using RaspberryPool.Api.Extensions;
using System;

namespace RaspberryPool.Api.Model
{
    public class SensorValue
    {
        public SensorValue(DateTime utcDate, double value)
        {
            t = utcDate.ToJsLocal();
            y = value;
        }

        public SensorValue(string time, double value)
        {
            t = time;
            y = value;
        }

        public string t { get; set; }
        public double y { get; set; }
    }
}
