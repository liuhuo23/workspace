#!/bin/bash
# 检查CPU占用最高的进程，输出到日志
LOGFILE="/home/liuhuo/workspace/data/logs/monitor_cpu.log"
date > "$LOGFILE"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 >> "$LOGFILE"
echo "内存占用最高的前五个进程：" >> "$LOGFILE"
printf "%-8s %-20s %-8s %-15s %-15s\n" "PID" "COMMAND" "%MEM" "RSS(M) 实际内存" "VSZ(M) 虚拟内存" >> "$LOGFILE"
ps -eo pid,comm,%mem,rss,vsz --sort=-%mem | awk 'NR>1{printf "%-8s %-20s %-8s %-15.2f %-15.2f\n", $1, $2, $3, $4/1024, $5/1024}' | head -n 5 >> "$LOGFILE"
echo "-----------------------------" >> "$LOGFILE"
