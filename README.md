# System Performance Monitoring Script

This script is designed to monitor the system's performance at regular intervals and generate reports in multiple formats: **text**, **JSON**, and **CSV**. 
It collects and reports data on CPU usage, memory usage, disk usage, and the top processes consuming CPU resources.

## Features

- **Monitors system performance**: CPU, memory, and disk usage.
- **Alerts on resource overuse**: Warns when CPU usage exceeds 80%, memory usage exceeds 75%, or disk usage exceeds 90%.
- **Customizable reporting**: Supports output in **text**, **JSON**, and **CSV** formats.
- **Interval-based monitoring**: Allows you to specify the monitoring interval.
- **Linux-only**: This script is intended for Linux-based systems.

## Requirements

- A Linux-based operating system.
- Basic util commands in linux like top, free etc.

## Usage

### 1. Clone the repository
Clone the repository to your local machine:
```bash
git clone https://github.com/PranshuGhildiyal/system_metrics_script.git
cd system_metrics_script
```

### 2. Make the script executable
```bash
chmod +x monitor_system.sh
```

### 3. Run the script
```bash
/bin/bash monitor_system.sh --interval 5 --format text
```
#### Available options:
- --interval <seconds>: Set the interval in seconds. Default is 10 seconds.
- --format <text|json|csv>: Specify the format. Default is text.
