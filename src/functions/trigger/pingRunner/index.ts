import { pingToWebsite } from "../../../libs/pingToWebsite";

const handler = async (
  event: {
    Records: {
      messageId: string;
      receiptHandle: string;
      body: string;
    }[];
  },
  context
) => {
  const Records = event.Records;

  const results: any[] = [];

  await Promise.all(
    Records.map(async (record) => {
      const url = JSON.parse(record.body).url;
      const result = await pingToWebsite(url);
      console.log("result:", result);
      results.push(result);
    })
  );

  return {
    statusCode: 200,
    body: JSON.stringify(results),
  };
};

export { handler };
