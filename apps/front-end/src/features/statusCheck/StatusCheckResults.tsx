import { StatusCheckRecord } from "@/api/types";
import { cn } from "@/lib/utils";
import React, { useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { getStatusCheckById } from "@/api";
import { Loader2 } from "lucide-react";

interface Props {
  className?: string;
  statusCheck: StatusCheckRecord;
}

const TOTAL_REFETCH_TIME = 10000;
const REFETCH_INTERVAL = 2500;

const StatusCheckResults: React.FC<Props> = ({ statusCheck, className }) => {
  const [refetch, setRefetch] = React.useState(true);

  const { data, isLoading } = useQuery({
    queryKey: ["statusCheck", statusCheck.id],
    queryFn: () => getStatusCheckById(statusCheck.id),
    refetchInterval: REFETCH_INTERVAL,
    enabled: refetch,
  });

  useEffect(() => {
    const timer = setTimeout(() => {
      setRefetch(false);
    }, TOTAL_REFETCH_TIME);

    return () => {
      clearTimeout(timer);
    };
  }, []);

  const formatDate = (date: string) => {
    return new Date(date).toLocaleString();
  };

  const getStatusColor = (status: boolean) => {
    switch (status) {
      case true:
        return "text-green-600 bg-green-50";
      case false:
        return "text-red-600 bg-red-50";
      default:
        return "text-gray-600 bg-gray-50";
    }
  };

  return (
    <div className={cn("max-w-3xl mx-auto", className)}>
      <h2 className="text-2xl font-bold mb-2">Results for {statusCheck.url}</h2>
      <p className="text-gray-500 mb-6">
        Created at {formatDate(statusCheck.createdAt)}
      </p>

      {(isLoading || refetch) && (
        <div className="flex items-center justify-center py-8">
          <Loader2 className="h-8 w-8 animate-spin text-gray-500" />
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-2">
        {data?.results?.map((result) => (
          <div
            key={result.id}
            className={cn(
              "rounded-lg border p-4 shadow-sm transition-all hover:shadow-md",
              getStatusColor(result.ok)
            )}
          >
            <div className="flex justify-between items-start mb-2">
              <h3 className="font-semibold">{result.region}</h3>
              <span className="font-medium">{result.status}</span>
            </div>
            <p className="text-sm opacity-75">
              Response time:{" "}
              <span className="font-medium">{result.responseTime}ms</span>
            </p>
          </div>
        ))}
      </div>
    </div>
  );
};

export default StatusCheckResults;
