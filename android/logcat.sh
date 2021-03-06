#!/bin/sh

function get_pattern_from_package_name() {
	local package=$1

	if [ -z "$package" ]; then
		echo "package:$package"
		return
	fi

	local pids=$(adb shell busybox ps | grep -ie "$package" | awk '{print $1}')

	if [ -z "$pids" ]; then
		echo "pids:$pids";
		return;
	fi

	pids=($pids)

	local pid_patterns
	local i
	for((i=0; i<${#pids[@]}; i++));do
		pid_patterns=${pid_patterns:+$pid_patterns\\|}"(\\s*${pids[i]}):"
	done

	export pattern="$pid_patterns"
}

function process_opt() {
	while getopts "ae:p:" arguments 2>/dev/null; do
		echo "arguments is $arguments; \$OPTIND is $OPTIND; \$OPTERR is $OPTERR; \$OPTARG is $OPTARG;"

		case $arguments in
			a)
				echo "logcat option: $@"
				break
				;;
			e)
				export pattern="$OPTARG"
				echo "pattern: $pattern"
				;;
			p)
				export package="$OPTARG"
				echo "package: $package"
				get_pattern_from_package_name "$package"
				echo "pattern: $pattern"
				;;
			?)
				echo -e "Usage:$0 [option]"
				echo -e "\toption:"
				echo -e "\t-a logcat options: add logcat options"
				echo -e "\t-e pattern: logcat for regex pattern"
				echo -e "\t-p package: logcat for package"
				export error_msg="1"
				break
				;;
		esac
	done
	#OPTIND=0
}

function start_logcat() {
	process_opt $@

	if [ -n "$error_msg" ]; then
		return
	fi

	if [ -z "$pattern" ];then
		echo "adb logcat $@ -v brief "*:V""
		adb logcat -v brief "*:V"
	else
		shift $(($OPTIND - 1))
		echo "adb logcat $@ -v brief "*:V" | grep -ie "$pattern""
		adb logcat $@ -v brief "*:V" | grep -e "$pattern"
	fi
}

start_logcat $@
