import os, sys, getopt
import pymongo
from pymongo_auth_aws.auth import aws_temp_credentials
from pymongo import MongoClient
from urllib.parse import quote_plus

def main(argv):
    creds = aws_temp_credentials()
    aws_access_key_id = quote_plus(creds.username)
    aws_secret_access_key = quote_plus(creds.password)
    aws_session_token = quote_plus(creds.token)

    with open('atlas-connection-string.txt', 'r') as file:
        atlas_host = file.readline().strip("\n").strip('"').replace('mongodb+srv://', '')

    atlas_python_connection_string = "mongodb+srv://{}:{}@{}/?authSource=%24external&authMechanism=MONGODB-AWS"\
        "&retryWrites=true&w=majority&authMechanismProperties=AWS_SESSION_TOKEN:{}".format(aws_access_key_id, aws_secret_access_key, atlas_host, aws_session_token)
    
    atlas_mongosh_connection_string = "\"mongodb+srv://{}/?"\
    "authSource=%24external&authMechanism=MONGODB-AWS\" "\
    "--apiVersion 1 --username {} --password {} --awsIamSessionToken {}".format(atlas_host, creds.username, creds.password, creds.token)
    
    atlas_mongosh_command = "mongosh {}".format(atlas_mongosh_connection_string)

    try:
        opts, args = getopt.getopt(sys.argv[1:], "mth", ["test", "mongosh-command", "help"])
    except getopt.GetoptError as err:
        print(err)
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-t", "--test"):
            client = pymongo.MongoClient(atlas_python_connection_string)
            for db in client.list_databases():
                print(db)
        elif opt in ("-m", "--mongosh-command"):
            print(atlas_mongosh_command)

def usage():
    print('client.py\n\t-m/--mongosh-command (print mongosh command to connect to Atlas)\n\t-t/--test (test connection to Atlas)')

if __name__ == "__main__":
   main(sys.argv[1:])