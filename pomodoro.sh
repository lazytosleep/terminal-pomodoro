#!/usr/bin/env bash

# Run for 1500 secs and then send break "
# sleep 1500 && notify-send "break"

# set -x
help() {

  echo "
    Options:
    start
    end
    details
    "
  exit 1
}

dt=$(date '+%d/%m/%Y')

createOrReadLastLine() {
  
  # if we don't have a file, start at zero
  if [ ! -f "/tmp/value.dat" ] ; then
    notify_end
    echo "${dt} 1" >> /tmp/value.dat
    # adding a new line as it seems sed last line ($) detects last line only if file ends with new line 
    # echo "" >> /tmp/value.dat
  # otherwise read the value from the file
  else
    # data=`sed -n '$p' /tmp/value.dat`
    # echo "data read ${data}"
    notify_end
    incrementValAndWrite
  fi  
}

incrementValAndWrite() {
  
  str=`sed -n '$p' /tmp/value.dat`
  echo "data read ${str}"
  IFS=' ' # space is set as delimiter
  read -ra ARR <<< "$str" # str is read into an array as tokens separated by IFS
  date=${ARR[0]}
  times=${ARR[1]} 

  # increment the value
  value=`expr ${times} + 1`

  # show it to the user
  echo "value: ${value}"

  # write to next line
  #echo "${value}" >> /tmp/value.dat
  # sed append was not woking if no line is present, so as a work around first add the line and if 
  # date matches, remove the last line
  sed -i '$ a '${dt}" "${value}'' /tmp/value.dat
  if [[ $dt = $date ]] ;
  then
    # below will get lines number in file
    n=`cat /tmp/value.dat |wc -l`
    n=`expr ${n} - 1`
    sed -i ''${n}' d' /tmp/value.dat
  fi
    
}

notify_end() {
  seconds=5; date1=$((`date +%s` + $seconds)); 
  while [ "$date1" -ge `date +%s` ]; do 
    echo -ne "$(date -u --date @$(($date1 - `date +%s` )) +%M:%S)\r"; 
done
  # sleep 5 && 
  # notify-send "break"
  zenity --warning --width=2000 --height=1000 --text 'Congratulations you have completed one pomodoro'
}

case "$1" in
  *)
    createOrReadLastLine
    ;;
  #*)
  #  help;;
esac


