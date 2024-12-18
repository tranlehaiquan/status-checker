import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import getDynamoDBClient from "../../../libs/getDynamoDBClient";
import { QueryCommand, QueryCommandInput } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";

// GET /check/{id}
const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const id = event.pathParameters?.id;
  const dynamodbClient = getDynamoDBClient();

  const params: QueryCommandInput = {
    ProjectionExpression: "id, #url",
    ExpressionAttributeNames: {
      "#url": "url",
    },
    TableName: "JobCheck",
    KeyConditionExpression: "id = :id", // Changed from FilterExpression
    ExpressionAttributeValues: {
      ":id": { S: id },
    },
  };

  const paramsResults: QueryCommandInput = {
    ProjectionExpression: "id, jobCheckId, #region, #status, responseTime",
    ExpressionAttributeNames: {
      "#region": "region",
      "#status": "status",
    },
    TableName: "JobCheckResponse",
    IndexName: "jobCheckId-index", // Add GSI name
    KeyConditionExpression: "jobCheckId = :jobCheckId",
    ExpressionAttributeValues: {
      ":jobCheckId": { S: id },
    },
  };

  const command = new QueryCommand(params);
  const [checkDetail, checkResults] = await Promise.all([
    dynamodbClient.send(command),
    dynamodbClient.send(new QueryCommand(paramsResults)),
  ]);
  const details = checkDetail.Items.map((i) => unmarshall(i));
  const results = checkResults.Items.map((i) => unmarshall(i));

  if (details.length === 0) {
    return {
      statusCode: 404,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ message: "Not found" }),
    };
  }

  const detail = details[0];

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      ...detail,
      results,
    }),
  };
};

export { handler };
