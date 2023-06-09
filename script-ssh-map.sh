cat /var/log/auth.log* | grep 'Failed password for root' | awk -F ' ' '{print $11}' | sed '/Failed/d' > ./root_tries.txt

cat /var/log/auth.log* | grep Failed | grep 'invalid user' | awk -F ' ' '{print $11,$13}' > ./user-and-IP.txt #
cat user-and-IP.txt | awk '{print $2}' > only-ip.txt #
cat user-and-IP.txt | awk '{print $1}' > only-user.txt #

while IFS= read -r line; #
        do newArr+=($line) #
done < only-ip.txt #

while IFS= read -r line;
        do newArr+=($line)
done < root_tries.txt


#echo "${newArr[@]}" | tr ' ' '\n'

#for i in "${newArr[@]}"; do
#       echo "    $i        `geoiplookup $i | cut -d ' ' -f 4-5`"
#done | sort |  uniq -c | sort -nr

for i in "${newArr[@]}"; do
        echo "`geoiplookup $i | cut -d ' ' -f 5`"
done | sort | uniq -c | sort -nr
