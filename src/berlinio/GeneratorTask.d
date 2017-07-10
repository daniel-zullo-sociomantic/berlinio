module berlinio.GeneratorTask;


/// Imports.
import ocean.io.Console : Cin;
import ocean.task.Task;
import ocean.transition;

/// Generator task to process new records coming from stdin at throttled rate.
public class GeneratorTask(Client) : Task
{
    /// The client instance.
    private Client client;

    /// Delegate to process a command.
    private bool delegate (Client, string) process_dg;

    /**
        Constructor.

        Params:
            client = the client to perform the command on
            dg = the delegate to process a command
    */
    public this (Client client, typeof(this.process_dg) dg)
    {
        this.client = client;
        this.process_dg = dg;
    }

    /// Runs the task.
    public override void run ()
    {
        mstring buffer;

        buffer = Cin.get();
        while (buffer)
        {
            assert(process_dg(this.client, buffer.idup));

            buffer.length = 0;
            enableStomping(buffer);

            buffer = Cin.get();
        }
    }
}
