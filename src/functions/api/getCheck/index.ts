import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

// GET /check/{id}
const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult>  => {
  // log param id
  console.log("get-check-status called");
  console.log("event:", event);

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Check status',
    }),
  }
};

export { handler };