#!/bin/bash

OUTPUT_DIR="$HOME/simpletracker/output"
CAPTURE_FORMAT="png"
DELAY_SECS=4

mkdir -p ${OUTPUT_DIR}

while True
do

  current_date=$(date "+%Y-%m-%d")
  current_time=$(date "+%H%M%S")

  today_output=$OUTPUT_DIR/$current_date
  mkdir -p $today_output

  applescript_output=$(osascript -e 'tell application "System Events" to tell (first process whose frontmost is true) to return {name, name of front window}')

  front_app=$(echo $applescript_output | awk -F',' '{print $1}')

  if [ "${front_app}" == "Safari" ]; then
    safari_output=$(osascript -e 'tell application "Safari" to return {name, url} of front document')
    front_window=$(echo $safari_output | awk -F',' '{printf $1 ($2)}')
  else
    front_window=$(echo $applescript_output | awk -F',' '{print $2}')
  fi

  sanitised_front_window=$(echo ${front_window} | sed 's/[^a-zA-Z0-9_+@-]/_/g')

  capture_filename=$(echo ${current_date}T${current_time}_${front_app}_${sanitised_front_window} | cut -c -128).${CAPTURE_FORMAT}
  capture_filepath=${today_output}/${capture_filename}

  screencapture -t $CAPTURE_FORMAT -x -C -D 1 "${capture_filepath}"

  echo "${current_date}T${current_time}, $front_app, $front_window, ${capture_filepath}" >> "$today_output/$current_date.csv"

  sleep $DELAY_SECS

done
