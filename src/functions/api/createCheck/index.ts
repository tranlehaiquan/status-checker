import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
// this function using to create check status
// create a record in the database
// Push message { id: newRecord.id } to SNS
// SNS -> publish -> SQS -> lambda -> createCheckStatusResult

const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult>  => {
  console.log("create-check-status called");
  console.log("body:", event.body);

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "create-check-status called",
    }),
  };
};

export { handler };