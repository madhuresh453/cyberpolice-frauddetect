"use client";

import { useState } from "react";
import { Shield, Phone, Network, BarChart3, Search, Settings, AlertTriangle, Ban, FileText } from "lucide-react";

export default function IspPortalDashboard() {
  const [activeTab, setActiveTab] = useState("dashboard");

  const tabs = [
    { icon: Shield, label: "Dashboard", id: "dashboard" },
    { icon: Phone, label: "Number Intelligence", id: "numbers" },
    { icon: Network, label: "Traffic Analytics", id: "traffic" },
    { icon: AlertTriangle, label: "Threat Analytics", id: "threats" },
    { icon: Ban, label: "SMS Firewall", id: "firewall" },
    { icon: BarChart3, label: "Fraud Heatmap", id: "heatmap" },
    { icon: Search, label: "API Integrations", id: "integrations" },
    { icon: FileText, label: "Compliance Reports", id: "compliance" },
    { icon: Settings, label: "Settings", id: "settings" },
  ];

  const stats = {
    totalNumbers: 12500000,
    flaggedNumbers: 15200,
    smsSpamBlocked: 482000,
    callsBlocked: 89000,
    activeThreats: 342,
    blockedIPs: 1250,
    complianceScore: 98.5,
    responseTimeMs: 245,
  };

  return (
    <div className="flex min-h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className="w-64 bg-white border-r p-4">
        <div className="flex items-center gap-2 mb-8">
          <Shield className="h-6 w-6 text-blue-600" />
          <span className="font-bold text-lg">ISP Portal</span>
        </div>
        <nav className="space-y-1">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition-colors ${
                activeTab === tab.id
                  ? "bg-blue-600 text-white"
                  : "text-gray-600 hover:bg-gray-100"
              }`}
            >
              <tab.icon className="h-4 w-4" />
              {tab.label}
            </button>
          ))}
        </nav>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-6 overflow-y-auto">
        <div className="mb-6">
          <h1 className="text-2xl font-bold">ISP Intelligence Dashboard</h1>
          <p className="text-gray-500">Real-time fraud detection and number intelligence</p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-4 gap-4 mb-6">
          <div className="bg-white rounded-xl border p-4 shadow-sm">
            <p className="text-sm text-gray-500">Total Numbers</p>
            <p className="text-2xl font-bold">{(stats.totalNumbers / 1000000).toFixed(1)}M</p>
          </div>
          <div className="bg-white rounded-xl border p-4 shadow-sm">
            <p className="text-sm text-gray-500">Flagged Numbers</p>
            <p className="text-2xl font-bold text-orange-600">{stats.flaggedNumbers.toLocaleString()}</p>
          </div>
          <div className="bg-white rounded-xl border p-4 shadow-sm">
            <p className="text-sm text-gray-500">SMS Spam Blocked</p>
            <p className="text-2xl font-bold text-green-600">{stats.smsSpamBlocked.toLocaleString()}</p>
          </div>
          <div className="bg-white rounded-xl border p-4 shadow-sm">
            <p className="text-sm text-gray-500">Calls Blocked</p>
            <p className="text-2xl font-bold text-red-600">{stats.callsBlocked.toLocaleString()}</p>
          </div>
        </div>

        <div className="grid grid-cols-4 gap-4 mb-6">
          <div className="bg-white rounded-xl border p-4 shadow-sm">
            <p className="text-sm text-gray-500">Active Threats</p>
            <p className="text-2xl font-bold text-red-500">{stats.activeThreats}</p>
          </div>
          <div className="bg-white rounded-xl border p-4 shadow-sm">
            <p className="text-sm text-gray-500">Blocked IPs</p>
            <p className="text-2xl font-bold">{stats.blockedIPs.toLocaleString()}</p>
          </div>
          <div className="bg-white rounded-xl border p-4 shadow-sm">
            <p className="text-sm text-gray-500">Compliance Score</p>
            <p className="text-2xl font-bold text-green-600">{stats.complianceScore}%</p>
          </div>
          <div className="bg-white rounded-xl border p-4 shadow-sm">
            <p className="text-sm text-gray-500">Avg Response Time</p>
            <p className="text-2xl font-bold">{stats.responseTimeMs}ms</p>
          </div>
        </div>

        {/* Content */}
        <div className="grid grid-cols-2 gap-6">
          {/* Number Intelligence */}
          <div className="bg-white rounded-xl border p-6 shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Number Intelligence Lookup</h2>
            <div className="flex gap-2 mb-4">
              <input
                type="text"
                placeholder="Enter phone number (+91...)"
                className="flex-1 border rounded-lg px-3 py-2 text-sm"
              />
              <button className="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm">Analyze</button>
            </div>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between p-2 bg-gray-50 rounded">
                <span className="text-gray-500">Risk Score</span>
                <span className="font-medium text-red-500">72/100</span>
              </div>
              <div className="flex justify-between p-2 bg-gray-50 rounded">
                <span className="text-gray-500">Reported Count</span>
                <span className="font-medium">47 times</span>
              </div>
              <div className="flex justify-between p-2 bg-gray-50 rounded">
                <span className="text-gray-500">SMS Spam Score</span>
                <span className="font-medium text-orange-500">68/100</span>
              </div>
              <div className="flex justify-between p-2 bg-gray-50 rounded">
                <span className="text-gray-500">Status</span>
                <span className="font-medium text-red-500">FLAGGED</span>
              </div>
            </div>
          </div>

          {/* Threat Map */}
          <div className="bg-white rounded-xl border p-6 shadow-sm">
            <h2 className="text-lg font-semibold mb-4">Live Threat Activity</h2>
            <div className="space-y-3">
              {[
                { msg: "SMS fraud campaign detected - 2,340 messages blocked", severity: "high", time: "2 min ago" },
                { msg: "Suspicious VoIP traffic from unknown IP range", severity: "medium", time: "5 min ago" },
                { msg: "SIM box detected in Mumbai region", severity: "high", time: "12 min ago" },
                { msg: "Bulk spam call pattern from 5 numbers", severity: "critical", time: "15 min ago" },
                { msg: "New phishing SMS campaign targeting Jio users", severity: "medium", time: "20 min ago" },
              ].map((item, i) => (
                <div key={i} className="flex gap-3 p-3 rounded-lg bg-gray-50">
                  <div className={`w-2 h-2 rounded-full mt-2 ${
                    item.severity === "critical" ? "bg-red-500" :
                    item.severity === "high" ? "bg-orange-500" : "bg-yellow-500"
                  }`} />
                  <div>
                    <p className="text-sm">{item.msg}</p>
                    <p className="text-xs text-gray-400 mt-1">{item.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* SMS Firewall */}
          <div className="bg-white rounded-xl border p-6 shadow-sm">
            <h2 className="text-lg font-semibold mb-4">SMS Firewall Status</h2>
            <div className="grid grid-cols-2 gap-3">
              <div className="p-3 bg-green-50 rounded-lg text-center">
                <p className="text-xl font-bold text-green-600">482K</p>
                <p className="text-xs text-gray-500">Spam Blocked Today</p>
              </div>
              <div className="p-3 bg-blue-50 rounded-lg text-center">
                <p className="text-xl font-bold text-blue-600">1.2M</p>
                <p className="text-xs text-gray-500">Total Analyzed</p>
              </div>
              <div className="p-3 bg-red-50 rounded-lg text-center">
                <p className="text-xl font-bold text-red-600">15,200</p>
                <p className="text-xs text-gray-500">Numbers Blocked</p>
              </div>
              <div className="p-3 bg-purple-50 rounded-lg text-center">
                <p className="text-xl font-bold text-purple-600">98.5%</p>
                <p className="text-xs text-gray-500">Accuracy Rate</p>
              </div>
            </div>
          </div>

          {/* TRAI Compliance */}
          <div className="bg-white rounded-xl border p-6 shadow-sm">
            <h2 className="text-lg font-semibold mb-4">TRAI Compliance</h2>
            <div className="space-y-2">
              {[
                { label: "DND Registry Sync", status: "Active", color: "green" },
                { label: "Spam Reporting API", status: "Connected", color: "green" },
                { label: "Number Portability", status: "Active", color: "green" },
                { label: "DoT Compliance", status: "Compliant", color: "green" },
                { label: "Last Audit", status: "2024-06-01", color: "blue" },
              ].map((item, i) => (
                <div key={i} className="flex justify-between p-2 bg-gray-50 rounded text-sm">
                  <span>{item.label}</span>
                  <span className={`font-medium text-${item.color}-600`}>{item.status}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}