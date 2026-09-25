# shellcheck shell=bash

run_segment() {
	local cpu_line cpu_idle cpu_usage

	if tp_shell_is_linux; then
		cpu_line=$(top -b -n 1 | grep "Cpu(s)")
		cpu_idle=$(echo "$cpu_line" | grep -o "[0-9]\+\\(.[0-9]\\+\\)\\? *id\\(le\\)\\?" | awk '{ print $1 }')
	elif tp_shell_is_macos; then
		cpu_line=$(top -e -l 1 | grep "CPU usage:" | sed 's/CPU usage: //')
		cpu_idle=$(echo "$cpu_line" | awk '{print $5}' | sed 's/%//')
	fi

	if [ -n "$cpu_idle" ]; then
		cpu_usage=$(awk -v idle="$cpu_idle" 'BEGIN { printf "%.0f", 100 - idle }')
		printf "󰓅 %s%%" "$cpu_usage"
		return 0
	fi

	return 1
}
