export type InsertStatusCheck = {
  url: string;
};

export type StatusCheckRecord = {
  id: string;
  url: string;
  createdAt: string;
};

export type StatusCheckResultRecord = {
  id: string;
  url: string;

  results: {
    jobCheckId: string;
    region: string;
    responseTime: number;
    id: string;
    status: number;
    ok: boolean;
  }[];
};
