import { createBrowserRouter } from "react-router-dom";
import { DashboardPage } from "@/pages/DashboardPage";

/** Central route table. Add feature routes here (lazy-load large pages). */
export const router = createBrowserRouter([
  { path: "/", element: <DashboardPage /> },
]);
