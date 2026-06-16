import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client.dart';

/// Intelligence Tab – Digital Trust Search, Fraud Heatmap, Trends
class IntelligenceTabScreen extends StatefulWidget {
  const IntelligenceTabScreen({super.key});

  @override
  State<IntelligenceTabScreen> createState() => _IntelligenceTabScreenState();
}

class _IntelligenceTabScreenState extends State<IntelligenceTabScreen> {
  final _searchController = TextEditingController();
  String _selectedLookupType = 'phone';
  bool _isSearching = false;
  Map<String, dynamic>? _searchResult;

  final List<Map<String, dynamic>> _lookupTypes = [
    {'key': 'phone', 'label': 'Phone', 'icon': Icons.phone, 'color': Colors.blue},
    {'key': 'upi', 'label': 'UPI ID', 'icon': Icons.payments, 'color': Colors.green},
    {'key': 'email', 'label': 'Email', 'icon': Icons.email, 'color': Colors.orange},
    {'key': 'url', 'label': 'URL', 'icon': Icons.link, 'color': Colors.red},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performLookup() async {
    final input = _searchController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResult = null;
    });

    try {
      final api = ApiClient();
      ApiResponse response;

      switch (_selectedLookupType) {
        case 'phone':
          response = await api.checkPhoneReputation(input);
          break;
        case 'upi':
          response = await api.checkUpiReputation(input);
          break;
        case 'email':
          response = await api.analyzeText(input);
          break;
        case 'url':
          response = await api.analyzeText(input);
          break;
        default:
          response = await api.analyzeText(input);
      }

      setState(() {
        _searchResult = response.data;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResult = {
          'error': true,
          'message': 'Lookup failed: $e',
          'trust_score': 0,
          'risk_level': 'unknown',
        };
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligence Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => context.push('/heatmap'),
            tooltip: 'Fraud Heatmap',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Digital Trust Search
          _buildSearchCard(theme),
          const SizedBox(height: 20),

          // Fraud Intelligence Graph
          _buildIntelligenceGraphCard(theme),
          const SizedBox(height: 20),

          // National Fraud Trends
          _buildTrendsCard(theme),
          const SizedBox(height: 20),

          // Quick Lookups
          _buildQuickLookups(theme),
          const SizedBox(height: 20),

          // Neo4j Connections
          _buildConnectionsCard(theme),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSearchCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search, color: Colors.indigo, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Digital Trust Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Verify any digital identity', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lookup type selector
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _lookupTypes.length,
                itemBuilder: (ctx, i) {
                  final t = _lookupTypes[i];
                  final selected = _selectedLookupType == t['key'];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(t['label'] as String, style: TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        _selectedLookupType = t['key'] as String;
                        _searchController.clear();
                        _searchResult = null;
                      }),
                      selectedColor: (t['color'] as Color).withValues(alpha: 0.2),
                      checkmarkColor: t['color'] as Color,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _getHintForType(_selectedLookupType),
                prefixIcon: Icon(
                  _lookupTypes.firstWhere((t) => t['key'] == _selectedLookupType)['icon'] as IconData,
                  color: _lookupTypes.firstWhere((t) => t['key'] == _selectedLookupType)['color'] as Color,
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _performLookup,
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              keyboardType: _selectedLookupType == 'phone' ? TextInputType.phone : TextInputType.text,
              onSubmitted: (_) => _performLookup(),
            ),

            // Search result
            if (_searchResult != null) ...[
              const SizedBox(height: 16),
              _buildSearchResult(),
            ],
          ],
        ),
      ),
    );
  }

  String _getHintForType(String type) {
    switch (type) {
      case 'phone': return 'Enter phone number (+91...)';
      case 'upi': return 'Enter UPI ID (name@upi)';
      case 'email': return 'Enter email address';
      case 'url': return 'Enter URL to check';
      default: return 'Enter value to lookup';
    }
  }

  Widget _buildSearchResult() {
    final result = _searchResult!;
    final trustScore = result['trust_score'] ?? result['confidence'] ?? 0;
    final riskLevel = result['risk_level'] ?? result['riskScore'] ?? 'unknown';
    final isHighRisk = riskLevel == 'high' || riskLevel == 'dangerous' || riskLevel == 'critical';
    final color = isHighRisk ? Colors.red : riskLevel == 'medium' ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isHighRisk ? Icons.dangerous : Icons.verified_user, color: color, size: 20),
              const SizedBox(width: 8),
              Text('Trust Score: $trustScore', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Text('${riskLevel}'.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (result['message'] != null) ...[
            const SizedBox(height: 8),
            Text('${result['message']}', style: const TextStyle(fontSize: 12)),
          ],
          if (result['complaint_count'] != null) ...[
            const SizedBox(height: 4),
            Text('Complaints: ${result['complaint_count']}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/report', extra: {
                    'source': 'intelligence',
                    'lookup_type': _selectedLookupType,
                    'input_value': _searchController.text,
                    'result': result,
                  }),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
                  child: Text('Report', style: TextStyle(color: color, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Save', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligenceGraphCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_tree, color: Colors.cyan, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fraud Intelligence Graph', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Neo4j-powered connection analysis', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _graphConnection('Phone', 'UPI', '23 connections', Colors.blue, Colors.green),
            _graphConnection('Phone', 'Device', '15 connections', Colors.blue, Colors.purple),
            _graphConnection('Phone', 'Fraud Report', '8 connections', Colors.blue, Colors.red),
            _graphConnection('Phone', 'Complaint', '5 connections', Colors.blue, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _graphConnection(String from, String to, String count, Color fromColor, Color toColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: fromColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(from, style: TextStyle(color: fromColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: toColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(to, style: TextStyle(color: toColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          Text(count, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTrendsCard(ThemeData theme) {
    final trends = [
      _Trend('KYC Fraud', 342, '+12%', Colors.red),
      _Trend('UPI Scam', 256, '+8%', Colors.orange),
      _Trend('Loan Fraud', 189, '-3%', Colors.green),
      _Trend('Phishing', 167, '+15%', Colors.red),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.trending_up, color: Colors.amber, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('National Fraud Trends', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('This month (India)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...trends.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: t.count / 400,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(t.color),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${t.count}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.color)),
                        Text(t.change, style: TextStyle(
                          fontSize: 10,
                          color: t.change.startsWith('+') ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLookups(ThemeData theme) {
    final lookups = [
      {'title': 'Phone Lookup', 'subtitle': 'Check number reputation', 'icon': Icons.phone, 'color': Colors.blue},
      {'title': 'UPI Lookup', 'subtitle': 'Verify UPI merchant', 'icon': Icons.payments, 'color': Colors.green},
      {'title': 'Email Lookup', 'subtitle': 'Check email sender', 'icon': Icons.email, 'color': Colors.orange},
      {'title': 'URL Lookup', 'subtitle': 'Scan for phishing', 'icon': Icons.link, 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Lookups', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: lookups.length,
          itemBuilder: (ctx, i) {
            final l = lookups[i];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLookupType = l['title'].toString().toLowerCase().split(' ')[0];
                });
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(l['icon'] as IconData, color: l['color'] as Color, size: 22),
                      const SizedBox(height: 6),
                      Text(l['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(l['subtitle'] as String, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConnectionsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.hub, color: Colors.teal, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Connection Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Neo4j graph database visualization', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Entity Relationships', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _entityRow(Icons.phone, 'Phone Numbers', '12,450', Colors.blue),
            _entityRow(Icons.payments, 'UPI IDs', '8,230', Colors.green),
            _entityRow(Icons.device_hub, 'Devices', '5,670', Colors.purple),
            _entityRow(Icons.warning, 'Fraud Reports', '3,890', Colors.red),
            _entityRow(Icons.person, 'Suspects', '1,234', Colors.orange),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/heatmap'),
                icon: const Icon(Icons.map, size: 18),
                label: const Text('View Fraud Heatmap'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entityRow(IconData icon, String label, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _Trend {
  final String name;
  final int count;
  final String change;
  final Color color;
  _Trend(this.name, this.count, this.change, this.color);
}