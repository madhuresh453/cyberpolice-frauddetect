"use client";
import { useState } from "react";
import { FileText, AlertTriangle, CheckCircle, Loader2 } from "lucide-react";

const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api/v1";

export default function FIRPage() {
  const [step, setStep] = useState<"form" | "submitted">("form");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [firResult, setFirResult] = useState<any>(null);
  const [form, setForm] = useState({
    complainants_name: "", complainants_phone: "", complainants_address: "",
    incident_date: "", incident_location: "", incident_description: "",
    accused_name: "", accused_phone: "", accused_address: "",
    case_id: "",
    sections_listed: [] as string[],
  });

  const sections = [
    "66 IT Act - Computer Related Offences", "66B - Dishonestly receiving stolen computer",
    "66C - Identity theft", "66D - Cheating by impersonation",
    "66E - Privacy violation", "67 - Obscene content",
    "67A - Sexually explicit content", "419 IPC - Cheating by impersonation",
    "420 IPC - Cheating", "406 IPC - Criminal breach of trust",
    "379 IPC - Theft", "384 IPC - Extortion",
    "468 IPC - Forgery for cheating", "471 IPC - Using forged document",
  ];

  const toggleSection = (s: string) => {
    setForm(prev => ({
      ...prev,
      sections_listed: prev.sections_listed.includes(s)
        ? prev.sections_listed.filter(x => x !== s)
        : [...prev.sections_listed, s],
    }));
  };

  const handleSubmit = async () => {
    setLoading(true);
    setError("");
    const token = localStorage.getItem("jwt_token");
    try {
      const res = await fetch(`${API}/police/firs`, {
        method: "POST",
        headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          case_id: form.case_id,
          complainant_name: form.complainants_name,
          complainant_phone: form.complainants_phone,
          complainant_address: form.complainants_address,
          incident_date: form.incident_date,
          incident_location: form.incident_location,
          description: form.incident_description,
          sections: form.sections_listed,
          accused_details: form.accused_name ? [{
            name: form.accused_name,
            phone: form.accused_phone,
            address: form.accused_address,
          }] : [],
        }),
      });
      const data = await res.json();
      if (data.status === "registered" || data.status === "created" || data.success) {
        setFirResult(data);
        setStep("submitted");
      } else {
        setError(data.message || "Failed to register FIR");
      }
    } catch (e: any) {
      setError(e.message || "Network error");
    }
    setLoading(false);
  };

  return (
    <div className="space-y-6">
      {step === "form" && (
        <>
          <div>
            <h1 className="text-2xl font-bold mb-1">First Information Report</h1>
            <p className="text-muted-foreground text-sm">Register an FIR under CrPC Section 154</p>
          </div>

          <div className="space-y-4">
            <div className="stat-card">
              <h3 className="font-semibold mb-4">Complainant Details</h3>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm text-muted-foreground mb-1">Full Name *</label>
                  <input className="input-field" value={form.complainants_name}
                    onChange={e => setForm(p => ({ ...p, complainants_name: e.target.value }))} />
                </div>
                <div>
                  <label className="block text-sm text-muted-foreground mb-1">Phone *</label>
                  <input className="input-field" value={form.complainants_phone}
                    onChange={e => setForm(p => ({ ...p, complainants_phone: e.target.value }))} />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm text-muted-foreground mb-1">Address</label>
                  <input className="input-field" value={form.complainants_address}
                    onChange={e => setForm(p => ({ ...p, complainants_address: e.target.value }))} />
                </div>
              </div>
            </div>

            <div className="stat-card">
              <h3 className="font-semibold mb-4">Incident Details</h3>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm text-muted-foreground mb-1">Date of Incident *</label>
                  <input type="date" className="input-field" value={form.incident_date}
                    onChange={e => setForm(p => ({ ...p, incident_date: e.target.value }))} />
                </div>
                <div>
                  <label className="block text-sm text-muted-foreground mb-1">Location</label>
                  <input className="input-field" value={form.incident_location}
                    onChange={e => setForm(p => ({ ...p, incident_location: e.target.value }))} />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm text-muted-foreground mb-1">Description *</label>
                  <textarea className="input-field h-32 resize-none" value={form.incident_description}
                    onChange={e => setForm(p => ({ ...p, incident_description: e.target.value }))}
                    placeholder="Describe the incident in detail..." />
                </div>
              </div>
            </div>

            <div className="stat-card">
              <h3 className="font-semibold mb-4">Accused Details (if known)</h3>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm text-muted-foreground mb-1">Name</label>
                  <input className="input-field" value={form.accused_name}
                    onChange={e => setForm(p => ({ ...p, accused_name: e.target.value }))} />
                </div>
                <div>
                  <label className="block text-sm text-muted-foreground mb-1">Phone</label>
                  <input className="input-field" value={form.accused_phone}
                    onChange={e => setForm(p => ({ ...p, accused_phone: e.target.value }))} />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm text-muted-foreground mb-1">Address</label>
                  <input className="input-field" value={form.accused_address}
                    onChange={e => setForm(p => ({ ...p, accused_address: e.target.value }))} />
                </div>
              </div>
            </div>

            <div className="stat-card">
              <h3 className="font-semibold mb-4">Legal Sections Applied</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                {sections.map(s => (
                  <label key={s} className={`flex items-center gap-2 p-2 rounded-lg cursor-pointer transition-all ${form.sections_listed.includes(s) ? "bg-primary/10 border border-primary/30" : "bg-muted/30 border border-border hover:border-primary/20"}`}>
                    <input type="checkbox" checked={form.sections_listed.includes(s)}
                      onChange={() => toggleSection(s)} className="accent-primary" />
                    <span className="text-sm">{s}</span>
                  </label>
                ))}
              </div>
            </div>

            <div className="stat-card">
              <label className="block text-sm text-muted-foreground mb-1">Case ID (optional — links FIR to existing case)</label>
              <input className="input-field" value={form.case_id}
                onChange={e => setForm(p => ({ ...p, case_id: e.target.value }))} />
            </div>

            {error && <div className="bg-destructive/10 border border-destructive/30 rounded-lg p-3 text-destructive text-sm">{error}</div>}

            <button onClick={handleSubmit} disabled={loading || !form.complainants_name || !form.incident_date}
              className="cyber-button w-full py-3 text-lg">
              {loading ? <Loader2 className="w-5 h-5 animate-spin mx-auto" /> : "Generate FIR"}
            </button>
          </div>
        </>
      )}

      {step === "submitted" && firResult && (
        <div className="stat-card text-center py-12">
          <CheckCircle className="w-16 h-16 text-green-400 mx-auto mb-4" />
          <h2 className="text-2xl font-bold mb-2">FIR Registered Successfully</h2>
          <p className="text-muted-foreground mb-6">The First Information Report has been filed in the system.</p>
          <div className="inline-block bg-muted rounded-lg p-6 mb-6 text-left">
            <p className="text-sm text-muted-foreground">FIR Number</p>
            <p className="text-2xl font-mono text-primary font-bold">{firResult.fir_number || firResult.id}</p>
            <p className="text-sm text-muted-foreground mt-2">Status: <span className="text-green-400">Registered</span></p>
          </div>
          <div className="flex gap-3 justify-center">
            <button onClick={() => { setStep("form"); setForm({ complainants_name: "", complainants_phone: "", complainants_address: "", incident_date: "", incident_location: "", incident_description: "", accused_name: "", accused_phone: "", accused_address: "", case_id: "", sections_listed: [] }); }}
              className="cyber-button">
              File Another FIR
            </button>
            <a href="/dashboard" className="cyber-button">Back to Dashboard</a>
          </div>
        </div>
      )}
    </div>
  );
}