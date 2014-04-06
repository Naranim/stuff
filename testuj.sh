#!/bin/bash

# constants
SUPPORTED_LANG=('cpp' 'c' 'py' 'go')
DIFF_COMMAND="diff -w"

# variables
declare -i test_run
declare -i test_passed
PRINT_HELP=""
SOLUTION=""
IN_FOLDER=""
OUT_FOLDER=""
SHOW_DIFF=""
NO_COMPARE=""
REGEX=""
VERBOSE=""
PRINT_HELP=""

function join { 
	separator="$1" # e.g. constructing regex, pray it does not contain %s
	shift
	regex="$( printf "${separator}%s" "${@}" )"
	regex="${regex:${#separator}}" # remove leading separator
	echo "${regex}"
}

function contains {
	local e
	for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
	return 1
}

function remove_path {
	f=$1
	echo "${f##*/}"
}

function file_name {
	f=$1
	f=$(remove_path $f)
	echo "${f%%.*}"
}

function file_ext {
	f=$1
	echo "${f##*.}"
}

function green {
	echo "$(tput setaf 2)$1$(tput sgr0)"
}

function red {
	echo "$(tput setaf 1)$1$(tput sgr0)"
}

function parse_args {
	while [[ $# > 0 ]]; do
		key="$1"
		shift

		case $key in
			-h|--help)
				PRINT_HELP="1"
				;;
			-s|--solution)
				SOLUTION="$1"
				shift
				;;
			-i|--in)
				IN_FOLDER="$1"
				shift
				;;
			-o|--out)
				OUT_FOLDER="$1"
				shift
				;;
			-d|--diff)
				SHOW_DIFF="1"
				;;
			-n|--no-compare)
				NO_COMPARE="1"
				;;
			-r|--tests_regex)
				REGEX="$1"
				shift
				;;
			-v|--verbose)
				VERBOSE="1"
				;;
			*)
				PRINT_HELP="1"
				;;
		esac
	done
}

function print_help {
	printf "Welcome to testuj! Usage:\n
   -h, --help\t\tprints help
   -s, --solution\tseta solution file (default solution.*)
   -i, --in\t\tsets tests input files folder
   -o, --out\t\tsets tests outs folder
   -d, --diff\t\tshow diff
   -n, --no-compare\trun solution on all tests and print stdout, don't compare
   -r, --tests_regex\tsets regex for input and output files
   -v, --verbose\tverbose mode"
}

function set_solution {
	if [[ ! -z "$SOLUTION" ]]; then
		echo $SOLUTION
		if [ ! -e $SOLUTION ]; then
			SOLUTION=""
		fi
	else 
		SUPP_LANG_REGEX=$(join "\|" "${SUPPORTED_LANG[@]}")
		tmp=$(ls | grep "solution\.\($SUPP_LANG_REGEX\)\$" | head -n 1)
		if [[ -z $tmp ]]; then
			tmp=$(ls | grep "\.\($SUPP_LANG_REGEX\)\$" | head -n 1)
		fi
		SOLUTION=$tmp
	fi

	if [[ ! -z "$VERBOSE" ]]; then
		echo "solution file: $SOLUTION"
	fi

	if [[ ! -z "$SOLUTION" ]]; then
		return 0
	else 
		return 1
	fi
}

function set_language {
	extension="${SOLUTION##*.}"
	if $(contains $extension ${SUPPORTED_LANG[@]}); then
		LANG=$extension
		if [[ ! -z "$VERBOSE" ]]; then
			echo "language: $LANG"
		fi
		return 0
	fi
	return 1
}

function set_in {
	if [[ -z "$IN_FOLDER" ]]; then
		IN_FOLDER=$(pwd)
	fi

	if [[ ! -z "$VERBOSE" ]]; then
		echo "input files path: $IN_FOLDER"
	fi

	if [[ ! -d $IN_FOLDER ]]; then
		return 1
	else
		return 0
	fi
}

function set_out {
	if [[ -z "$OUT_FOLDER" ]]; then
		OUT_FOLDER=$(pwd)
	fi

	if [[ ! -z "$VERBOSE" ]]; then
		echo "output files path: $OUT_FOLDER"
	fi

	if [[ ! -d $OUT_FOLDER ]]; then
		return 1
	else
		return 0
	fi
}

function set_regex {
	if [[ -z "$REGEX" ]]; then
		REGEX=".*"
	fi
	return 0
}

function set_commands {
	case $LANG in
		cpp|c)
			COMPILE_COMMAND="g++ $SOLUTION -O2 -Wall -o .solution"
			RUN_COMMAND="./.solution"
			;;
		py)
			COMPILE_COMMAND="echo \"dupa\" >> /dev/null"
			RUN_COMMAND="python $SOLUTION"
			;;
		go)
			COMPILE_COMMAND="go build -o .solution $SOLUTION"
			RUN_COMMAND="./.solution"
			;;
	esac
}

function compile {
	if [[ ! -z "$VERBOSE" ]]; then 
		echo "compiling..."
		echo "command: $COMPILE_COMMAND"
	fi
	comp_out=$($COMPILE_COMMAND)
	comp_res=$?

	if [[ comp_res ]]; then
		echo $comp_out
		return 0
	fi

	if [[ ! -z "$VERBOSE" ]]; then 
		echo "compilation done"
	fi

	return 1
}

function make_testing {
	test_files=$(find $IN_FOLDER -maxdepth 1 -type f | grep ".*\.in$" | grep "$REGEX" | sort)
	declare -i counter
	counter=1
	for input in $test_files; do
		input_name=$(file_name $input)
		output=$(find $OUT_FOLDER -maxdepth 1 -type f -name $input_name.out)
		if [[ ! -z "$VERBOSE" ]]; then
			echo "input: $input"
			echo "output: $output"
		fi

		if [[ -z "$output" ]]; then
			if [[ ! -z "$VERBOSE" ]]; then
				echo "skipping $input_name, output not found"
			fi
			continue
		fi

		$RUN_COMMAND < $input > .tmp_out
		ex_stat=$?
		if [ ! ex_stat ]; then
			result=$(red RTE)
		else 
			d=$($DIFF_COMMAND .tmp_out $output)
			if [[ ! -z "$d" ]]; then
				result=$(red ANS)
				if [[ ! -z $SHOW_DIFF ]]; then
					comment=$d
				fi
			else
				result=$(green OK)
				test_passed=$test_passed+1
			fi
		fi

		echo -e " $counter.\t" $result "\t" $input_name
		if [[ ! -z $comment ]]; then
			echo $comment
		fi
		counter=$counter+1
		test_run=$test_run+1

	done
}

function main {
	parse_args "$@"
	if [ $PRINT_HELP ]; then
		print_help
		exit 0
	fi

	if ! set_solution; then
		echo "solution not found"
		exit 1
	fi

	if ! set_language; then
		echo "language not supported"
		exit 1
	fi

	if ! set_in; then
		echo "input files folder not found"
		exit 1
	fi

	if ! set_out; then
		echo "output files folder not found"
		exit 1
	fi

	if ! set_regex; then
		echo "problem with regex"
		exit 1
	fi

	set_commands

	if ! compile; then
		echo "compilation failed!"
		exit 1
	fi

	test_run=0
	test_passed=0

	make_testing

	echo ""
	echo "Tests run: $test_run"
	echo "Tests passed: $test_passed"
	declare -i points
	points=$test_passed*100
	points=$points/$test_run
	echo "Points: $points"

	if [[ $test_run-$test_passed -eq 0 ]]; then
		echo $(green "All tests passed")
	else 
		declare -i errors
		errors=$test_run-$test_passed
		echo $(red "$errors tests failed")
	fi

}

main "$@"

