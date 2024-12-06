import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { PublishCommand, SNSClient } from "@aws-sdk/client-sns";
// this function using to create check status
// create a record in the database
// Push message { id: newRecord.id } to SNS
// SNS -> publish -> SQS -> lambda -> createCheckStatusResult

const getSNSClient = () => {
  const isDev = process.env.NODE_ENV === "development";

  const credentials = isDev
    ? {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      }
    : null;

  const snsClient = new SNSClient({
    credentials,
  });

  return snsClient;
};

const handler = async (
  event: APIGatewayProxyEvent,
  context: any
): Promise<APIGatewayProxyResult> => {
  console.log("event", event);
  console.log("env", process.env);
  console.log("context", context);

  const snsClient = getSNSClient();
  const message = new PublishCommand({
    Message: JSON.stringify({ url: "https://google.com.vn" }),
    TopicArn: process.env.SNS_TOPIC_ARN,
  });

  try {
    await snsClient.send(message);
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "create-check-status called",
      }),
    };
  } catch (error) {
    console.error("error", error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "create-check-status failed",
      }),
    };
  }
};

export { handler };
