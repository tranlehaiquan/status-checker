// this function using to create check status
// create a record in the database
// Push message { id: newRecord.id } to SNS
// SNS -> publish -> SQS -> lambda -> createCheckStatusResult

const handler = async (event, context) => {
  console.log("create-check-status called");
  console.log("event:", event);
  console.log("context:", context);

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "create-check-status called",
    }),
  };
};

export { handler };