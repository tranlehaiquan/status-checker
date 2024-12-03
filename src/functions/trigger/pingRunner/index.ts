import { pingToWebsite } from '../../../libs/pingToWebsite';

const handler = async (event: { url: string }, context) => {
  console.log("status-check called");
  console.log("event:", event);

  const result = await pingToWebsite(event.url);
  console.log("result:", result);

  return {
    statusCode: 200,
    body: JSON.stringify(result),
  };
};

export { handler };
