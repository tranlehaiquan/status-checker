class ErrorTimeout extends Error {
  constructor(message) {
    super(message);
    this.name = "ErrorTimeout";
  }
}

// ping to a website
export const pingToWebsite = async (url: string, timeout: number = 10) => {
  // let null be the default value for status
  let status = null;
  let responseTime;
  let ok = false;

  const start = Date.now();
  try {
    const result = (await promiseWithTimeout(
      fetch(url),
      timeout * 1000
    )) as Response;
    status = result.status;
    ok = result.ok;
  } catch (error) {
    if (error instanceof ErrorTimeout) {
      status = 408;
    }

    console.error(error);
  } finally {
    responseTime = Date.now() - start;
  }

  return {
    status,
    ok,
    responseTime,
  };
};

const promiseWithTimeout = (
  promise,
  ms,
  timeoutError = new ErrorTimeout("timeout")
) => {
  const timeout = new Promise((_, reject) => {
    setTimeout(() => {
      reject(timeoutError);
    }, ms);
  });

  return Promise.race([promise, timeout]);
};
