import 'package:flutter/material.dart';
import 'package:app/theme/app_icons.dart';

enum TransactionType { income, expense }

/// 交易记录模型
class Transaction {
  final String id;
  final String title;
  final String requesterId;
  final String financeId;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String status;
  final int iconCode; // 使用 int 代码而不是 IconData
  final String? receiptPath;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    required this.title,
    required this.requesterId,
    required this.financeId,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    required this.iconCode,
    this.receiptPath,
    this.isApproved = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// 获取 IconData 对象 - 返回常用图标
  IconData getIcon() {
    if (type == TransactionType.income) {
      return AppIcons.attachMoney;
    } else {
      return AppIcons.receiptLong;
    }
  }

  /// 从 JSON 创建 Transaction 对象
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      requesterId: json['requester_id'] as String,
      financeId: json['finance_id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      type: (json['type'] as String) == 'income' ? TransactionType.income : TransactionType.expense,
      status: json['status'] as String,
      iconCode: int.parse(json['icon'] as String),
      receiptPath: json['receipt_path'] as String?,
      isApproved: json['is_approved'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'requester_id': requesterId,
      'finance_id': financeId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      'status': status,
      'icon': iconCode.toString(),
      'receipt_path': receiptPath,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 复制对象并修改某些字段
  Transaction copyWith({
    String? id,
    String? title,
    String? requesterId,
    String? financeId,
    String? category,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? status,
    int? iconCode,
    String? receiptPath,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      requesterId: requesterId ?? this.requesterId,
      financeId: financeId ?? this.financeId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      iconCode: iconCode ?? this.iconCode,
      receiptPath: receiptPath ?? this.receiptPath,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
