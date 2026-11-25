import { Outlet } from "react-router-dom";
import { AppProvider } from "../context/AppContext";

export default function AppShell() {
  return (
    <AppProvider>
      <Outlet />
    </AppProvider>
  );
}
