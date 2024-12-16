#!/bin/bash

# Default configuration variables
INTERVAL=10    
FORMAT="text"
OUTPUT_FILE="system_report"

# ANSI color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Function to print error msg and exit
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2  # $1 is the error msg passed in the func
    exit 1
}

# OS validation
validate_system() {
    if [[ ! "$OSTYPE" == "linux-gnu"* ]]; then
        error_exit "This script supports Linux systems only."
    fi
}

# User input validation
while [[ $# -gt 0 ]]; do
    case $1 in
        --interval)
            INTERVAL="$2"
            if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
            echo "Error: --interval must be a positive number."
            exit 1
      fi
            shift 2
            ;;
        --format)
            FORMAT="$2"
            if [[ "$FORMAT" != "text" && "$FORMAT" != "json" && "$FORMAT" != "csv" ]]; then
            echo "Error: --format must be text, json, or csv. (Case Sensitive)"
            exit 1
      fi
            shift 2
            ;;
        *)
            error_exit "Unknown argument: $1"
    esac
done

# System info colleciton
get_system_info() {

    # CPU
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}') # top -bn1 (batch mode, run 1 time)

    # Memory
    memory_info=($(free | grep Mem | awk '{print $2, $3, $4, $7}'))
    total_mem=$((memory_info[0] / 1024))
    used_mem=$((memory_info[1] / 1024))
    free_mem=$((memory_info[2] / 1024))
    available_mem=$((memory_info[3] / 1024))

    # Disk
    disk_info=$(df -h | awk '$NF=="/" {print $2, $3, $5}')
    total_disk=$(echo "$disk_info" | awk '{print $1}')
    used_disk=$(echo "$disk_info" | awk '{print $2}')
    disk_percent=$(echo "$disk_info" | awk '{print $3}' | sed 's/%//')

    # Top 5 processes
    top_processes=$(ps aux | awk '{print $2, $3, $11}' | sort -k2 -nr | head -n 5)

   
    # CPU > 80%
    if [[ $(echo "$cpu_usage > 80" | bc) -eq 1 ]]; then
        echo -e "${RED}WARNING: High CPU Usage - ${cpu_usage}%${NC}"
    fi

    # Memory > 75%
    if [[ $((used_mem * 100 / total_mem)) -gt 75 ]]; then
        echo -e "${RED}WARNING: High Memory Usage - $((used_mem * 100 / total_mem))%${NC}"
    fi

    # Disk > 90%
    if [[ $disk_percent -gt 90 ]]; then
        echo -e "${RED}WARNING: High Disk Usage - ${disk_percent}%${NC}"
    fi

    # Output file 
    case $FORMAT in
        "text")
            # Call text report generator function with collected data
            generate_text_report "$cpu_usage" "$total_mem" "$used_mem" "$free_mem" "$total_disk" "$used_disk" "$disk_percent" "$top_processes"
            ;;
        "json")
            # Call JSON report generator function with collected data
            generate_json_report "$cpu_usage" "$total_mem" "$used_mem" "$free_mem" "$total_disk" "$used_disk" "$disk_percent" "$top_processes"
            ;;
        "csv")
            # Call CSV report generator function with collected data
            generate_csv_report "$cpu_usage" "$total_mem" "$used_mem" "$free_mem" "$total_disk" "$used_disk" "$disk_percent" "$top_processes"
            ;;
        *)
            # No action required. Case alrady handled.
            :
            ;;
    esac
}

# Create output file
generate_text_report() {
    output_file="${OUTPUT_FILE}.txt"
    
    {
        echo "System Performance Report"
        echo "========================="
        echo "Timestamp: $(date)"
        echo ""
        echo "CPU Information:"
        echo "  Usage: $1%"
        echo ""
        echo "Memory Information:"
        echo "  Total Memory: ${2} MB"
        echo "  Used Memory: ${3} MB"
        echo "  Free Memory: ${4} MB"
        echo ""
        echo "Disk Information:"
        echo "  Total Disk Space: $5"
        echo "  Used Disk Space: $6"
        echo "  Disk Usage Percentage: $7%"
        echo ""
        echo "Top 5 CPU Consuming Processes:"
        echo "$8" | awk '{print "  PID: " $1 ", CPU: " $2 "%, Process: " $3}'
    } > "$output_file"
    
    echo "Report saved to $output_file"
}

generate_json_report() {
    output_file="${OUTPUT_FILE}.json"
    {
        echo "{"
        echo "  \"timestamp\": \"$(date)\","
        echo "  \"cpu\": {"
        echo "    \"usage\": $1"
        echo "  },"
        echo "  \"memory\": {"
        echo "    \"total\": $2,"
        echo "    \"used\": $3,"
        echo "    \"free\": $4"
        echo "  },"
        echo "  \"disk\": {"
        echo "    \"total\": \"$5\","
        echo "    \"used\": \"$6\","
        echo "    \"usage_percentage\": $7"
        echo "  },"
        echo "  \"top_processes\": ["
        echo "$8" | awk '{print "    {\"pid\": \"" $1 "\", \"cpu\": \"" $2 "\", \"name\": \"" $3 "\"}"}' | sed '$!s/$/,/'
        echo "  ]"
        echo "}"
    } > "$output_file"
    echo "Report saved to $output_file"
}

generate_csv_report() {
    output_file="${OUTPUT_FILE}.csv"
    {
        echo "Timestamp,CPU Usage,Total Memory (MB),Used Memory (MB),Free Memory (MB),Total Disk,Used Disk,Disk Usage %"
        echo "$(date),$1,$2,$3,$4,$5,$6,$7"
        echo ""
        echo "PID,CPU Usage,Process Name"
        echo "$8"
    } > "$output_file"
    echo "Report saved to $output_file"
}

main() {
    # Validate system
    validate_system
    
    # Startup msg
    echo -e "${GREEN}Starting System Performance Monitoring${NC}"
    echo -e "Interval: ${INTERVAL} seconds | Format: ${FORMAT}"
    
    while true; do
        get_system_info
        sleep "$INTERVAL"
    done
}

main
