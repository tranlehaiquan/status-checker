import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import getAWSCredential from "./getAWSCredential";

const getDynamoDBClient = () => {
  const credentials = getAWSCredential();
  const dynamoDBClient = new DynamoDBClient({
    credentials,
    region: 'ap-southeast-1',
  });

  return dynamoDBClient;
}

export default getDynamoDBClient;