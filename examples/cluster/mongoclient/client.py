import sys, argparse
import pymongo
from pymongo_auth_aws.auth import aws_temp_credentials
from pymongo import MongoClient
from urllib.parse import quote_plus

def main(argv):
    creds = aws_temp_credentials()
    aws_access_key_id = quote_plus(creds.username)
    aws_secret_access_key = quote_plus(creds.password)
    aws_session_token = quote_plus(creds.token)

    parser = argparse.ArgumentParser()
    parser.add_argument("--host", type=str, required=True, help="MongoDB Atlas host")
    parser.add_argument("--test", action="store_true", help="Test the connection")
    parser.add_argument("-m", "--mongosh", action="store_true", help="Print mongosh command to connect")
    args = parser.parse_args()

    atlas_host = args.host
    atlas_python_connection_string = generate_python_connection_string(atlas_host, aws_access_key_id, aws_secret_access_key, aws_session_token)
    atlas_mongosh_connection_string = generate_mongosh_connection_string(atlas_host, creds.username, creds.password, creds.token)

    if args.test:
        client = pymongo.MongoClient(atlas_python_connection_string)
        for db in client.list_databases():
            print(db)
    if args.mongosh:
        print("mongosh {}".format(atlas_mongosh_connection_string))
            
def generate_python_connection_string(atlas_host, aws_access_key_id, aws_secret_access_key, aws_session_token):
    return "mongodb+srv://{}:{}@{}/?authSource=%24external&authMechanism=MONGODB-AWS"\
        "&retryWrites=true&w=majority&authMechanismProperties=AWS_SESSION_TOKEN:{}".format(aws_access_key_id, aws_secret_access_key, atlas_host, aws_session_token)

def generate_mongosh_connection_string(atlas_host, username, password, token):
    return "\"mongodb+srv://{}/?"\
    "authSource=%24external&authMechanism=MONGODB-AWS\" "\
    "--apiVersion 1 --username {} --password {} --awsIamSessionToken {}".format(atlas_host, username, password, token)

if __name__ == "__main__":
   main(sys.argv[1:])