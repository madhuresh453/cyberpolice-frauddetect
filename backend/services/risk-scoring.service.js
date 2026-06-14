/**
 * CyberShield AI - Risk Scoring Engine
 * 
 * Computes real-time risk scores for calls, SMS, transactions, and URLs
 * using NLP, keyword analysis, threat intelligence, and behavior analysis.
 */

// ===== SCAM KEYWORD DATABASE =====
const SCAM_KEYWORDS = {
  otp: { weight: 20, category: "OTP_FRAUD", severity: "high" },
  kyc: { weight: 18, category: "KYC_FRAUD", severity: "high" },
  "bank account": { weight: 15, category: "BANK_FRAUD", severity: "medium" },
  upi: { weight: 20, category: "UPI_FRAUD", severity: "high" },
  "remote access": { weight: 25, category: "REMOTE_ACCESS", severity: "critical" },
  anydesk: { weight: 25, category: "REMOTE_ACCESS", severity: "critical" },
  teamviewer: { weight: 25, category: "REMOTE_ACCESS", severity: "critical" },
  "atm card": { weight: 15, category: "BANK_FRAUD", severity: "high" },
  "credit card": { weight: 15, category: "BANK_FRAUD", severity: "high" },
  aadhaar: { weight: 12, category: "IDENTITY_FRAUD", severity: "medium" },
  "pan card": { weight: 12, category: "IDENTITY_FRAUD", severity: "medium" },
  "net banking": { weight: 15, category: "BANK_FRAUD", severity: "medium" },
  "customer care": { weight: 8, category: "IMPERSONATION", severity: "low" },
  refund: { weight: 15, category: "REFUND_FRAUD", severity: "high" },
  "loan approval": { weight: 12, category: "LOAN_FRAUD", severity: "medium" },
  "prize money": { weight: 20, category: "PRIZE_SCAM", severity: "high" },
  "gift voucher": { weight: 15, category: "PRIZE_SCAM", severity: "medium" },
  "free offer": { weight: 5, category: "PROMOTION", severity: "low" },
  urgent: { weight: 10, category: "URGENCY", severity: "medium" },
  immediately: { weight: 8, category: "URGENCY", severity: "low" },
  "action required": { weight: 10, category: "URGENCY", severity: "medium" },
  police: { weight: 15, category: "IMPERSONATION", severity: "high" },
  government: { weight: 12, category: "IMPERSONATION", severity: "medium" },
  officer: { weight: 10, category: "IMPERSONATION", severity: "medium" },
  "cyber crime": { weight: 18, category: "IMPERSONATION", severity: "high" },
  "digital arrest": { weight: 30, category: "DIGITAL_ARREST", severity: "critical" },
  "skip tracing": { weight: 25, category: "DIGITAL_ARREST", severity: "critical" },
  "trafficking": { weight: 25, category: "EXTREME", severity: "critical" },
  "narcotics": { weight: 25, category: "EXTREME", severity: "critical" },
  "money laundering": { weight: 20, category: "FINANCIAL_CRIME", severity: "high" },
  "income tax": { weight: 15, category: "IMPERSONATION", severity: "high" },
  "electricity bill": { weight: 10, category: "UTILITY_FRAUD", severity: "medium" },
  "phone bill": { weight: 10, category: "UTILITY_FRAUD", severity: "medium" },
  "prize winner": { weight: 20, category: "PRIZE_SCAM", severity: "high" },
  "lottery winner": { weight: 20, category: "PRIZE_SCAM", severity: "high" },
  "you have won": { weight: 20, category: "PRIZE_SCAM", severity: "high" },
  "claim your": { weight: 15, category: "PRIZE_SCAM", severity: "medium" },
  "free gift": { weight: 10, category: "PRIZE_SCAM", severity: "medium" },
  "limited time": { weight: 8, category: "URGENCY", severity: "low" },
  "today only": { weight: 8, category: "URGENCY", severity: "low" },
  "personal details": { weight: 15, category: "PHISHING", severity: "high" },
  "login details": { weight: 15, category: "PHISHING", severity: "high" },
  "click here": { weight: 10, category: "PHISHING", severity: "medium" },
  "verify now": { weight: 15, category: "PHISHING", severity: "high" },
  "account suspended": { weight: 20, category: "THREAT_INTIMIDATION", severity: "high" },
  "account blocked": { weight: 20, category: "THREAT_INTIMIDATION", severity: "high" },
  "legal action": { weight: 20, category: "THREAT_INTIMIDATION", severity: "high" },
  "court notice": { weight: 22, category: "THREAT_INTIMIDATION", severity: "critical" },
  "arrest warrant": { weight: 28, category: "THREAT_INTIMIDATION", severity: "critical" },
  "transfer money": { weight: 25, category: "FRAUD", severity: "critical" },
  "send money": { weight: 22, category: "FRAUD", severity: "critical" },
  "pay now": { weight: 15, category: "FRAUD", severity: "high" },
  "emergency": { weight: 10, category: "URGENCY", severity: "medium" },
  "help me": { weight: 8, category: "SOCIAL_ENGINEERING", severity: "medium" },
  "confidential": { weight: 10, category: "PHISHING", severity: "medium" },
  "secret": { weight: 10, category: "PHISHING", severity: "medium" },
  "don't tell anyone": { weight: 20, category: "SOCIAL_ENGINEERING", severity: "high" },
};

// ===== PHONE NUMBER PATTERNS =====
const KNOWN_SPAM_PREFIXES = ["+91140", "+91130", "+92121", "+92123", "+92124"];
const HIGH_RISK_COUNTRIES = ["+92", "+94", "+880", "+977", "+98", "+963"];

// ===== URL ANALYSIS =====
const PHISHING_DOMAINS = [
  "google.security.com", "paytm-safe.com", "phonepe-verify.com",
  "gpay-verify.com", "sbisecure.in", "hdfc-bank.in", "icici-verify.com",
  "www-icici.com", "www-hdfc.com", "www-sbi.com", "netflix-free.com",
  "amazon-gift.com", "flipkart-offer.com", "irctc-refund.com",
];

const SUSPICIOUS_TLDS = [".xyz", ".top", ".club", ".gq", ".ml", ".cf", ".tk", ".ga"];

// ===== RISK SCORING FUNCTIONS =====

/**
 * Analyze text for scam keywords and patterns
 * Returns { score, keywords_found, categories }
 */
function analyzeText(text) {
  if (!text || text.trim().length === 0) {
    return { score: 0, keywordsFound: [], categories: {}, severity: "safe" };
  }

  const lowerText = text.toLowerCase();
  const keywordsFound = [];
  const categories = {};
  let totalWeight = 0;

  for (const [keyword, data] of Object.entries(SCAM_KEYWORDS)) {
    if (lowerText.includes(keyword)) {
      keywordsFound.push({ keyword, weight: data.weight, category: data.category, severity: data.severity });
      totalWeight += data.weight;
      categories[data.category] = (categories[data.category] || 0) + data.weight;
    }
  }

  // Normalize score to 0-100 range
  const score = Math.min(totalWeight, 100);

  // Determine severity
  let severity = "safe";
  if (score > 75) severity = "critical";
  else if (score > 50) severity = "high";
  else if (score > 25) severity = "medium";
  else if (score > 10) severity = "low";

  return {
    score,
    keywordsFound,
    categories,
    severity,
    riskLevel: score <= 20 ? "safe" : score <= 50 ? "low" : score <= 75 ? "medium" : "high",
  };
}

/**
 * Analyze a phone number for risk patterns
 */
function analyzePhoneNumber(phoneNumber) {
  if (!phoneNumber) return { riskScore: 0, isSpam: false, reason: "No number" };

  let riskScore = 0;
  const reasons = [];

  // Check known spam prefixes
  for (const prefix of KNOWN_SPAM_PREFIXES) {
    if (phoneNumber.startsWith(prefix)) {
      riskScore += 40;
      reasons.push(`Known spam prefix: ${prefix}`);
      break;
    }
  }

  // Check high-risk country codes
  for (const countryCode of HIGH_RISK_COUNTRIES) {
    if (phoneNumber.startsWith(countryCode)) {
      riskScore += 20;
      reasons.push(`International number from high-risk region`);
      break;
    }
  }

  // Unknown number (not in contacts)
  riskScore += 15;
  reasons.push("Unknown number");

  // Short number or unusual format
  const digits = phoneNumber.replace(/\D/g, "");
  if (digits.length < 10) {
    riskScore += 20;
    reasons.push("Suspicious number format");
  }

  return {
    riskScore: Math.min(riskScore, 100),
    isSuspicious: riskScore > 30,
    reasons,
  };
}

/**
 * Analyze a URL for phishing/malware indicators
 */
function analyzeUrl(url) {
  if (!url || url.trim().length === 0) {
    return { riskScore: 0, isMalicious: false, indicators: [] };
  }

  let riskScore = 0;
  const indicators = [];
  const lowerUrl = url.toLowerCase();

  // Check exact phishing domains
  const isPhishingDomain = PHISHING_DOMAINS.some(domain => lowerUrl.includes(domain));
  if (isPhishingDomain) {
    riskScore += 50;
    indicators.push("Known phishing domain");
  }

  // Check suspicious TLDs
  const hasSuspiciousTld = SUSPICIOUS_TLDS.some(tld => lowerUrl.endsWith(tld));
  if (hasSuspiciousTld) {
    riskScore += 20;
    indicators.push("Suspicious TLD");
  }

  // Check for IP address instead of domain
  const ipRegex = /https?:\/\/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/;
  if (ipRegex.test(lowerUrl)) {
    riskScore += 30;
    indicators.push("Uses IP address instead of domain");
  }

  // Check for URL shorteners
  const shorteners = ["bit.ly", "tinyurl", "tiny.cc", "goo.gl", "ow.ly", "is.gd", "buff.ly", "t.co"];
  const isShortener = shorteners.some(s => lowerUrl.includes(s));
  if (isShortener) {
    riskScore += 10;
    indicators.push("URL shortener - destination hidden");
  }

  // Check for excessive subdomains
  const subdomainCount = (lowerUrl.match(/\./g) || []).length;
  if (subdomainCount > 4) {
    riskScore += 15;
    indicators.push("Excessive subdomains");
  }

  // Check for suspicious keywords in URL
  const suspiciousUrlWords = ["login", "verify", "secure", "account", "update", "confirm", "bank", "pay"];
  for (const word of suspiciousUrlWords) {
    if (lowerUrl.includes(word)) {
      riskScore += 10;
      indicators.push(`Suspicious keyword '${word}' in URL`);
      break;
    }
  }

  // Check for misspelled domains (typosquatting)
  const misspelledPatterns = [
    /g00gle/i, /gogle/i, /googie/i, /go0gle/i,
    /faceb00k/i, /facebok/i, /facebook/i,
    /whatsapp/i.test(lowerUrl) && !lowerUrl.includes("whatsapp.com"),
  ];
  if (misspelledPatterns.some(p => p === true || (typeof p === 'object' && p.test(lowerUrl)))) {
    riskScore += 35;
    indicators.push("Possible typosquatting domain");
  }

  const finalScore = Math.min(riskScore, 100);

  return {
    riskScore: finalScore,
    isMalicious: finalScore > 50,
    isSuspicious: finalScore > 20 && finalScore <= 50,
    isSafe: finalScore <= 20,
    indicators,
    riskLevel: finalScore <= 20 ? "safe" : finalScore <= 50 ? "suspicious" : "dangerous",
  };
}

/**
 * Analyze a UPI transaction for fraud indicators
 */
function analyzeTransaction(transaction) {
  let riskScore = 0;
  const indicators = [];

  // Large amount
  if (transaction.amount > 50000) {
    riskScore += 20;
    indicators.push("Large transaction amount");
  } else if (transaction.amount > 100000) {
    riskScore += 35;
    indicators.push("Very large transaction amount");
  }

  // Unknown merchant
  if (transaction.merchantId && transaction.merchantId.startsWith("new_")) {
    riskScore += 15;
    indicators.push("Unknown merchant");
  }

  // New beneficiary
  if (transaction.isNewBeneficiary) {
    riskScore += 20;
    indicators.push("First-time beneficiary");
  }

  // Unusual time
  const hour = new Date().getHours();
  if (hour >= 23 || hour < 6) {
    riskScore += 10;
    indicators.push("Transaction at unusual hour");
  }

  // Rapid transactions (if provided)
  if ((transaction.recentTransactionCount || 0) > 5) {
    riskScore += 15;
    indicators.push("Multiple recent transactions");
  }

  return {
    riskScore: Math.min(riskScore, 100),
    riskLevel: riskScore <= 20 ? "safe" : riskScore <= 50 ? "suspicious" : "risky",
    indicators,
    shouldBlock: riskScore > 70,
    shouldWarn: riskScore > 40,
  };
}

/**
 * Main risk scoring function - combines all analyses
 */
function calculateRiskScore(context) {
  const scores = [];
  const factors = [];

  // Text analysis
  if (context.text) {
    const textResult = analyzeText(context.text);
    scores.push(textResult.score * 0.4); // 40% weight
    factors.push({ name: "Content Analysis", score: textResult.score, severity: textResult.severity });
  }

  // Phone number analysis
  if (context.phoneNumber) {
    const phoneResult = analyzePhoneNumber(context.phoneNumber);
    scores.push(phoneResult.riskScore * 0.25); // 25% weight
    factors.push({ name: "Caller Reputation", score: phoneResult.riskScore, severity: phoneResult.isSuspicious ? "medium" : "low" });
  }

  // URL analysis
  if (context.url) {
    const urlResult = analyzeUrl(context.url);
    scores.push(urlResult.riskScore * 0.35); // 35% weight
    factors.push({ name: "Link Analysis", score: urlResult.riskScore, severity: urlResult.riskLevel });
  }

  // Transaction analysis
  if (context.transaction) {
    const txResult = analyzeTransaction(context.transaction);
    scores.push(txResult.riskScore * 0.3);
    factors.push({ name: "Transaction Analysis", score: txResult.riskScore, severity: txResult.riskLevel });
  }

  // Compute final score (average with weights)
  const totalWeight = scores.length > 0 ? scores.length : 1;
  const finalScore = Math.round(scores.reduce((a, b) => a + b, 0) / totalWeight);

  return {
    score: Math.min(finalScore, 100),
    factors,
    riskLevel: finalScore <= 20 ? "safe" : finalScore <= 50 ? "low" : finalScore <= 75 ? "medium" : "high",
    isThreat: finalScore > 50,
    timestamp: new Date().toISOString(),
  };
}

// ===== EXPORT =====
export {
  analyzeText,
  analyzePhoneNumber,
  analyzeUrl,
  analyzeTransaction,
  calculateRiskScore,
  SCAM_KEYWORDS,
};