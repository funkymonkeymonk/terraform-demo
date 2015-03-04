# This is a general-purpose function to ask Yes/No questions in Bash, either
# with or without a default answer. It keeps repeating the question until it
# gets a valid answer.
 
ask() {
    # http://djm.me/ask
    while true; do
 
        if [ "${2:-}" = "Y" ]; then
            prompt="y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi
 
        # Ask the question
        read -p "$1 [$prompt] " REPLY
 
        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi
 
        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
 
    done
}
 



pushd tf > /dev/null
terraform plan
if ask "Would you like to make the above changes?"; then
    terraform apply
fi

servers=$(terraform output coreos_public_ip_addresses)
address=$(echo $servers | cut -d ' ' -f 1)
port=4001

popd > /dev/null

echo "Waiting for server to come online $address"
code="200"
until [[ "$response" == "$code" ]]
do
    response=$(curl --write-out %{http_code} --silent --output /dev/null http://$address:$port/v1/machines)
    echo "Waiting for response code [$code] got [$response]"
    sleep 1
done


