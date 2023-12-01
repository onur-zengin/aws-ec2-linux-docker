#!/usr/bin/env python3

import os
import sys
import json
import boto3
from botocore.exceptions import ClientError


# OS commands to handle cleanup & exit, or fallback if certs not found.
cleanup     = "rm *.pem_encoded"
fallback    = "mv ../conf.d/nginx_http.conf ../conf.d/nginx.conf"


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
        print(e, "Falling back to non-secure HTTP URL.")
        os.system(fallback)
        sys.exit(3)
    except:
        print("Unknown error (2). Falling back to non-secure HTTP URL.")
        os.system(fallback)
        sys.exit(3)

    # Decrypts secret using the associated KMS key.
    secret = get_secret_value_response['SecretString']

    return secret


def decoder(secrets_dct):
    
    for row in secrets_dct:
        # OS command to decode the b64_encoded secrets (once pulled from AWS Secrets Manager)
        decode = "base64 -di %s > %s" % (row, row.removesuffix('_encoded'))
        try:
            f = open(row, "w")
            f.write(secrets_dct[row])
            f.close()    
            os.system(decode)
        except:
            print("Unknown error (2). Falling back to non-secure HTTP URL.")
            os.system(fallback)
            sys.exit(3)


def main(args):

    # Make an API call to AWS Secrets Manager using the command-line arguments (usage: ./getSecrets.py [secret_name] [region_name])
    secret      = get_secret(args[1], args[2])
    secrets_dct = json.loads(secret)

    decoder(secrets_dct)

    # Cleanup & exit(0)
    os.system(cleanup)
    print("TLS certificate successfully imported.")


if __name__ == '__main__':
    main(sys.argv)




