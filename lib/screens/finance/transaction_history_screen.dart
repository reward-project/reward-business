import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/dio_service.dart';

class TransactionHistory {
  final int id;
  final double amount;
  final String type;
  final String description;
  final DateTime createdAt;
  final double balance;

  TransactionHistory({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
    required this.balance,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null ? 
        DateTime.tryParse(json['createdAt']) ?? DateTime.now() : 
        DateTime.now(),
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  List<TransactionHistory> _histories = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _fetchTransactionHistory(refresh: true);
  }

  void _handleScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _fetchTransactionHistory(refresh: false);
      }
    }
  }

  Future<void> _fetchTransactionHistory({required bool refresh}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioService.instance.get(
        '/members/me/cash-history',
        queryParameters: {
          'page': refresh ? 0 : _currentPage,
          'size': _pageSize,
          'sort': 'transactionDate,desc',
          'type': 'ALL',
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('No data received from server');
        }

        final content = data['content'] as List;
        final totalPages = data['totalPages'] as int;
        
        if (mounted) {
          setState(() {
            if (refresh) {
              _histories = content.map((data) => TransactionHistory.fromJson(data)).toList();
              _currentPage = 1;
            } else {
              _histories.addAll(content.map((data) => TransactionHistory.fromJson(data)).toList());
              _currentPage++;
            }
            _hasMore = _currentPage < totalPages;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('거래 내역'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchTransactionHistory(refresh: true),
        child: _isLoading && _histories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _histories.isEmpty
          ? const Center(child: Text('거래 내역이 없습니다.'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: _histories.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _histories.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final history = _histories[index];
                final isPositive = history.amount > 0;
                
                return ListTile(
                  leading: Icon(
                    isPositive ? Icons.add_circle : Icons.remove_circle,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  title: Text(history.description),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(history.createdAt)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat('+#,###;-#,###').format(history.amount),
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '잔액: ${NumberFormat('#,###').format(history.balance)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 