import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import getAWSCredential from "./getAWSCredential";

const getDynamoDBClient = () => {
  const credentials = getAWSCredential();
  const dynamoDBClient = new DynamoDBClient({
    credentials,
  });

  return dynamoDBClient;
}

export default getDynamoDBClient;