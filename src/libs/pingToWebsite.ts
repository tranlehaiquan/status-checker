// ping to a website
export const pingToWebsite = async (url: string) => {
  let status;
  let responseTime;

  const start = Date.now();
  try {
    const result = await fetch(url);
    status = result.status;
  } catch (error) {
    console.error("error:", error);
  } finally {
    responseTime = Date.now() - start;
  }

  return {
    status,
    responseTime,
  }
};