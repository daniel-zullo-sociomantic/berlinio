/**
    Main task module.

    Main task to initialize the swarm clients and run the main application
    objects.
*/

module berlinio.MainTask;


/// Imports.
import Version;

import berlinio.config.AppConfig;
import berlinio.GeneratorTask;
import berlinio.OutputTask;

import ocean.io.Stdout;
import ocean.task.Scheduler;
import ocean.task.Task;
import ocean.task.ThrottledTaskPool;
import ocean.task.util.Timer;
import ocean.transition;
import ocean.util.log.Log;

import tinyredis.redis;


/// Static module logger.
static private Logger log;
static this ()
{
    log = Log.lookup("berlinio.MainTask");
}


/**
    Main task to initialize the swarm clients and run the main application
    objects.
*/
public class MainTask : Task
{
    /// Task shared resources.
    public struct Resources
    {
        /// Channel name specified on the command line (if any).
        public cstring channel_name;
    }

    /// Task shared resources.
    private Resources resources;

    /**
        Initializes the shared resources for the task.

        Params:
            resources = the resource for the task
    */
    public void setResources (Resources resources)
    {
        this.resources = resources;
    }

    /**
        Used to pass to the application exit status flag from main task to the
        `run` method so that it can be used to deduce application exit status
        code.

        It is merely a workaround for the fact that tango.core.Fiber doesn't
        save co-routine exit value on its own.
    */
    private bool ok_;

    public bool ok ()
    {
        return this.ok_;
    }

    /**
        Runs the main application task.

        Initializes the swarm clients and run the main application objects.
    */
    override public void run ()
    {
        // suspend once so that rest of the code will execute
        // only when eventLoop is known to be running
        theScheduler.processEvents();

        // force shutdown in the end to avoid being stuck with
        // left-over epoll events
        scope(exit)
            theScheduler.shutdown();

        try
        {
            this.ok_ = true;

            Redis client = new Redis();

            auto task_pool = new ThrottledTaskPool!(OutputTask)(100, 10);
            auto generator = new GeneratorTask!(Redis)(client, &task_pool.start);
            task_pool.throttler.addSuspendable(generator);

            theScheduler.schedule(generator);

            SchedulerStats stats = theScheduler.getStats();
            log.trace("Task queue busy: {}", stats.task_queue_busy);
            log.trace("Task queue total: {}", stats.task_queue_total);
            log.trace("Suspended queue busy: {}", stats.suspended_queue_busy);
            log.trace("Suspended queue total: {}", stats.suspended_queue_total);
            log.trace("Worker fiber busy: {}", stats.worker_fiber_busy);
            log.trace("Worker fiber total: {}", stats.worker_fiber_total);

            task_pool.awaitRunningTasks();
        }
        catch (Exception e)
        {
            this.ok_ = false;

            stderr.formatln("An exception occurred!");
            stderr.formatln("Exception Type: {}", e.classinfo.name);
            stderr.formatln("Exception Message: {} in {}:{}", e.msg, e.file,
                            e.line);

            log.error("An exception occurred! Exception Type: {} "
                "Exception Message: {}", e.classinfo.name, e.msg);
        }
    }
}
