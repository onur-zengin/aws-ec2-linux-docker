#!/usr/bin/env python3

import os
import sys
import json
import boto3
import subprocess
from botocore.exceptions import ClientError


def encode_pem(path, file_name):

    # OS command to encode the contents in base64 format (to protect file integrity during transfer)
    cmd = "openssl base64 -in %s/%s  | tr -d '\n'" % (path, file_name)

    try:   
        encoded = os.popen(cmd).read()
    except:
        raise
    else:
        if encoded == "":
            print("Error (1). *.pem files could not be read")
            sys.exit(3)
    
    return(encoded)


def create_secret(secret_string, domain_name, region_name):

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        response = client.create_secret(
            Name='cert-encoded',
            Description='Certificate chain and private key file for %s. Created by putSecrets.py.' % domain_name,
            SecretString = json.dumps(secret_string),
            ForceOverwriteReplicaSecret=True
        )
    except ClientError as e:
        if "ResourceExistsException" in str(e):
            print("A version of cert-encoded already exists. Trying to update..")
            response = client.put_secret_value(
                SecretId='cert-encoded',
                SecretString=json.dumps(secret_string),
                VersionStages=[
                    'AWSCURRENT',
                ]
            )
        else:
            print("ClientError", e)
            sys.exit(3)
    except:
        print("Unknown error (1).")
        sys.exit(3)


def edit_conf(path, file_name, domain_name):

    sed_cmd1 = "sed -i '' -e 's/DOMAIN_NAME/%s/g' ./configs/%s/%s" % (domain_name, path, file_name) 
    sed_cmd2 = "sed -i '' -e 's/#py#//g' ./configs/%s/%s" % (path, file_name)

    # Update the configuration files with domain_name;
    
    try:    
        os.system(sed_cmd1)
        os.system(sed_cmd2)
    except:
        raise
    #    print("Unknown error (3).")
    #    sys.exit(3)


def main(args):
    
    # Locate the certificate files;

    path =  args[1]

    if path[-1] == "/":
        path = path[:-1]

    cert = {
        "fullchain.pem_encoded" : encode_pem(path, "fullchain.pem"),
        "privkey.pem_encoded" : encode_pem(path, "privkey.pem")
    }

    # Make an API call to AWS Secrets Manager;

    create_secret(cert, args[2], args[3])
    print("TLS certificate successfully uploaded.")
    
    # Update Nginx & Docker configurations;
    
    conf = {
        "nginx" : "nginx.conf",
        "docker" : "compose.yml"
    }
    
    for i in conf:
        edit_conf(i, conf[i], args[2])
    print("Nginx & Docker configurations updated to include the domain name.")


if __name__ == '__main__':

    main(sys.argv)

    # Usage: ./putSecrets.py [path_to_pem_files] [domain_name] [region_name]