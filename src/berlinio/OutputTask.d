module berlinio.OutputTask;

/// Imports.
import ocean.task.Task;
import ocean.task.util.Timer;
import ocean.transition;
import ocean.util.log.Log;
import ocean.io.Stdout;

import tinyredis.redis;


/// Static module logger.
static private Logger log;
static this ()
{
    log = Log.lookup("berlinio.OutputTask");
}


/// Task to perform commands on a database.
public class OutputTask : Task
{
    /// The client instance.
    private Redis client;

    /// Command to be processed.
    private cstring command;

    /// Flag to check whether or nor the current command has finished.
    private bool finished_request;

    /// Flag to check whether or nor the current command has succeeded.
    private bool succeeded_request;

    /**
        Copy the arguments required to run the task.

        Params:
            client = the client instance
            command = the command to be processed
    */
    public void copyArguments (Redis client, cstring command)
    {
        this.client = client;

        this.command = command;
    }

    /**
        Runs the task to perform a command in a database.

        Re-tries the command on failure until it succeeds or the number of
        retries is achieved.

        Suspends itself among re-tries using
        `this.resume()` and `this.suspend()` to control the execution of
        the bound worker fiber.
    */
    override public void run ()
    {
        this.succeeded_request = false;
        while (!this.succeeded_request)
        {
            this.finished_request = false;

            this.getOutput(this.command);
            this.notifier();

            if (!this.finished_request)
                this.suspend();

            if (this.succeeded_request)
                break;

            // Delay the retrying mechanism of the task to reduce the load on
            // the client
            static immutable RETRY_WAIT_US = 1_000_000; // 1s
            wait(RETRY_WAIT_US);
        }
    }

    /// Recycles the task.
    override public void recycle ()
    {
        this.client = null;
        this.command = null;

        this.succeeded_request = false;
        this.finished_request = false;
    }

    /**
        Output delegate to the get calls.

        Params:
            value = the result of the command
    */
    private void getOutput (in cstring value)
    {
        if (value.length)
        {
            //assert(this.client.send!(bool)(value));
            if (this.client.send!(bool)(cast(string)value))
                this.printRecord(value);
        }
    }

    /**
        Prints a record to stdout, according to the configured formatting
        options.

        Params:
            record = record to print
    */
    private void printRecord (in cstring value)
    {
        //log.info(value);
    }

    /**
        The notifier for the get request calls.

        Handles error logging.
    */
    private void notifier ()
    {
        if (false)
        {
            log.error("Error processing a request");
        }

        this.finished_request = true;
        this.succeeded_request = true;

        if (this.suspended())
        {
            this.resume();
        }
    }
}
