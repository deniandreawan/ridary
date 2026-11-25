import { Navigate, Outlet } from "react-router-dom";
import { LoadingScreen } from "../components/Banners";
import { useApp } from "../context/AppContext";

export default function ProtectedRoute() {
  const { loading, user, demoMode } = useApp();

  if (loading) {
    return (
      <div className="min-h-[100dvh] bg-canvas px-6 py-10">
        <LoadingScreen />
      </div>
    );
  }

  if (!user && !demoMode) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
}
