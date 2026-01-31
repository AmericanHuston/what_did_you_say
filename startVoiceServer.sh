#!/usr/bin/bash
python3 ./voice_server_recognizer.py || python ./voice_server_recognizer.py
if [ $? -eq 0 ]; then
    exit 0
fi
echo "Error running voice server. Check if Python 3 is installed along with Flask."
echo "You can install Flask on a system with python with the following command: "
echo "pip install Flask"