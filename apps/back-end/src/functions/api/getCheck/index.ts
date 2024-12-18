import { APIGatewayProxyResult } from "aws-lambda";
import getDynamoDBClient from "../../../libs/getDynamoDBClient";
import { ScanCommand, ScanCommandInput } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";

// GET /check
const handler = async (): Promise<APIGatewayProxyResult> => {
  const dynamodbClient = getDynamoDBClient();

  const params: ScanCommandInput = {
    ProjectionExpression: "id, #url, createdAt",
    ExpressionAttributeNames: {
      "#url": "url"
    },
    TableName: "JobCheck",
  };

  const command = new ScanCommand(params);
  const data = await dynamodbClient.send(command);
  const items = data.Items.map(i => unmarshall(i));

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(items),
  };
};

export { handler };
