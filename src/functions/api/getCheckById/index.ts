import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import getDynamoDBClient from "../../../libs/getDynamoDBClient";
import { QueryCommand, ScanCommandInput } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";

// GET /check/{id}
const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const id = event.pathParameters?.id;
  const dynamodbClient = getDynamoDBClient();

  const params: ScanCommandInput = {
    ProjectionExpression: "id, #url",
    ExpressionAttributeNames: {
      "#url": "url"
    },
    TableName: "JobCheck",
    FilterExpression: "id = :id",
    ExpressionAttributeValues: {
      ":id": { S: id },
    },
  };

  const command = new QueryCommand(params);
  const data = await dynamodbClient.send(command);
  const items = data.Items.map(i => unmarshall(i));

  if(items.length === 0) {
    return {
      statusCode: 404,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ message: "Not found" }),
    };
  }

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(items[0]),
  };
};

export { handler };
