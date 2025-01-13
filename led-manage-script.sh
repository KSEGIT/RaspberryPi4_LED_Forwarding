#!/bin/bash

# Configuration with correct GPIO offsets
ACTIVITY_LED_GPIO="530"  # GPIO 18 -> 512 + 18
POWER_LED_GPIO="531"    # GPIO 19 -> 512 + 19

# LED paths from your system
LED_ACTIVITY="/sys/class/leds/ACT/brightness"
PWR_LED="/sys/class/leds/PWR/brightness"

# Setup GPIOs
for GPIO in "$ACTIVITY_LED_GPIO" "$POWER_LED_GPIO"; do
    if ! [ -e "/sys/class/gpio/gpio${GPIO}" ]; then
        echo "$GPIO" > /sys/class/gpio/export || {
            echo "Failed to export GPIO ${GPIO}"
            exit 1
        }
    fi
    echo "out" > "/sys/class/gpio/gpio${GPIO}/direction" || {
        echo "Failed to set GPIO ${GPIO} direction"
        exit 1
    }
done

# Function to write to LED
write_led() {
    if [ -e "/sys/class/gpio/gpio${1}/value" ]; then
        echo "$2" > "/sys/class/gpio/gpio${1}/value"
    else
        echo "GPIO ${1} not available"
    fi
}

# Function to read LED state safely
read_led() {
    if [ -e "$1" ]; then
        cat "$1" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    write_led "$ACTIVITY_LED_GPIO" 0
    write_led "$POWER_LED_GPIO" 0
    for GPIO in "$ACTIVITY_LED_GPIO" "$POWER_LED_GPIO"; do
        [ -e "/sys/class/gpio/gpio${GPIO}" ] && echo "$GPIO" > /sys/class/gpio/unexport
    done
    exit 0
}

# Set cleanup on script exit
trap cleanup EXIT INT TERM

echo "Starting LED monitor..."
echo "Press Ctrl+C to exit"

# Main loop with error handling
while true; do
    # Mirror Activity LED
    act_state=$(read_led "$LED_ACTIVITY")
    write_led "$ACTIVITY_LED_GPIO" "$act_state"

    # Mirror Power LED
    pwr_state=$(read_led "$PWR_LED")
    write_led "$POWER_LED_GPIO" "$pwr_state"

    sleep 0.1
done
