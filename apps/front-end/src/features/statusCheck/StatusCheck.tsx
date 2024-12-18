import React from 'react';
import StatusCheckResults from './StatusCheckResults';
import StatusCheckForm from './StatusCheckForm';
import { Button } from '@/components/ui/button';

interface Props {
  className?: string;
};

const StatusCheck: React.FC<Props> = () => {
  const [statusCheckId, setStatusCheckId] = React.useState<string | null>(null);

  const handleGoBack = () => {
    setStatusCheckId(null);
  }

  if(!statusCheckId) {
    return <StatusCheckForm />;
  }

  return (
    <div>
      <Button onClick={handleGoBack}>Go back</Button>

      <StatusCheckResults />   
    </div>
  );
}

export default StatusCheck;