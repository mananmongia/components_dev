defectdojo()
{
    mkdir ./defectdojo &&
    cd defectdojo &&
    openssl req -x509 -nodes -newkey rsa:4096 -keyout ssl.pem -out ssl.crt -sha256 -days 365 -subj '/CN=closetdojo.strangled.net' -out ssl.crt &&
    cd ../
    echo "********Please copy the defectdojo folder into your secrets archive (secrets.gpg)********"
}

octant()
{
    mkdir ./octant &&
    cd octant &&
    openssl req -x509 -nodes -newkey rsa:4096 -keyout ssl.pem -out ssl.crt -sha256 -days 365 -subj "/C=IN/ST=Karnataka/L=Bengaluru/O=PwC/OU=DevSecOps/CN=closetoctant.strangled.net" &&
    cd ../
    echo "********Please copy the octant folder into your secrets archive (secrets.gpg)********"
}

if [[ $1 == "dd" ]]
then
    defectdojo
elif [[ $1 == "oc" ]]
then
    octant
elif [[ $1 == "all" ]]
then
    defectdojo &&
    octant &&
    echo "********Please copy the defectdojo and octant folders into your secrets archive (secrets.gpg)********"
else
    echo "+++++Wrong Choice !!!!!!! Run again+++++"
fi