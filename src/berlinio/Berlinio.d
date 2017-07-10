/// Berlinio main module.
module berlinio.Berlinio;


/// Imports.
import Version;

import berlinio.config.AppConfig;
import berlinio.MainTask;

import ocean.text.Arguments;
import ocean.text.convert.Format;
import ocean.task.Scheduler;
import ocean.transition;
import ocean.util.app.DaemonApp;
import ocean.util.config.ConfigParser;
import ocean.util.log.Log;

import core.stdc.stdlib: EXIT_FAILURE, EXIT_SUCCESS;


/// Static module logger.
static private Logger log;
static this ()
{
    log = Log.lookup("berlinio.Berlinio");
}


/// Main class.
public class Berlinio : DaemonApp
{
    /// Main task.
    private MainTask task;

    /// Constructor.
    public this ()
    {
        static immutable name = "Berlinio";
        static immutable desc = "Performs records updates in a Redis database "
        "based on data streams comming from stdin or a relational database";

        DaemonApp.OptionalSettings settings;

        settings.usage = "<executable> [-c <config.ini>] [-C <channel>]";

        settings.help = "";

        super(name, desc, versionInfo, settings);

        this.task = new MainTask();
    }

    /**
        Get values from the configuration file.

        Params:
            app = the application instance
            config = the configuration parser
    */
    public override void processConfig (IApplication app, ConfigParser config)
    {
        AppConfig.init(config);
    }

    /**
        Initializes the scheduler and enters to the epoll event loop.

        Params:
            args = the command line arguments
            config = the configuration parser

        Returns:
            the application return value
    */
    override protected int run (Arguments args, ConfigParser config)
    {
        log.info("{} running", this.name);

        // Global scheduler setup to use the task system.
        // The scheduler is shared by the stream processor and all tasks.
        SchedulerConfiguration sc;
        sc.worker_fiber_limit = AppConfig.scheduler.worker_fiber_limit;
        sc.task_queue_limit = AppConfig.scheduler.task_queue_limit;
        sc.suspended_task_limit = AppConfig.scheduler.suspended_task_limit;
        initScheduler(sc);

        // In order for signal and timer handling to be processed, we must
        // call this method. This registers one or more clients with epoll.
        this.startEventHandling(theScheduler.epoll());

        theScheduler.schedule(this.task);

        theScheduler.eventLoop();

        return this.task.ok ? EXIT_SUCCESS : EXIT_FAILURE;
    }

    /// Called by the timer extension when the stats period fires.
    override protected void onStatsTimer ()
    {
    }

    /**
        Adds command line arguments

        Params:
            app = the application instance
            args = the command line arguments to add
    */
    override public void setupArgs ( IApplication app, Arguments args )
    {
        args("channel").aliased('C').params(1)
            .help("Specify which channel to operate on");
    }

    /**
        Validates command line arguments.

        Params:
            app = the application
            args = the command line arguments to validate

        Returns:
            the error message, if any argument failed to validate
    */
    override public cstring validateArgs (IApplication app, Arguments args)
    {
        return null;
    }

    /**
        Process the command line arguments.

        Params:
            app = the application
            args = the arguments to process
    */
    override public void processArgs (IApplication app, Arguments args)
    {
        MainTask.Resources resources;

        resources.channel_name = args.getString("channel");
        this.task.setResources(resources);
    }
}
