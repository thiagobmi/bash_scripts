#!/bin/bash

myIP=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')

nmap -n -sn $myIP/24 -oG - | awk '/Up$/{print $2}' >iplist.txt

while IFS= read -r line; do
    if [ $line != $myIP ]; then
        IPlist+=($line)
    fi

done <iplist.txt

for ip in "${IPlist[@]}"; do
    ping -c 1 $ip | grep -o 'time=.*' >>pingtimes.txt

done

grep -o 'time=.*' pingtimes.txt | cut -c 6-9 >timelist.txt

while IFS= read -r line; do
    timeList+=($line)

done <timelist.txt

for ((i = 0; i < ${#IPlist[*]}; i++)); do
    echo "${IPlist[i]}     ${timeList[i]}"
done

indexmin=0
indexmax=0

printf "%s\n" "${timeList[@]}" | sort -rn | tail -n1 >minEmax.txt
printf "%s\n" "${timeList[@]}" | sort -rn | head -n1 >>minEmax.txt

min=$(cat minEmax.txt | head -n1)
max=$(cat minEmax.txt | tail -n1)

for ((i = 0; i < ${#IPlist[*]}; i++)); do
    if [[ "${timeList[i]}" == "$min" ]]; then
        indexmin=$i
    fi
    if [[ "${timeList[i]}" == "$max" ]]; then
        indexmax=$i
    fi
done

echo "O IP com menor latência é ${IPlist[indexmin]} ($min ms)"
echo "O IP com maior latência é ${IPlist[indexmax]} ($max ms)"


rm minEmax.txt
rm iplist.txt
rm pingtimes.txt
rm timelist.txt
