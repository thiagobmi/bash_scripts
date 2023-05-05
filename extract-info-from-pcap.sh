#!/bin/bash

tshark -r intro-wireshark-trace1.pcap -T fields -E header=y -e ip.src -e ip.len -e _ws.col.Protocol -E separator=, >exit.txt

tshark -r intro-wireshark-trace1.pcap -T fields  -Y http -E header=y -e ip.src -e ip.len -e _ws.col.Protocol -e ip.dst >httpfiles.txt

awk -F ',' '{print $1}' exit.txt >tmp.txt

awk 'NF' tmp.txt >srcIP.txt

rm tmp.txt

awk -F ',' '{print $2}' exit.txt >tmp.txt

awk 'NF' tmp.txt >sizePkts.txt

rm tmp.txt

awk -F ',' '{print $3}' exit.txt >tmp.txt

awk 'NF' tmp.txt >protocols.txt

rm tmp.txt

echo "$(tail -n +2 srcIP.txt)" >srcIP.txt
echo "$(tail -n +2 sizePkts.txt)" >sizePkts.txt
echo "$(tail -n +2 protocols.txt)" >protocols.txt

IPArr=()
sizeArr=()
protocols=()

while IFS= read -r line; do
	IPArr+=($line)

done <srcIP.txt

unique_IPs=($(echo "${IPArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

countIPs=()

for ((i=0;i < ${#unique_IPs[*]};i++));do
	countIPs[i]=0
done 

for ((i=0;i<${#unique_IPs[*]};i++)); do
	for ip2 in ${IPArr[*]}; do
		if [[ $ip2 =~ ${unique_IPs[i]} ]]; then
			((countIPs[i]++))
		fi
	done
done

saveMaxIP=0
saveMaxIPIndex=0

for ((i=0;i < ${#unique_IPs[*]};i++));do
	if (( ${countIPs[i]} > $saveMaxIP )); then
		saveMaxIP=$countIPs;
		saveMaxIPIndex=$i;
	fi; 
done 


while IFS= read -r line; do
	protocols+=($line)

done <protocols.txt

unique_protocols=($(echo "${protocols[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

count=0

while IFS= read -r line;do
	sizeArr+=($line)
	((count++))
done < sizePkts.txt

sum=$(IFS=+; echo "$((${sizeArr[*]}))")

max=${sizeArr[0]}
min=${sizeArr[0]}

for n in "${sizeArr[@]}" ; do
    ((n > max)) && max=$n
    ((n < min)) && min=$n
done


printf '\n\n'
printf '1) Protocolos presentes no arquivo são os seguintes:\n'
echo ${unique_protocols[@]}
printf '\n'
printf '2) Quantidade de pacotes:\n'
echo ${count}
printf '\n'
printf "3) O IP que mais mandou pacotes foi:\n"
echo "${unique_IPs[saveMaxIPIndex]} (${countIPs[saveMaxIPIndex]} pacotes)"
printf '\n\n'
printf "4) As trocas de dados utilizando o protocolo HTTP foram as seguintes:\n"
cat httpfiles.txt
printf '\n\n'
printf '5) o Tamanho médio dos pacotes é:\n'
echo "$(($sum/$count))"
printf '\n'
printf '6) O tamanho do maior pacote é:\n'
echo $max
printf '\n'
printf '7) O tamanho do menor pacote é:\n'
echo $min
printf '\n'
echo 'Fim xd'

rm srcIP.txt
rm sizePkts.txt
rm protocols.txt
rm httpfiles.txt
rm exit.txt
