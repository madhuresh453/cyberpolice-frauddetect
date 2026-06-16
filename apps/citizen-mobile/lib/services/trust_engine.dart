import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/api_client.dart';

/// Central Trust Engine — scores phone numbers, UPI IDs, websites, etc.
/// Combines: AI analysis + Police reports + Community reports + Historical data
class RaksaarTrustEngine {
  static final RaksaarTrustEngine _instance = RaksaarTrustEngine._();
  factory RaksaarTrustEngine() => _instance;
  RaksaarTrustEngine._();

  final ApiClient _api = ApiClient();

  // Cache results locally for offline use
  Future<Map<String, dynamic>> _getCache(String key) async {
    final box = await Hive.openBox('trust_cache');
    final cached = box.get(key);
    if (cached != null) {
      final data = jsonDecode(cached) as Map<String, dynamic>;
      // Cache valid for 24 hours
      if (DateTime.now().millisecondsSinceEpoch - (data['_cached_at'] as int? ?? 0) < 86400000) {
        return data;
      }
    }
    return {};
  }

  Future<void> _setCache(String key, Map<String, dynamic> data) async {
    final box = await Hive.openBox('trust_cache');
    data['_cached_at'] = DateTime.now().millisecondsSinceEpoch;
    await box.put(key, jsonEncode(data));
  }

  /// Get trust score for a phone number
  /// Returns: { score, risk_level, reports_count, sources, scam_type, last_reported }
  Future<Map<String, dynamic>> checkPhoneNumber(String phoneNumber) async {
    // Check cache first
    final cached = await _getCache('phone:$phoneNumber');
    if (cached.isNotEmpty) return cached;

    try {
      final result = await _api.checkPhoneReputation(phoneNumber);
      final data = result.data;
      await _setCache('phone:$phoneNumber', data);
      return data;
    } catch (e) {
      // Return cached or basic
      return {
        'score': 50, 'risk_level': 'unknown',
        'error': 'Using local data: ${e.toString()}',
        'sources': ['offline_cache'],
      };
    }
  }

  /// Get trust score for a UPI ID
  Future<Map<String, dynamic>> checkUpiId(String upiId) async {
    final cached = await _getCache('upi:$upiId');
    if (cached.isNotEmpty) return cached;

    try {
      final result = await _api.checkUpiReputation(upiId);
      final data = result.data;
      await _setCache('upi:$upiId', data);
      return data;
    } catch (e) {
      // Analyze locally
      return _analyzeUpiLocally(upiId);
    }
  }

  /// Analyze UPI ID locally when offline
  Map<String, dynamic> _analyzeUpiLocally(String upiId) {
    int score = 50;
    final indicators = <String>[];
    final upi = upiId.toLowerCase();

    // Check for suspicious patterns
    if (upi.contains('pay') || upi.contains('send') || upi.contains('receive')) {
      score += 10;
      indicators.add('Generic UPI handle');
    }
    if (upi.contains('new') || upi.contains('temp') || upi.contains('fresh')) {
      score += 15;
      indicators.add('Newly created handle');
    }
    if (RegExp(r'^\d{10,}@').hasMatch(upi)) {
      score += 20;
      indicators.add('Phone number as UPI (common for fraud)');
    }
    if (upi.contains('sbi') || upi.contains('hdfc') || upi.contains('icici')) {
      if (upi.contains('customer') || upi.contains('help') || upi.contains('care')) {
        score += 25;
        indicators.add('Impersonation script detected');
      }
    }

    score = score.clamp(0, 100);
    return {
      'upi_id': upiId,
      'score': score,
      'risk_level': score >= 70 ? 'high' : score >= 40 ? 'medium' : 'low',
      'indicators': indicators,
      'recommendation': score >= 70 ? 'DO_NOT_PAY' : score >= 40 ? 'VERIFY' : 'SAFE',
      'sources': ['local_analysis'],
    };
  }

  /// Analyze a URL for phishing / scam
  Future<Map<String, dynamic>> checkUrl(String url) async {
    final cached = await _getCache('url:$url');
    if (cached.isNotEmpty) return cached;

    int score = 0;
    final indicators = <String>[];
    final lowerUrl = url.toLowerCase();

    // Phishing domains
    const phishingDomains = [
      'google.security.com', 'paytm-safe.com', 'phonepe-verify.com',
      'gpay-verify.com', 'sbisecure.in', 'hdfc-bank.in', 'icici-verify.com',
      'www-icici.com', 'www-hdfc.com', 'www-sbi.com',
    ];
    for (final domain in phishingDomains) {
      if (lowerUrl.contains(domain)) {
        score += 50;
        indicators.add('Known phishing domain: $domain');
      }
    }

    // Suspicious TLDs
    const suspiciousTlds = ['.xyz', '.top', '.club', '.gq', '.ml', '.cf', '.tk', '.ga'];
    for (final tld in suspiciousTlds) {
      if (lowerUrl.endsWith(tld)) {
        score += 20;
        indicators.add('Suspicious TLD: $tld');
      }
    }

    // URL shorteners
    const shorteners = ['bit.ly', 'tinyurl', 'tiny.cc', 'goo.gl', 'ow.ly', 'is.gd', 't.co'];
    for (final s in shorteners) {
      if (lowerUrl.contains(s)) {
        score += 10;
        indicators.add('URL shortened by $s');
      }
    }

    score = score.clamp(0, 100);
    final result = {
      'url': url,
      'score': score,
      'risk_level': score >= 50 ? 'high' : score >= 20 ? 'medium' : 'low',
      'indicators': indicators,
      'recommendation': score >= 50 ? 'BLOCK' : score >= 20 ? 'CAUTION' : 'SAFE',
      'sources': ['url_analysis'],
    };
    await _setCache('url:$url', result);
    return result;
  }

  /// Analyze SMS content for fraud
  Future<Map<String, dynamic>> analyzeSms(String text, {String? sender}) async {
    try {
      final result = await _api.analyzeSms(text, sender: sender);
      return result.data;
    } catch (e) {
      // Local classification
      return _classifySmsLocally(text);
    }
  }

  Map<String, dynamic> _classifySmsLocally(String text) {
    int score = 0;
    final keywords = <String>[];
    final lowerText = text.toLowerCase();

    // Fraud keywords
    const fraudPatterns = {
      'otp': 10, 'bank': 15, 'account': 10, 'kyc': 20, 'update': 10,
      'verify': 15, 'urgent': 15, 'blocked': 20, 'suspended': 20, 'limited': 10,
      'reward': 15, 'lottery': 25, 'won': 20, 'prize': 20, 'cashback': 10,
      'loan': 10, 'credit': 10, 'insurance': 10, 'emi': 10, 'card': 10,
      'upi': 15, 'gpay': 10, 'phonepe': 10, 'paytm': 10,
      'salary': 15, 'job': 15, 'work from home': 20, 'part time': 20,
      'investment': 20, 'crypto': 25, 'bitcoin': 25, 'guaranteed': 20,
    };

    for (final entry in fraudPatterns.entries) {
      if (lowerText.contains(entry.key)) {
        score += entry.value;
        keywords.add(entry.key);
      }
    }

    // Check for URLs
    if (text.contains('http') || text.contains('.com') || text.contains('.in')) {
      score += 10;
      keywords.add('contains_url');
    }

    score = score.clamp(0, 100);
    String scamType;
    if (score >= 50) {
      if (keywords.any((k) => ['otp', 'bank', 'kyc', 'verify'].contains(k))) {
        scamType = 'KYC_FRAUD';
      } else if (keywords.any((k) => ['lottery', 'won', 'prize', 'reward'].contains(k))) {
        scamType = 'LOTTERY_SCAM';
      } else if (keywords.any((k) => ['job', 'work from home', 'part time', 'salary'].contains(k))) {
        scamType = 'JOB_SCAM';
      } else if (keywords.any((k) => ['investment', 'crypto', 'bitcoin', 'guaranteed'].contains(k))) {
        scamType = 'INVESTMENT_SCAM';
      } else if (keywords.any((k) => ['loan', 'credit', 'card', 'emi'].contains(k))) {
        scamType = 'LOAN_SCAM';
      } else if (keywords.any((k) => ['blocked', 'suspended', 'limited', 'urgent'].contains(k))) {
        scamType = 'ACCOUNT_TAKEOVER';
      } else {
        scamType = 'FRAUD_SMS';
      }
    } else {
      scamType = 'SAFE';
    }

    return {
      'is_scam': score >= 50,
      'risk_score': score,
      'scam_type': scamType,
      'keywords_found': keywords,
      'recommendation': score >= 70 ? 'DELETE IMMEDIATELY' :
                        score >= 40 ? 'Do not click any links' : 'Message appears safe',
    };
  }

  /// Analyze WhatsApp content
  Future<Map<String, dynamic>> analyzeWhatsApp(String text, {String? sender}) async {
    final smsResult = await analyzeSms(text, sender: sender);
    
    // WhatsApp-specific checks
    final indicators = <String>[];
    final lower = text.toLowerCase();
    
    if (lower.contains('part time') || lower.contains('work from home') || lower.contains('daily earning')) {
      indicators.add('Employment scam pattern');
    }
    if (lower.contains('crypto') || lower.contains('bitcoin') || lower.contains('investment')) {
      indicators.add('Investment scam pattern');
    }
    if (lower.contains('lottery') || lower.contains('you won')) {
      indicators.add('Lottery scam pattern');
    }
    if (lower.contains('screenshot') || lower.contains('apk') || lower.contains('download')) {
      indicators.add('APK/malware distribution');
    }

    return {
      ...smsResult,
      'whatsapp_indicators': indicators,
      'platform': 'whatsapp',
    };
  }
}