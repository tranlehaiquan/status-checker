import { pingToWebsite } from "../../../libs/pingToWebsite";
import {
  SQSEvent,
  Context,
} from 'aws-lambda';
import getDynamoDBClient from "../../../libs/getDynamoDBClient";
import { marshall } from "@aws-sdk/util-dynamodb";
import { PutItemCommand } from "@aws-sdk/client-dynamodb";

const handler = async (
  event: SQSEvent,
  context: Context
) => {
  const Records = event.Records;
  const results: any[] = [];
  const dynamodbClient = getDynamoDBClient();

  await Promise.all(
    Records.map(async (record) => {
      const payload = JSON.parse(record.body);
      const url = payload.url;
      const result = await pingToWebsite(url);
      const resultRecord = {
        id: payload.id,
        checkId: payload.id,
        region: process.env.AWS_REGION,
        ...result,
      }

      await dynamodbClient.send(
        new PutItemCommand({
          Item: marshall(resultRecord),
          TableName: "JobCheckResponse",
        })
      );
      
      results.push(resultRecord);

      return resultRecord;
    })
  );

  return {
    statusCode: 200,
    body: JSON.stringify(results),
  };
};

export { handler };
