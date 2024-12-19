import { StatusCheckRecord } from "@/api/types";
import { cn } from "@/lib/utils";
import React from "react";
import { useQuery } from "@tanstack/react-query";
import { getStatusCheckById } from "@/api";

interface Props {
  className?: string;
  statusCheck: StatusCheckRecord;
}

const StatusCheckResults: React.FC<Props> = ({ statusCheck, className }) => {
  const { data, isLoading } = useQuery({
    queryKey: ["statusCheck", statusCheck.id],
    queryFn: () => getStatusCheckById(statusCheck.id),
    refetchInterval: 5000,
  });

  return (
    <div className={cn(className)}>
      <h2 className="text-2xl font-bold">Results for {statusCheck.url}</h2>
      <p className="text-gray-500">Created at {statusCheck.createdAt}</p>

      {isLoading && <p>Loading...</p>}
      {data?.results?.map((result) => (
        <div key={result.id} className="border p-4 my-4">
          <p>Region: {result.region}</p>
          <p>Status: {result.status}</p>
          <p>Response time: {result.responseTime}ms</p>
        </div>
      ))}
    </div>
  );
};

export default StatusCheckResults;
