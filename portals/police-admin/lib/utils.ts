import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatDate(date: string | Date): string {
  return new Intl.DateTimeFormat("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(date));
}

export function formatNumber(num: number): string {
  return new Intl.NumberFormat("en-IN").format(num);
}

export function formatPercent(value: number): string {
  return `${(value * 100).toFixed(1)}%`;
}

export function getRiskColor(score: number): string {
  if (score >= 80) return "text-red-500";
  if (score >= 60) return "text-orange-500";
  if (score >= 40) return "text-yellow-500";
  return "text-green-500";
}

export function getRiskBadge(score: number): { label: string; variant: "destructive" | "warning" | "default" | "secondary" } {
  if (score >= 80) return { label: "Critical", variant: "destructive" };
  if (score >= 60) return { label: "High", variant: "warning" };
  if (score >= 40) return { label: "Medium", variant: "default" };
  return { label: "Low", variant: "secondary" };
}

export function getStatusColor(status: string): string {
  const colors: Record<string, string> = {
    active: "text-green-500",
    pending: "text-yellow-500",
    resolved: "text-blue-500",
    closed: "text-gray-500",
    blocked: "text-red-500",
  };
  return colors[status] || "text-gray-500";
}

export function truncate(str: string, length: number = 50): string {
  if (str.length <= length) return str;
  return str.slice(0, length) + "...";
}