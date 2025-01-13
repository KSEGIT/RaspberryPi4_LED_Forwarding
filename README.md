# Raspberry Pi External LED Monitor Setup Guide

This guide explains how to set up external LEDs to mirror the Raspberry Pi's power and activity indicators.

## Prerequisites
- Raspberry Pi 4B
- Standard LEDs (2x)
- Appropriate resistors (220Ω-330Ω for 3.3V)
- Basic wiring components

## Step 1: Determine GPIO Offset

On Raspberry Pi, GPIO numbering might use an offset. Check your system's GPIO configuration:

```bash
# Check GPIO chip information
cat /sys/class/gpio/gpiochip*/ngpio
cat /sys/class/gpio/gpiochip*/label
```

Example output:
```
58
8
pinctrl-bcm2711
raspberrypi-exp-gpio
```

If you see `pinctrl-bcm2711`, your GPIO pins start from 512. Therefore:
- GPIO 18 becomes 530 (512 + 18)
- GPIO 19 becomes 531 (512 + 19)

## Step 2: Check LED Paths

Verify LED device paths:
```bash
ls -l /sys/class/leds/
```

You should see something like:
```
lrwxrwxrwx 1 root root 0 Jan  1  1970 ACT -> ../../devices/platform/leds/leds/ACT
lrwxrwxrwx 1 root root 0 Jan  1  1970 PWR -> ../../devices/platform/leds/leds/PWR
```

## Step 3: Create LED Monitor Script

Create `/opt/led-manage-script.sh`:

## Step 4: Set Up Systemd Service

1. Create service file `/etc/systemd/system/led-monitor.service`:

2. Set correct permissions:
```bash
sudo chmod 755 /opt/led-manage-script.sh
sudo chown root:root /opt/led-manage-script.sh
```

## Step 5: Enable and Start Service

```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable led-monitor

# Start the service
sudo systemctl start led-monitor
```

## Monitoring and Troubleshooting

Check service status:
```bash
# View service status
systemctl status led-monitor

# View service logs
journalctl -u led-monitor

# View last 50 lines of logs in real-time
journalctl -u led-monitor -n 50 -f

# Check for errors
journalctl -u led-monitor -p err
```

Service management commands:
```bash
# Stop service
systemctl stop led-monitor

# Start service
systemctl start led-monitor

# Restart service
systemctl restart led-monitor
```

## Circuit Diagram

Connect LEDs to their respective GPIO pins with appropriate resistors:
- Activity LED: GPIO 18 (physical pin 12)
- Power LED: GPIO 19 (physical pin 35)
- Use 220Ω-330Ω resistors for each LED
- Connect LED cathodes (negative/shorter leg) to ground

## Notes

- The script requires root privileges to access GPIO
- GPIO numbers might differ based on your Raspberry Pi model
- Verify LED paths in `/sys/class/leds/` as they might vary
- Always use appropriate resistors to protect LEDs
- Test the script manually before enabling the service
