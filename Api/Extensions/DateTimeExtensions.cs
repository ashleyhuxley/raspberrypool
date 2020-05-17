using System;

namespace RaspberryPool.Api.Extensions
{
    public static class DateTimeExtensions
    {
        private static TimeZoneInfo TimeInfo = TimeZoneInfo.FindSystemTimeZoneById("GMT Standard Time");

        public static string ToJsLocal(this DateTime date)
        {
            return TimeZoneInfo.ConvertTimeFromUtc(date, TimeInfo).ToString("yyyy-MM-dd HH:mm:ss");
        }

        public static DateTime GmtToUtc(this DateTime gmtTime)
        {
            return TimeZoneInfo.ConvertTimeToUtc(gmtTime);
        }
    }
}
