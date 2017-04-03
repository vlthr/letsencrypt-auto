echo "Acquiring certs for $DOMAINS"

get_certs() {
    # Requires the following environment variables
    # - CERT_DOMAINS : comma separated list of domains
    # - EMAIL
    # - CONCAT
    # - args
    # Uses first entry in  in $CERT_DOMAINS as the name for the certificate

    local d=${CERT_DOMAINS//,*/} # read first domain
    echo "Getting certificate for $CERT_DOMAINS"
    certbot certonly --agree-tos --renew-by-default -n \
            --text --server https://acme-v01.api.letsencrypt.org/directory \
            --email $EMAIL -d $CERT_DOMAINS $args
    ec=$?
    echo "certbot exit code $ec"
    if [ $ec -eq 0 ]
    then
        if $CONCAT
        then
            # Some applications (like HAProxy) expect the cert to include both chain and private key concatenated in a single file
            cat /etc/letsencrypt/live/$d/fullchain.pem /etc/letsencrypt/live/$d/privkey.pem > /certs/$d.pem
        else
            # keep full chain and private key in separate files (e.g. for nginx and apache)
            cp /etc/letsencrypt/live/$d/fullchain.pem /certs/$d.pem
            cp /etc/letsencrypt/live/$d/privkey.pem /certs/$d.key
        fi
        echo "Certificate acquired for $CERT_DOMAINS! (/certs/$d)"
    else
        echo "Error: failed to acquire certificates for $CERT_DOMAINS. Check the logs for details."
    fi
}

args=""
args=" --standalone --standalone-supported-challenges http-01"

if $DEBUG
then
    args=$args" --debug"
fi

if $SEPARATE
then
    for d in $DOMAINS
    do
        CERT_DOMAINS=$d
        get_certs
    done
else
    CERT_DOMAINS=${DOMAINS// /,}
    get_certs
fi
