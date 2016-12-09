# bash_threader
Runs multiple tasks in background without using wait.  A, hopefully, flexible tool to run 
N concurrent processes in the background using a PID queue to avoid waiting for a "batch"
of processes to finish before starting the next batch.

This way we can always have the specified number of procecesses running at the same time without
needing to try and do it ourselves because, frankly, it kind of sucks writing it all the time.


# Whats the Point

To make doing the same thing on slightly different data easier in bash.

# How do I use it?

`cat ip_list.txt | ./threader.sh -s "ping $1"  -p 5` This would perform a default ping function, 
five at a time, for the entire ip_list.txt.

`./threader.sh -s "ping $1" -p 5 127.0.0.1 192.168.0.1 8.8.8.8 8.8.4.4 www.reddit.com`  This would ping
all five of the ending arguments at once.

`./threader.sh -s ./some_local_script -p 5 some arguments to that local script` This would call `./some_local_script`,
five at a time, with one argument at a time.  It's important to note that you must include the `./` if you are calling
a local script.  Imagine that you are basically typing whatever `-s` gets onto a command line.

`./threader.sh -s "cat $@" -p 2 -a /path/to/file /path/to/other_file` This would call two cat scripts that each get called
with all the arguments (`/path/to/file` and `/path/to/other_file`).  The `-a` flag means the `-s` script gets all the arguments.

So the take away is that we specify the task to run with `-s`.  We specify all the arguments after we specify all our flags.
We have to pass `-p` to specify how many parallel tasks to run at the same time.  We can pass `-a` to give all the arguments
to each task that runs instead of just one argument.  Not shown here but, we can specify `-m` to only run that many tasks
before we stop.

Lastly realize that no matter what your script is getting the arguments you try to send it.

`./threader.sh -s "sleep 1" -p 2 this is gonna break`  Won't work because you are basically calling `sleep 1 this` and so on...

# A point about inline scripts

We can specify a string with `-s` that contains something which we wish to run... In order for that thing to get arguments we must
treat it as though it were placed in a `.sh` file and run from there... The point being that if you want to do something to the arguments
the inline script is going to get you need to tell it to use the first argument.  Obviously you can use `$@` to give the inline script
all the arguments it's getting... you, probably, get the idea.

# Is this secure?

No, absolutely not.  We will blindly run ANYTHING passed to `-s` by setting it to a variable and calling it directly, without quotes.  So yea if you pass `-s rm -rf /` you will have a bad time.  So 100% keep this away from the script kiddies.

# Does this handle functions with spaces

Almost surely not.  I don't use eval because idk, i didn't, so just fork it and do it yourself?
Also consider stop putting spaces in your paths and script names because they tend to fuck shit up. <3 
