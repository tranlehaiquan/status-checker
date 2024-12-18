const getAWSCredential = () => {
  const isDev = process.env.NODE_ENV === "development";
  const credentials = isDev
    ? {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      }
    : null;
  return credentials;
}

export default getAWSCredential;