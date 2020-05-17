using System;

namespace RaspberryPool.Api.Model
{
    public class TimerSetting
    {
        public int DesiredTemperature { get; set; }

        public string StartTime { get; set; }

        public string EndTime { get; set; }
    }
}
