using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using RaspberryPool.Api.Extensions;
using RaspberryPool.Api.Model;
using RaspberryPool.Api.Processing;
using RaspberryPool.Api.Storage;

namespace RaspberryPool.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DataController : ControllerBase
    {
        private readonly ILogger<DataController> _logger;

        public DataController(ILogger<DataController> logger)
        {
            _logger = logger;
        }

        [HttpGet("{sensor}")]
        public async Task<IEnumerable<SensorValue>> Get(string sensor, DateTime from, DateTime to, Precision precision)
        {
            var rawLogs = await AzureStorageDataProvider.GetLogs(from, to, sensor);

            if (sensor == "pool" || sensor == "air" || sensor == "output")
            {
                return LogProcesser.GetSensorData(rawLogs, precision);
            }
            else
            {
                return LogProcesser.GetApplianceData(rawLogs);
            }
        }

        [HttpGet("{sensor}/latest")]
        public async Task<double> GetLatest(string sensor)
        {
            return await AzureStorageDataProvider.GetLatest(sensor);
        }

        [HttpGet("{sensor}/status")]
        public async Task<bool> GetStatus(string sensor)
        {
            return await AzureStorageDataProvider.IsOn(sensor);
        }

        [HttpGet("timer")]
        public async Task<Model.TimerSetting> GetTimerSetting()
        {
            var setting = await AzureStorageDataProvider.GetTimerSetting();
            return new Model.TimerSetting
            {
                DesiredTemperature = Convert.ToInt32(setting.DesiredTemp),
                EndTime = setting.EndTime.ToJsLocal(),
                StartTime = setting.StartTime.ToJsLocal()
            };
        }

        [HttpPost("timer")]
        public async Task<IActionResult> PostSetting(Model.TimerSetting setting)
        {
            var startTime = DateTime.Parse(setting.StartTime).ToUniversalTime();
            var endTime = DateTime.Parse(setting.EndTime).ToUniversalTime();

            if (setting.DesiredTemperature < 0 || setting.DesiredTemperature > 40)
            {
                return BadRequest("Invalid temperature");
            }

            if ((startTime > endTime) || (endTime < DateTime.UtcNow))
            {
                return BadRequest("Invalid date");
            }

            await AzureStorageDataProvider.SetTimer(
                setting.DesiredTemperature, 
                startTime, 
                endTime);

            return Ok();
        }
    }
}
