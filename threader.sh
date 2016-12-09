readonly PROGNAME=$(basename $0)


while getopts ":s:p:m:a" o; do
    case "${o}" in
		s)
			task_script=${OPTARG}
			;;
		p)
			parallel_processes=${OPTARG}
			;;
		m)
			max_processes=${OPTARG}
			;;	
		a)
			uniq_args_to_tasks=${OPTARG}
			;;
		\?)
		usage
        exit 1;
        ;;
    esac
done
shift $((OPTIND-1))



# GLOBALS
bp=();
bp_tmp=();
processes_run_so_far=0;


# HANDLE STDIN OR ARGS... WE CANT DO BOTH BECAUSE LOL IDK, DONT DO THAT.
if [ -z ${@+x} ]; then
	all_args=(`cat -`);
else
	all_args=("$@");
fi

if [ -z ${max_processes+x} ]; then
	max_processes=${#all_args[@]};
fi

usage(){
	echo <<BONER
	-s task_script					Full path to script to run in background.
	-p parallel_processes			Number of processes to run at any one time.
	[-m] max_processes				Max number of processes to run.  Defaults to the number of arguments given.  
										Which means if you omit -a and pass 6 args you'll run 6 tasks each one getting all 6 arguments.
	-a all_args_to_tasks			Normally each task gets all of the arguments passed to this script.  Passing this arg means each task only gets one arg.
										Obviously if the number of tasks being run exceeds the number of arguments when this flag is passed the remaining tasks will get called with nothing.

	Arguments for the tasks can be specified after all flags or from stdin.  Flags must be declared before all arguments otherwise the arguments between flags will likely get "dropped".
	Though i really don't know what will happen.

	EX: Passing arguments from stdin

	find . -type f |  $PROGNAME -s 
BONER
}


# REQUIRED FUNCTIONS
check_for_finished_pids(){

	for pid in "${bp[@]}"; do
	
		kill -0 "${pid}" 2>/dev/null
		r="$?";
		#echo "${pid} $r";
 		
 		if [ $r -eq 0 ]; then
 			bp_tmp+=("${pid}");
 		fi;

	done
	bp=("${bp_tmp[@]}");
 	bp_tmp=();
 	#echo "BP: ${bp[@]}"
}

run_new_task(){

	if [ -z ${all_args_to_tasks+x} ]; then
		${task_script} "${all_args[0]}" &
		all_args=(${all_args[@]:1})
	else
		${task_script} ${all_args[@]} &  
	fi;

	pid=$!;
	bp+=("${pid}");
	processes_run_so_far=$((processes_run_so_far+1));
}




while [ "${processes_run_so_far}" -lt "${max_processes}" ]; do

	if [ "${#bp[@]}" -lt "${parallel_processes}" ]; then
		run_new_task "$@"
 	else
 		check_for_finished_pids 
 	fi

done


while [ "${#bp[@]}" -gt 0 ]; do

	check_for_finished_pids

done