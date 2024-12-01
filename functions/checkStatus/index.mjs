const handler = async (event, context) => {
  console.log("status-check called");
  console.log("event:", event);
  console.log("context:", context);

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "status-check called",
    }),
  };
};

export { handler };
