import axios from "axios";
import { env } from "@/config/env";

/** Matches the backend envelope (docs/api-conventions.md). */
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: { code: string; message: string; details?: Record<string, string> };
  timestamp: string;
}

export const api = axios.create({
  baseURL: env.apiBaseUrl,
  timeout: 20_000,
  headers: { Accept: "application/json" },
});

// TODO(auth): attach the access token (kept in memory, not localStorage) and
// refresh once on 401.
