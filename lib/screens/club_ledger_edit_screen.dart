import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/providers/ledger_provider.dart';
import 'package:app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class ClubLedgerEditScreen extends StatefulWidget {
  final Transaction? transaction;

  const ClubLedgerEditScreen({super.key, this.transaction});

  @override
  State<ClubLedgerEditScreen> createState() => _ClubLedgerEditScreenState();
}

class _ClubLedgerEditScreenState extends State<ClubLedgerEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _amountController;
  late TextEditingController _requesterController;
  late TextEditingController _financeController;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  bool _isApproved = false;
  
  String? _receiptPath;
  Uint8List? _receiptBytes; // For Web compatibility

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _titleController = TextEditingController(text: tx?.title ?? '');
    // Provide a default category if editing an existing entry, otherwise empty
    // The Stitch design shows "社團耗材" as placeholder
    _categoryController = TextEditingController(text: tx?.category ?? '');
    _amountController = TextEditingController(text: tx != null ? tx.amount.toString() : '');
    _requesterController = TextEditingController(text: tx?.requester ?? '');
    _financeController = TextEditingController(text: tx?.finance ?? '');
    _selectedDate = tx?.date ?? DateTime.now();
    _selectedType = tx?.type ?? TransactionType.expense;
    _receiptPath = tx?.receiptPath;
    _isApproved = tx?.isApproved ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    _requesterController.dispose();
    _financeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.skyBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _receiptBytes = bytes;
            _receiptPath = image.path; // Keep path as identifier/fallback
          });
        } else {
          setState(() {
            _receiptPath = image.path;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('讀取圖片錯誤: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _saveTransaction() {
    // Basic validation
    if (_titleController.text.trim().isEmpty || _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請填寫必填欄位：品項與金額。'), backgroundColor: Colors.red),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金額必須為有效數字。'), backgroundColor: Colors.red),
      );
      return;
    }

    final provider = Provider.of<LedgerProvider>(context, listen: false);

    final newTx = Transaction(
      id: widget.transaction?.id ?? Random().nextInt(100000).toString(),
      title: _titleController.text.trim(),
      requester: _requesterController.text.trim(),
      finance: _financeController.text.trim(),
      category: _categoryController.text.trim(),
      amount: amount,
      date: _selectedDate,
      type: _selectedType,
      status: widget.transaction?.status ?? '處理中',
      icon: widget.transaction?.icon ?? (_selectedType == TransactionType.income ? Icons.attach_money : Icons.receipt_long),
      receiptPath: _receiptPath,
      isApproved: _isApproved,
    );

    if (widget.transaction == null) {
      provider.addTransaction(newTx);
    } else {
      provider.updateTransaction(newTx);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserProvider>(context).role;
    final canApprove = userRole == '財務長' || userRole == '社長';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '編輯記帳紀錄',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 24),
                    _buildDateField(),
                    const SizedBox(height: 20),
                    _buildInputField('品項', '請輸入品項 (例如：購買社團耗材)', _titleController),
                    const SizedBox(height: 20),
                    _buildInputField('金額', '請輸入金額', _amountController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                    const SizedBox(height: 20),
                    _buildInputField('請款', '請輸入請款人姓名', _requesterController),
                    const SizedBox(height: 20),
                    _buildInputField('財務', '請輸入財務長姓名', _financeController),
                    const SizedBox(height: 20),
                    _buildInputField('備註', '請輸入備註 (選填)', _categoryController),
                    const SizedBox(height: 20),
                    _buildReceiptUpload(),
                    const SizedBox(height: 20),
                    _buildApprovalField(canApprove),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = TransactionType.income),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == TransactionType.income ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _selectedType == TransactionType.income
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Center(
                  child: Text(
                    '收入',
                    style: TextStyle(
                      color: _selectedType == TransactionType.income ? AppTheme.skyBlue : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = TransactionType.expense),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == TransactionType.expense ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _selectedType == TransactionType.expense
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Center(
                  child: Text(
                    '支出',
                    style: TextStyle(
                      color: _selectedType == TransactionType.expense ? Colors.red.shade400 : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '日期',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(_selectedDate),
                  style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
                ),
                Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalField(bool canApprove) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: const Text(
          '此帳目已審核',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        activeColor: AppTheme.skyBlue,
        value: _isApproved,
        onChanged: canApprove
            ? (bool value) {
                setState(() {
                  _isApproved = value;
                });
              }
            : null,
      ),
    );
  }

  Widget _buildReceiptUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '上傳收據 (選填)',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        if (_receiptPath != null || _receiptBytes != null)
           _buildReceiptPreview()
        else
           GestureDetector(
             onTap: _pickImage,
             child: Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 32),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey.shade200, style: BorderStyle.none),
               ),
               child: Column(
                 children: [
                   Icon(Icons.cloud_upload_outlined, color: AppTheme.skyBlue.withValues(alpha: 0.5), size: 40),
                   const SizedBox(height: 12),
                   Text(
                     '點擊或拖曳檔案以上傳',
                     style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     '支援 JPG, PNG 格式',
                     style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                   ),
                 ],
               ),
             ),
           ),
      ],
    );
  }

  Widget _buildReceiptPreview() {
    Widget imageWidget;
    if (kIsWeb && _receiptBytes != null) {
      imageWidget = Image.memory(_receiptBytes!, fit: BoxFit.cover);
    } else if (_receiptPath != null && !kIsWeb) {
      imageWidget = Image.file(File(_receiptPath!), fit: BoxFit.cover);
    } else {
      // Fallback if path exists but doesn't map right due to platform
      imageWidget = const Center(child: Text("已有上傳檔案", style: TextStyle(color: Colors.grey)));
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageWidget,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _receiptPath = null;
                  _receiptBytes = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _deleteTransaction() {
    if (widget.transaction == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除紀錄'),
        content: const Text('確定要刪除這筆記帳紀錄嗎？此動作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<LedgerProvider>(context, listen: false);
              provider.deleteTransaction(widget.transaction!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit screen
            },
            child: const Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _saveTransaction,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.skyBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.skyBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '儲存紀錄',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          if (widget.transaction != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _deleteTransaction,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade400),
                ),
                child: Center(
                  child: Text(
                    '刪除紀錄',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
