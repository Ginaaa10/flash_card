import 'package:flutter/material.dart';
import 'package:flash_card_app/shared/services/ai_service.dart';

class AiConnectDialog extends StatefulWidget {
  const AiConnectDialog({super.key});

  @override
  State<AiConnectDialog> createState() => _AiConnectDialogState();
}

class _AiConnectDialogState extends State<AiConnectDialog> {
  bool _isConnected = false;
  bool _isLoading = true;
  String? _provider;
  bool _obscureKey = true;
  int _tabIndex = 0;
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final connected = await AiService.isConnected;
    final provider = await AiService.getProvider();
    final apiKey = await AiService.getApiKey();
    if (mounted) {
      setState(() {
        _isConnected = connected;
        _provider = provider ?? 'gemini';
        _apiKeyController.text = apiKey ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API key')),
      );
      return;
    }
    await AiService.saveApiKey(_provider!, key);
    if (mounted) {
      setState(() => _isConnected = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI connected successfully')),
      );
    }
  }

  Future<void> _disconnect() async {
    await AiService.clearApiKey();
    if (mounted) {
      setState(() {
        _isConnected = false;
        _apiKeyController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected from AI')),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('AI Connection'),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTab('Connect', 0, Icons.link),
                        ),
                        Expanded(
                          child: _buildTab('Hướng dẫn', 1, Icons.help_outline),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _tabIndex == 0
                        ? _buildConnectTab()
                        : _buildGuideTab(),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    final isSelected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectTab() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isConnected) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connected (${_provider?.toUpperCase()})',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _disconnect,
                icon: const Icon(Icons.link_off, color: Colors.red),
                label: const Text('Disconnect', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const Divider(height: 24),
          ],
          Text(
            'Select AI Provider',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildProviderChip('gemini', 'Gemini'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProviderChip('openai', 'OpenAI'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'API Key',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureKey,
            decoration: InputDecoration(
              hintText: 'Paste your API key here',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveApiKey,
              icon: const Icon(Icons.save),
              label: Text(_isConnected ? 'Update Key' : 'Save & Connect'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    final isGemini = _provider == 'gemini';
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.school, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isGemini ? 'Hướng dẫn lấy API key Gemini miễn phí' : 'Hướng dẫn lấy API key OpenAI',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isGemini)
            ..._buildGeminiGuide()
          else
            ..._buildOpenAiGuide(),
        ],
      ),
    );
  }

  List<Widget> _buildGeminiGuide() {
    return [
      _buildStep(1, 'Vào Google AI Studio', 'Mở trình duyệt và truy cập https://aistudio.google.com'),
      _buildStep(2, 'Đăng nhập bằng tài khoản Google', 'Dùng acc Google của bạn để đăng nhập (miễn phí).'),
      _buildStep(3, 'Bấm "Get API key"', 'Nút nằm ở góc trên bên phải màn hình.'),
      _buildStep(4, 'Chọn "Create API key"', 'Nếu chưa có project, hệ thống sẽ tạo project Google Cloud tự động.'),
      _buildStep(5, 'Copy key', 'Key có dạng AIza... Hãy copy ngay vì chỉ xem được 1 lần.'),
      _buildStep(6, 'Dán vào tab Connect', 'Quay lại tab "Connect", chọn Gemini và dán key vào ô, bấm "Save & Connect".'),
      const SizedBox(height: 8),
      _buildTip('Miễn phí: key Gemini có hạn mức gọi nhất định mỗi ngày, đủ dùng cho quiz học tập.'),
    ];
  }

  List<Widget> _buildOpenAiGuide() {
    return [
      _buildStep(1, 'Vào OpenAI Platform', 'Truy cập https://platform.openai.com và đăng nhập.'),
      _buildStep(2, 'Vào mục "API Keys"', 'Nằm trong menu bên trái của dashboard.'),
      _buildStep(3, 'Bấm "Create new secret key"', 'Đặt tên và bấm tạo.'),
      _buildStep(4, 'Copy key', 'Key hiện 1 lần duy nhất, hãy copy ngay.'),
      _buildStep(5, 'Dán vào tab Connect', 'Quay lại tab "Connect", chọn OpenAI và dán key vào ô, bấm "Save & Connect".'),
      const SizedBox(height: 8),
      _buildTip('Lưu ý: OpenAI có thể tính phí theo lượng sử dụng. Hãy kiểm tra hạn mức tài khoản.'),
    ];
  }

  Widget _buildStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
            ),
            child: Text(
              '$number',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.brown.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderChip(String value, String label) {
    final isSelected = _provider == value;
    return GestureDetector(
      onTap: () => setState(() => _provider = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF764BA2) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
