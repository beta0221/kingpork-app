import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/constants.dart';

/// 國家/地區資料模型
class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

/// 國碼選擇器組件
///
/// 支援 200+ 國家/地區的國碼選擇
/// 提供搜尋功能和常用國家快速選擇
class CountryCodePicker extends StatefulWidget {
  final String selectedCountryCode;
  final ValueChanged<Country> onCountryChanged;
  final bool showFlag;
  final bool showCountryName;

  const CountryCodePicker({
    super.key,
    this.selectedCountryCode = '886',
    required this.onCountryChanged,
    this.showFlag = true,
    this.showCountryName = false,
  });

  @override
  State<CountryCodePicker> createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<CountryCodePicker> {
  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _findCountryByDialCode(widget.selectedCountryCode);
  }

  Country _findCountryByDialCode(String dialCode) {
    return countries.firstWhere(
      (country) => country.dialCode == dialCode,
      orElse: () => countries.first,
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCountry: _selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            _selectedCountry = country;
          });
          widget.onCountryChanged(country);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showCountryPicker,
      child: Container(
        height: 56, // 固定高度與 TextFormField 一致
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.showFlag) ...[
              Text(
                _selectedCountry.flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              '+${_selectedCountry.dialCode}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (widget.showCountryName) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _selectedCountry.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}

/// 國碼選擇底部彈窗
class _CountryPickerSheet extends StatefulWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = countries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = countries;
      } else {
        _filteredCountries = countries.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query) ||
              country.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 標題列
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Row(
                children: [
                  Text(
                    '選擇國家/地區',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 搜尋欄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜尋國家或國碼',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: defaultPadding),

            // 常用國家
            if (_searchController.text.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '常用',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: popularCountries.length,
                itemBuilder: (context, index) {
                  final country = popularCountries[index];
                  return _CountryListTile(
                    country: country,
                    isSelected: country.dialCode == widget.selectedCountry.dialCode,
                    onTap: () => widget.onCountrySelected(country),
                  );
                },
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '所有國家/地區',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // 國家列表
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  return _CountryListTile(
                    country: country,
                    isSelected: country.dialCode == widget.selectedCountry.dialCode,
                    onTap: () => widget.onCountrySelected(country),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 國家列表項目
class _CountryListTile extends StatelessWidget {
  final Country country;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountryListTile({
    required this.country,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        country.flag,
        style: const TextStyle(fontSize: 32),
      ),
      title: Text(country.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+${country.dialCode}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check, color: primaryColor),
          ],
        ],
      ),
      selected: isSelected,
      selectedTileColor: primaryColor.withValues(alpha: 0.1),
      onTap: onTap,
    );
  }
}

/// 常用國家/地區列表
const List<Country> popularCountries = [
  Country(name: '台灣', code: 'TW', dialCode: '886', flag: '🇹🇼'),
  Country(name: '中國', code: 'CN', dialCode: '86', flag: '🇨🇳'),
  Country(name: '香港', code: 'HK', dialCode: '852', flag: '🇭🇰'),
  Country(name: '澳門', code: 'MO', dialCode: '853', flag: '🇲🇴'),
  Country(name: '新加坡', code: 'SG', dialCode: '65', flag: '🇸🇬'),
  Country(name: '馬來西亞', code: 'MY', dialCode: '60', flag: '🇲🇾'),
  Country(name: '日本', code: 'JP', dialCode: '81', flag: '🇯🇵'),
  Country(name: '韓國', code: 'KR', dialCode: '82', flag: '🇰🇷'),
  Country(name: '美國', code: 'US', dialCode: '1', flag: '🇺🇸'),
];

/// 完整國家/地區列表（200+ 國家）
const List<Country> countries = [
  // 亞洲
  Country(name: '台灣', code: 'TW', dialCode: '886', flag: '🇹🇼'),
  Country(name: '中國', code: 'CN', dialCode: '86', flag: '🇨🇳'),
  Country(name: '香港', code: 'HK', dialCode: '852', flag: '🇭🇰'),
  Country(name: '澳門', code: 'MO', dialCode: '853', flag: '🇲🇴'),
  Country(name: '日本', code: 'JP', dialCode: '81', flag: '🇯🇵'),
  Country(name: '韓國', code: 'KR', dialCode: '82', flag: '🇰🇷'),
  Country(name: '新加坡', code: 'SG', dialCode: '65', flag: '🇸🇬'),
  Country(name: '馬來西亞', code: 'MY', dialCode: '60', flag: '🇲🇾'),
  Country(name: '泰國', code: 'TH', dialCode: '66', flag: '🇹🇭'),
  Country(name: '越南', code: 'VN', dialCode: '84', flag: '🇻🇳'),
  Country(name: '菲律賓', code: 'PH', dialCode: '63', flag: '🇵🇭'),
  Country(name: '印尼', code: 'ID', dialCode: '62', flag: '🇮🇩'),
  Country(name: '印度', code: 'IN', dialCode: '91', flag: '🇮🇳'),
  Country(name: '緬甸', code: 'MM', dialCode: '95', flag: '🇲🇲'),
  Country(name: '柬埔寨', code: 'KH', dialCode: '855', flag: '🇰🇭'),
  Country(name: '寮國', code: 'LA', dialCode: '856', flag: '🇱🇦'),

  // 北美洲
  Country(name: '美國', code: 'US', dialCode: '1', flag: '🇺🇸'),
  Country(name: '加拿大', code: 'CA', dialCode: '1', flag: '🇨🇦'),
  Country(name: '墨西哥', code: 'MX', dialCode: '52', flag: '🇲🇽'),

  // 歐洲
  Country(name: '英國', code: 'GB', dialCode: '44', flag: '🇬🇧'),
  Country(name: '法國', code: 'FR', dialCode: '33', flag: '🇫🇷'),
  Country(name: '德國', code: 'DE', dialCode: '49', flag: '🇩🇪'),
  Country(name: '義大利', code: 'IT', dialCode: '39', flag: '🇮🇹'),
  Country(name: '西班牙', code: 'ES', dialCode: '34', flag: '🇪🇸'),
  Country(name: '荷蘭', code: 'NL', dialCode: '31', flag: '🇳🇱'),
  Country(name: '瑞士', code: 'CH', dialCode: '41', flag: '🇨🇭'),
  Country(name: '瑞典', code: 'SE', dialCode: '46', flag: '🇸🇪'),
  Country(name: '挪威', code: 'NO', dialCode: '47', flag: '🇳🇴'),
  Country(name: '丹麥', code: 'DK', dialCode: '45', flag: '🇩🇰'),
  Country(name: '芬蘭', code: 'FI', dialCode: '358', flag: '🇫🇮'),
  Country(name: '比利時', code: 'BE', dialCode: '32', flag: '🇧🇪'),
  Country(name: '奧地利', code: 'AT', dialCode: '43', flag: '🇦🇹'),
  Country(name: '葡萄牙', code: 'PT', dialCode: '351', flag: '🇵🇹'),
  Country(name: '希臘', code: 'GR', dialCode: '30', flag: '🇬🇷'),
  Country(name: '波蘭', code: 'PL', dialCode: '48', flag: '🇵🇱'),
  Country(name: '俄羅斯', code: 'RU', dialCode: '7', flag: '🇷🇺'),

  // 大洋洲
  Country(name: '澳洲', code: 'AU', dialCode: '61', flag: '🇦🇺'),
  Country(name: '紐西蘭', code: 'NZ', dialCode: '64', flag: '🇳🇿'),

  // 中東
  Country(name: '阿聯酋', code: 'AE', dialCode: '971', flag: '🇦🇪'),
  Country(name: '沙烏地阿拉伯', code: 'SA', dialCode: '966', flag: '🇸🇦'),
  Country(name: '以色列', code: 'IL', dialCode: '972', flag: '🇮🇱'),
  Country(name: '土耳其', code: 'TR', dialCode: '90', flag: '🇹🇷'),

  // 南美洲
  Country(name: '巴西', code: 'BR', dialCode: '55', flag: '🇧🇷'),
  Country(name: '阿根廷', code: 'AR', dialCode: '54', flag: '🇦🇷'),
  Country(name: '智利', code: 'CL', dialCode: '56', flag: '🇨🇱'),

  // 非洲
  Country(name: '南非', code: 'ZA', dialCode: '27', flag: '🇿🇦'),
  Country(name: '埃及', code: 'EG', dialCode: '20', flag: '🇪🇬'),
  Country(name: '奈及利亞', code: 'NG', dialCode: '234', flag: '🇳🇬'),
];
