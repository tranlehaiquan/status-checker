import { pingToWebsite } from "../../../libs/pingToWebsite";
import {
  SQSEvent,
  Context,
} from 'aws-lambda';
import getDynamoDBClient from "../../../libs/getDynamoDBClient";
import { marshall } from "@aws-sdk/util-dynamodb";
import { PutItemCommand } from "@aws-sdk/client-dynamodb";
import { v4 as uuid } from 'uuid';

const handler = async (
  event: SQSEvent,
  context: Context
) => {
  const Records = event.Records;
  const dynamodbClient = getDynamoDBClient();

  const results = await Promise.all(
    Records.map(async (record) => {
      const payload = JSON.parse(record.body);
      const url = payload.url;
      const result = await pingToWebsite(url);
      const resultRecord = {
        id: uuid(),
        jobCheckId: payload.id,
        region: process.env.AWS_REGION,
        createAt: new Date().toISOString(),
        ...result,
      }

      await dynamodbClient.send(
        new PutItemCommand({
          Item: marshall(resultRecord),
          TableName: "JobCheckResponse",
        })
      );
      
      return resultRecord;
    })
  );

  return {
    statusCode: 200,
    body: JSON.stringify(results),
  };
};

export { handler };
