import { pingToWebsite } from '../../libs/pingToWebsite';
// this function will ping to the website target
// and create new Record in the database { id: newRecord.id, checkStatus: ref.checkStatus, result: string }
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
