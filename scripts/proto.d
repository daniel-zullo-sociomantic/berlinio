import std.conv : to; 
import std.getopt;
import std.stdio : write;
import std.format;

void setOp (T...) (T arguments)
{
    immutable string newline = "\r\n";

    write("*", arguments.length, newline); // Number of arguments

    foreach (arg; arguments)
    {
        write("$", arg.length, newline); // length of the argument
        write(arg, newline);             // name of the argument
    }
}

int main (string[] args)
{
    auto num_records = 1_000_000UL;
    auto help = false;

    getopt(args, "records|n", &num_records);

    foreach (i; 0..num_records)
    {
        auto key = "Key%d".format(i);
        auto value = "Value%d".format(i);
        setOp("SET", key, value);
    }

    return 0;
}

// usage: rdmd proto.d | redis-cli --pipe
