"use client";

import { useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export function useAuth({ required = false, adminOnly = false } = {}) {
  const { data: session, status } = useSession();
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);

  const isAuthenticated = !!session?.user;
  const isAdmin = session?.user?.role === "ADMIN";

  useEffect(() => {
    if (status === "loading") {
      return;
    }

    if (required && !isAuthenticated) {
      router.push("/login");
      return;
    }

    if (adminOnly && !isAdmin) {
      router.push("/");
      return;
    }

    setIsLoading(false);
  }, [status, isAuthenticated, isAdmin, required, adminOnly, router]);

  return {
    session,
    isLoading: status === "loading" || isLoading,
    isAuthenticated,
    isAdmin,
  };
}