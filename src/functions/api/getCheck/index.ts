import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import getDynamoDBClient from "../../../libs/getDynamoDBClient";
import { ScanCommand } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";

// GET /check/{id}
const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  // log param id
  console.log("get-check-status called");
  console.log("event:", event);
  const dynamodbClient = getDynamoDBClient();

  const params = {
    ProjectionExpression: "id",
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
