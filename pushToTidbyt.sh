#!/bin/sh

/usr/local/bin/pixlet render <YOUR_PATH>/ioBroker_Home.star
/usr/local/bin/pixlet push --api-token <YOUR_API_KEY_HERE> <YOUR_DEVICE_KEY_HERE> <YOUR_PATH>/ioBroker_Home.webp
