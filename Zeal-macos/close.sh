#!/bin/bash
echo "Closing Zeal..."
killall Zeal 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Zeal closed."
else
    echo "Zeal is not running."
fi
