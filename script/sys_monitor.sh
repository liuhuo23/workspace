#!/bin/bash
# 监控每个CPU核心的使用率、内存、温度、风扇转速
LOGFILE="/home/liuhuo/workspace/data/logs/sys_monitor.log"
date >  "$LOGFILE"

# 1. 每个CPU核心使用率
mpstat -P ALL 1 1 | grep -E "^Average|^平均" >> "$LOGFILE"

# 2. 内存使用情况
free -h >> "$LOGFILE"

# 3. CPU温度（需lm-sensors支持）
if command -v sensors &>/dev/null; then
    sensors >> "$LOGFILE"
else
    echo "sensors命令未安装，无法获取温度" >> "$LOGFILE"
fi

# 4. 风扇转速（需lm-sensors支持）
if command -v sensors &>/dev/null; then
    sensors | grep -i fan >> "$LOGFILE"
else
    echo "sensors命令未安装，无法获取风扇转速" >> "$LOGFILE"
fi

echo "-----------------------------" >> "$LOGFILE"

# 获取 AMD CPU 温度（k10temp-pci-00c3）
if command -v sensors &>/dev/null; then
    cpu_temp=$(sensors | awk '/k10temp-pci-00c3/,/^$/ {if ($1=="Tctl:") print $2}')
    echo "AMD CPU 温度 (k10temp-pci-00c3): $cpu_temp" >> "$LOGFILE"
else
    echo "sensors命令未安装，无法获取CPU温度" >> "$LOGFILE"
fi

# 检查系统是否卡死，满足任一条件则重启
CPU_THRESHOLD=95    # 平均CPU使用率阈值（百分比）
MEM_THRESHOLD=95    # 内存使用率阈值（百分比）
TEMP_THRESHOLD=90   # CPU温度阈值（摄氏度）



# 获取平均CPU使用率（用top命令更通用）
if command -v top &>/dev/null; then
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    cpu_usage_int=${cpu_usage%.*}
else
    cpu_usage_int=0
fi



# 获取内存使用率
if command -v free &>/dev/null; then
    mem_total=$(free | awk '/Mem:|内存：/ {print $2}')
    mem_used=$(free | awk '/Mem:|内存：/ {print $3}')
    if [ -n "$mem_total" ] && [ "$mem_total" -ne 0 ]; then
        mem_usage=$(awk "BEGIN{printf \"%.0f\", $mem_used*100/$mem_total}")
    else
        mem_usage=0
    fi
else
    mem_usage=0
fi


# 获取AMD CPU温度（k10temp-pci-00c3）
if command -v sensors &>/dev/null; then
    cpu_temp=$(sensors | awk '/k10temp-pci-00c3/,/^$/ {if ($1=="Tctl:") print $2}' | head -n1)
    cpu_temp=${cpu_temp//+}  # 去掉+号
    cpu_temp=${cpu_temp/°C/} # 去掉°C
    if ! [[ "$cpu_temp" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        cpu_temp=0
    fi
else
    cpu_temp=0
fi


# 汇总输出所有获取到的指标
echo "================= 指标汇总 =================" >> "$LOGFILE"
echo "平均CPU使用率: ${cpu_usage_int}%" >> "$LOGFILE"
echo "内存使用率: ${mem_usage}%" >> "$LOGFILE"
echo "CPU温度(Core 0): $cpu_temp°C" >> "$LOGFILE"
if command -v sensors &>/dev/null; then
    amd_cpu_temp=$(sensors | awk '/k10temp-pci-00c3/,/^$/ {if ($1=="Tctl:") print $2}')
    echo "AMD CPU温度(k10temp-pci-00c3): $amd_cpu_temp" >> "$LOGFILE"
fi
echo "=============================================" >> "$LOGFILE"

# 判断是否需要重启（温度取整数部分比较）
cpu_temp_int=${cpu_temp%.*}
if [ "$cpu_usage_int" -ge "$CPU_THRESHOLD" ] || [ "$mem_usage" -ge "$MEM_THRESHOLD" ] || [ "$cpu_temp_int" -ge "$TEMP_THRESHOLD" ]; then
    echo "$(date): 系统异常，自动重启！CPU:${cpu_usage_int}% MEM:${mem_usage}% TEMP:$cpu_temp°C" >> "$LOGFILE"
    /sbin/reboot
fi
