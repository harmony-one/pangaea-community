while :
    do
rm test.txt
curl -s https://harmony.one/pga/network | sed -n  '/ONLINE/,/OFFLINE/p' >test.txt
sleep 5
rm wallets.txt
grep 'one.*' test.txt >wallets.txt
sleep 86400

done