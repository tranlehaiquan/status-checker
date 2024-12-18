import {
  APIGatewayProxyEvent,
  APIGatewayProxyResult,
  APIGatewayEventRequestContext,
} from "aws-lambda";
import { PublishCommand, SNSClient } from "@aws-sdk/client-sns";
import { marshall } from "@aws-sdk/util-dynamodb";
import { v4 as uuid } from "uuid";

import getDynamoDBClient from "../../../libs/getDynamoDBClient";
import getAWSCredential from "../../../libs/getAWSCredential";
import { PutItemCommand } from "@aws-sdk/client-dynamodb";

// this function using to create check status
// create a record in the database
// Push message { id: newRecord.id } to SNS
// SNS -> publish -> SQS -> lambda -> createCheckStatusResult
const getSNSClient = () => {
  const credentials = getAWSCredential();
  const snsClient = new SNSClient({
    credentials,
  });

  return snsClient;
};

const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  const body = event.body;
  const url = JSON.parse(body).url;
  const urlInstance = new URL(url);
  const dynamodbClient = getDynamoDBClient();
  const snsClient = getSNSClient();
  const record = {
    id: uuid(),
    url: urlInstance.origin,
  };
  const message = new PublishCommand({
    Message: JSON.stringify(record),
    TopicArn: process.env.SNS_TOPIC_ARN,
  });

  const paramsDB = {
    Item: marshall(record),
    TableName: "JobCheck",
  };

  try {
    await snsClient.send(message);
    await dynamodbClient.send(new PutItemCommand(paramsDB));

    return {
      statusCode: 200,
      body: JSON.stringify(record),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "create-check-status failed",
      }),
    };
  }
};

export { handler };
