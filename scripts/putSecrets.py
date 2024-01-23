#!/usr/bin/env python3

import os
import sys
import json
import boto3
from botocore.exceptions import ClientError


def create_secret(secret_string, domain_name, region_name):

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        response = client.create_secret(
            Name='cert_encoded',
            Description='Certificate chain and private key file for %s. Created by putSecrets.py.' % domain_name,
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


def edit_conf(path, file_name, domain_name):

    # Update the Nginx configuration with domain_name;
    try:    
        f = open("../configs/%s/%s" % (path, file_name), 'a+')
        f.seek(0)
        lines = f.readlines()
        for line in lines:
            if "DOMAIN_NAME" in line:
                line.replace("DOMAIN_NAME", domain_name)
                if line[0] == "#":
                    f.write(line[1:])
        f.close()
    except:
        raise

    #sed_cmd = "sed -i '' -e 's/DOMAIN_NAME/%s/g' ../configs/%s/%s" % (domain_name, path, file_name)

    # Update the Nginx configuration with domain_name;
    #try:    
    #    os.system(sed_cmd)
    #except:
    #    print("Unknown error (3).")
    #    sys.exit(3)




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

    create_secret(cert, args[2], args[3])
    print("TLS certificate successfully uploaded.")
    
    # Update Nginx & Docker configurations;
    
    conf = {
        "nginx" : "nginx.conf",
        "docker" : "compose.yml"
    }
    
    for i in conf:
        edit_conf(i, conf[i], args[2])
    print("Nginx & Docker configurations updated to include domain name.")


if __name__ == '__main__':
    main(sys.argv)
