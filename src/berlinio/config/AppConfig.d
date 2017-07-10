/// Parses a configuration file and stores its values in static variables.

module berlinio.config.AppConfig;


/// Imports.
import ocean.transition;
import ConfigReader = ocean.util.config.ConfigFiller;
import ocean.util.config.ConfigParser;


/**
    Scheduler related properties.

    worker_fiber_limit = maximum number of simultaneous worker fibers in the
                         scheduler pool
    task_queue_limit = maximum number of tasks awaiting scheduling in the queue
                       while all worker fibers are busy
    suspended_task_limit = maximum number of tasks that can be suspended in
                           between scheduler dispatch cycles
*/
private class SchedulerConfig
{
    uint worker_fiber_limit = 1_000;

    uint task_queue_limit = 50_000;

    uint suspended_task_limit = 2_000;
}


/// Configuration struct.
public struct AppConfig
{
    /// Static variables to handle the configuration file.
static:
    public SchedulerConfig scheduler;

    /**
        Initializes configuration.

        Params:
            config = configuration parser instance
    */
    public void init (ConfigParser config)
    {
        ConfigReader.fill("Scheduler", AppConfig.scheduler, config);
    }
}
