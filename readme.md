```mermaid
graph TD;
    A(Gateway) --> B[POST lambda /check];
    B --> Database[(Dynamodb)]
    B --> C[SNS: Check Created];
    C --> D[SQS];
    D --> E[Lambda Ping to Website];

    subgraph Multiple Region
      D[SQS];
      E[Lambda Ping to Website];
    end

    E -- Create Check result --> Database

```


```mermaid
erDiagram
    JobCheck {
        string id
        string url
        string createdDate
    }

    JobCheckResponse {
        string id
        string JobCheckId
        string status
        int    statusCode
        int    responseTime
        string createdDate
    }
    
    JobCheck ||--o{ JobCheckResponse : has
```

## Invoke function with SAM

```shell
# Invoke single function
sam local invoke --hook-name terraform --event ./src/events/testEvent.json aws_lambda_function.lambda_create_check --env-vars env.jso

# Start API Gateway
sam local start-api --hook-name terraform
```