import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/custom_modal_bottom_sheet.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/screens/search/views/components/search_form.dart';

import 'components/hot_searches.dart';
import 'components/recent_searches.dart';
import 'components/search_filter.dart';
import 'components/search_resulats.dart';
import 'components/search_suggestions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isShowSuggestions = false;
  bool _isShowSearchResult = false;

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: Image.asset(
          "assets/logo/tklab_logo.png",
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: const [CloseButton()],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: SearchForm(
                  autofocus: true,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    if (value!.length >= 2) {
                      setState(() {
                        _isShowSuggestions = true;
                      });
                    } else {
                      setState(() {
                        _isShowSuggestions = false;
                      });
                    }
                  },
                  onFieldSubmitted: (value) {
                    setState(() {
                      _isShowSearchResult = true;
                    });
                  },
                  onSaved: (value) {},
                  validator: (value) {
                    return null;
                  }, // validate
                  onTabFilter: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: const SearchFilter(),
                    );
                  },
                ),
              ),
            ),
            if (_isFocused && !_isShowSuggestions)
              const SliverToBoxAdapter(
                child: RecentSearches(),
              ),
            if (_isFocused && !_isShowSuggestions)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: defaultPadding),
                  child: HotSearches(),
                ),
              ),
            if (_isFocused && _isShowSuggestions)
              const SliverToBoxAdapter(
                child: SearchSuggestions(),
              ),
            // No Search result

            // const SliverPadding(
            //   padding: EdgeInsets.all(defaultPadding),
            //   sliver: SliverToBoxAdapter(
            //     child: NoSearchResult(),
            //   ),
            // ),

            if (_isShowSearchResult && !_isFocused)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    defaultPadding, defaultPadding / 2, defaultPadding, 0),
                sliver: SliverToBoxAdapter(
                  child: Text.rich(
                    TextSpan(
                      text: "搜尋結果 ",
                      style: Theme.of(context).textTheme.titleSmall,
                      children: [
                        TextSpan(
                          text: "(3 項)",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_isShowSearchResult && !_isFocused) const SearchResulats(),
          ],
        ),
      ),
    );
  }
}
