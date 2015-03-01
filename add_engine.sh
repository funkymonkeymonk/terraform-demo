
add_engine(){
  id=$1
  address=$2
  memory=$3
  cpu=$4

  echo "{
  \"id\": \"$id\",
  \"ssl_cert\": \"\",
  \"ssl_key\": \"\",
  \"ca_cert\": \"\",
  \"engine\": {
    \"id\": \"$address\",
    \"addr\": \"http://$address:2375\",
    \"cpus\": $cpu,
    \"memory\": $memory,
    \"labels\": [
      \"local\",
      \"dev\"
    ]
  }
}"

}


shipyard=$(fleetctl list-units -fields=unit,machine -no-legend | grep shipyard | cut -d '/' -f 2)
port=8080
username=admin
password=shipyard
auth=$(curl -s -d "{\"username\": \"$username\", \"password\": \"$password\"}" http://$shipyard:$port/auth/login)
header="X-Access-Token: $username:$(echo $auth | cut -d '"' -f 4)"

curl http://$shipyard:$port/api/engines -H "$header"

fleetctl list-machines -no-legend -full | \
while read i
do
  machineID=$(echo $i | cut -d ' ' -f 1)  
  ip=$(echo $i | cut -d ' ' -f 2)
  info=$(docker -H tcp://$ip:2375 info)
  
  mem=$(echo $info | cut -d ' ' -f 29)
  memSize=$(echo $info | cut -d ' ' -f 30)
  cpus=$(echo $info | cut -d ' ' -f 26)
  result=$(add_engine $machineID $ip $mem $cpus)

  curl -X POST -H "$header" http://$shipyard:$port/api/engines --data "$result"
done




