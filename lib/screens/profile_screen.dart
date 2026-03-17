import 'package:flutter/material.dart';
import 'package:app/services/supabase_service.dart';
import 'package:app/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 底部導覽列當前選擇索引 (個人: 3)
  int _currentIndex = 3;
  bool _isLoading = true;
  User? _currentUser;

  // 初始化所有控制器
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _gradeController;
  late TextEditingController _genderController;
  late TextEditingController _lineIdController;
  late TextEditingController _instagramController;
  late TextEditingController _birthDateController;
  late TextEditingController _clubRoleController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadUserData();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _studentIdController = TextEditingController();
    _phoneController = TextEditingController();
    _departmentController = TextEditingController();
    _gradeController = TextEditingController();
    _genderController = TextEditingController();
    _lineIdController = TextEditingController();
    _instagramController = TextEditingController();
    _birthDateController = TextEditingController();
    _clubRoleController = TextEditingController();
  }

  void _loadUserData() async {
    try {
      final supabaseService = SupabaseService();
      final user = await supabaseService.fetchCurrentUser();
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _updateControllers(user);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加載用戶數據失敗: $e')),
        );
      }
    }
  }

  void _updateControllers(User? user) {
    if (user == null) return;
    
    _nameController.text = user.name;
    _studentIdController.text = user.studentId ?? '';
    _phoneController.text = user.phone ?? '';
    _departmentController.text = user.department ?? '';
    _gradeController.text = user.grade ?? '';
    _genderController.text = user.gender ?? '';
    _lineIdController.text = user.lineId ?? '';
    _instagramController.text = user.instagram ?? '';
    _birthDateController.text = user.birthday?.toString().split(' ')[0] ?? '';
    _clubRoleController.text = user.clubRole ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _gradeController.dispose();
    _genderController.dispose();
    _lineIdController.dispose();
    _instagramController.dispose();
    _birthDateController.dispose();
    _clubRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF5FB),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF4AA2E8)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FB), // 淡灰藍色背景
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildAvatarSection(),
                    const SizedBox(height: 24),
                    _buildFormSection(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 頂部導覽列
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4AA2E8)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            '編輯個人資料',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          // 右側圓形漸層裝飾
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF), Color(0xFF65B6FF)],
                stops: [0.2, 0.6, 1.0],
              ),
              border: Border.all(color: const Color(0xFF81C1FB), width: 2),
            ),
          ),
        ],
      ),
    );
  }

  // 大頭貼與社團資訊區塊
  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // 外層白色與米色雙重邊框
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5D5C5), // 圖片底色
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              // 這裡暫時用 Icon 代替圖片中的人像，實務上可換成 Image.network 或 Image.asset
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            // 編輯按鈕 (藍底白筆)
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF4AA2E8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '淡江大學禪學社',
          style: TextStyle(
            color: Color(0xFF4AA2E8),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'TKU Zen Club Member',
          style: TextStyle(
            color: Color(0xFF7F8C8D),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 白色表單卡片區塊
  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本信息
          const Text(
            '基本信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField('姓名', _nameController),
          const SizedBox(height: 16),
          _buildInputField('學號', _studentIdController),
          const SizedBox(height: 16),
          _buildInputField('手機號碼', _phoneController),
          const SizedBox(height: 16),
          _buildInputField('性別', _genderController),
          const SizedBox(height: 16),
          _buildInputField('出生日期 (YYYY-MM-DD)', _birthDateController),

          const SizedBox(height: 28),
          // 教育信息
          const Text(
            '教育信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField('系級', _departmentController),
          const SizedBox(height: 16),
          _buildInputField('年級', _gradeController),

          const SizedBox(height: 28),
          // 社團信息
          const Text(
            '社團信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField('社團職位', _clubRoleController),

          const SizedBox(height: 28),
          // 聯絡與社交
          const Text(
            '聯絡與社交',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField('LINE ID', _lineIdController),
          const SizedBox(height: 16),
          _buildInputField('Instagram 帳號', _instagramController),
        ],
      ),
    );
  }

  // 獨立的輸入框元件
  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C3E50),
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
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2C3E50),
              height: 1.5, // 增加行高讓多行文字更好閱讀
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // 底部保存修改按鈕
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saveUserData,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF53A6ED), // 主按鈕藍色
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              '保存修改',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveUserData() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法獲取用戶信息')),
      );
      return;
    }

    try {
      final supabaseService = SupabaseService();
      
      // 解析生日
      DateTime? birthDate;
      if (_birthDateController.text.isNotEmpty) {
        try {
          birthDate = DateTime.parse(_birthDateController.text);
        } catch (e) {
          print('生日解析失敗: $e');
        }
      }

      // 構建更新數據
      final updateData = {
        'name': _nameController.text,
        'student_id': _studentIdController.text.isNotEmpty ? _studentIdController.text : null,
        'phone': _phoneController.text.isNotEmpty ? _phoneController.text : null,
        'department': _departmentController.text.isNotEmpty ? _departmentController.text : null,
        'grade': _gradeController.text.isNotEmpty ? _gradeController.text : null,
        'gender': _genderController.text.isNotEmpty ? _genderController.text : null,
        'line_id': _lineIdController.text.isNotEmpty ? _lineIdController.text : null,
        'instagram': _instagramController.text.isNotEmpty ? _instagramController.text : null,
        'birthday': birthDate?.toIso8601String(),
        'club_role': _clubRoleController.text.isNotEmpty ? _clubRoleController.text : null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 調用 supabase 更新
      await supabaseService.client
          .from('users')
          .update(updateData)
          .eq('id', _currentUser!.id);

      // 重新加載數據
      _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ 資料已保存'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('保存數據失敗: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失敗: $e')),
        );
      }
    }
  }

  // 底部導覽列
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4AA2E8),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '帳本',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '行事曆',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '個人',
          ),
        ],
      ),
    );
  }
}