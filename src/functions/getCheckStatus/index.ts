const handler = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Check status',
    }),
  }
};

export { handler };