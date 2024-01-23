#!/usr/bin/env python3

import os
import sys
import json
import boto3
from botocore.exceptions import ClientError


def create_secret(secret_string, region_name):

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        response = client.create_secret(
            Name='cert_encoded',
            Description='Certificate chain and private key file. Created by putSecrets.py for vmon.',
            SecretString = json.dumps(secret_string),
            ForceOverwriteReplicaSecret=True
        )
    except ClientError as e:
        if "ResourceExistsException" in str(e):
            print("A version of cert_encoded already exists. Trying to update..")
            response = client.put_secret_value(
                SecretId='cert_encoded',
                SecretString=json.dumps(secret_string),
                VersionStages=[
                    'latest',
                ]
            )
        else:
            print("ClientError", e)
            sys.exit(3)
    except:
        print("Unknown error (1).")
        sys.exit(3)


def update_nginx(domain_name):

    sed_cmd = "sed -i '' -e 's/DOMAIN_NAME/%s/g' ../configs/nginx/nginx.conf" % (domain_name)

    # Update the Nginx configuration with domain_name;
    try:    
        os.system(sed_cmd)
    except:
        print("Unknown error (3).")
        os.system(fallback)
        sys.exit(3)


def encode_pem(path, file_name):

    try:   
        # OS command to encode the contents in base64 format (to protect file integrity during transfer)
        encoded = os.popen("openssl base64 -in %s/%s  | tr -d '\n'" % (path, file_name)).read()
    except:
        print("Unknown error (1). *.pem files could not be read")
        sys.exit(3)
    finally:
        return(encoded)


def main(args):
    
    # Usage: ./putSecrets.py [path_to_pem_files] [domain_name] [region_name]
    
    # Locate the certificate files;

    path =  args[1]

    if path[-1] == "/":
        path = path[:-1]

    cert = {
        "fullchain" : encode_pem(path, "fullchain.pem"),
        "privkey" : encode_pem(path, "privkey.pem")
    }

    # Make an API call to AWS Secrets Manager;

    create_secret(cert, args[3])
    print("TLS certificate successfully uploaded.")
    
    # Update Nginx configuration;
    
    update_nginx(args[2])
    print("Nginx configuration updated.")


if __name__ == '__main__':
    main(sys.argv)
