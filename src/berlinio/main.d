/**
    The entry point for the application.

    Usage: Just run the application.

    Run the application with -h flag to know more about usage.
*/

module berlinio.main;


/// Imports.
import berlinio.Berlinio;

import ocean.io.Stdout;
import ocean.transition;

import core.stdc.stdlib: EXIT_FAILURE, EXIT_SUCCESS;


/**
    Main function. Creates an instance of the main module class and runs it.

    Params:
        args = array with raw command line arguments
*/
int main (istring[] args)
{
    int exit_status = EXIT_SUCCESS;

    try
    {
        auto instance = new Berlinio;
        exit_status = instance.main(args);
    }
    catch ( Exception e )
    {
        exit_status = EXIT_FAILURE;

        stderr.formatln("An exception occurred!");
        stderr.formatln("Exception Type: {}", e.classinfo.name);
        stderr.formatln("Exception Message: {}", e.msg);
    }

    return exit_status;
}
