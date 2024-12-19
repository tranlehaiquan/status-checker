import { InsertStatusCheck, StatusCheckResultRecord } from "./types"

const BASE_URL = import.meta.env.VITE_BE_URL;

export const createStatusCheck = async (params: InsertStatusCheck) => {
  const response = await fetch(`${BASE_URL}/check`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(params),
  });

  return response.json();
}

export const getAllStatusCheck = async () => {}

export const getStatusCheckById = async (id: string): Promise<StatusCheckResultRecord> => {
  const response = await fetch(`${BASE_URL}/check/${id}`);
  return response.json();
}