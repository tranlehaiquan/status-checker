import React from "react";
import StatusCheckResults from "./StatusCheckResults";
import StatusCheckForm from "./StatusCheckForm";
import { Button } from "@/components/ui/button";
import { StatusCheckRecord } from "@/api/types";

interface Props {
  className?: string;
}

const StatusCheck: React.FC<Props> = () => {
  const [statusCheck, setStatusCheck] =
    React.useState<StatusCheckRecord | null>(null);

  const handleGoBack = () => {
    setStatusCheck(null);
  };

  const onSuccessfulSubmit = (data: StatusCheckRecord) => {
    setStatusCheck(data);
  };

  if (!statusCheck) {
    return <StatusCheckForm onSuccessfulSubmit={onSuccessfulSubmit} />;
  }

  return (
    <div>
      <Button onClick={handleGoBack} variant={"link"}>
        &larr; Go back
      </Button>

      <StatusCheckResults statusCheck={statusCheck} />
    </div>
  );
};

export default StatusCheck;
