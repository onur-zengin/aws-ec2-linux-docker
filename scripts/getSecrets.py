#!/usr/bin/env python3

import os
import sys
import json
import boto3
from botocore.exceptions import ClientError


def get_secret(secret_name, region_name):

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        #raise e
        print(e, "Falling back to self-signed certificate.")
        sys.exit(3)
    except:
        print("Unknown error (1). Falling back to self-signed certificate.")
        sys.exit(3)

    # Decrypts secret using the associated KMS key.
    secret = get_secret_value_response['SecretString']

    return secret


def decode(row):

    # Making OS call to decode the b64_encoded secrets 
    cmd = "base64 -di %s > %s" % (row, row.removesuffix('_encoded'))
    
    try:
        f = open(row, "w")
        f.write(secrets_dct[row])
        f.close()    
        os.system(cmd)
    except:
        print("Unknown error (2). Falling back to self-signed certificate.")
        sys.exit(3)


# Make an API call to AWS Secrets Manager using the command-line arguments (usage: ./getSecrets.py [secret_name] [region_name])
secret      = get_secret(sys.argv[1], sys.argv[2])
secrets_dct = json.loads(secret)

for row in secrets_dct:
    decode(row)

# Cleanup & exit(0)
os.system('rm *.pem_encoded')
print("TLS certificate successfully imported.")
