cat /var/log/auth.log* | grep Failed | grep 'invalid user' | awk -F ' ' '{print $11,$13}' > ./user-and-IP.txt
cat user-and-IP.txt | awk '{print $2}' > only-ip.txt
cat user-and-IP.txt | awk '{print $1}' > only-user.txt

while IFS= read -r line;
        do lista+=($line)
	done < only-ip.txt

while IFS= read -r line;
        do users+=($line)
        done < only-user.txt

count=0;

for i in "${lista[@]}"; do
	echo "$i     ${users[$count]}     `geoiplookup $i | cut -d ' ' -f 4-5`"

	((count=count + 1))
done

rm only-ip.txt
rm only-user.txt
rm user-and-IP.txt
