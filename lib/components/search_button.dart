import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'mobile_builder.dart';

class SearchButton extends StatefulWidget {
  final ValueChanged<String?> onSearch;

  const SearchButton({super.key, required this.onSearch});

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  final TextEditingController _searchController = TextEditingController();
  bool _focused = false;

  String get _filter => _searchController.value.text;
  final _focusNode = FocusNode();
  final _clearFocusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(updateState);
    _searchController.addListener(updateState);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _clearFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 60, right: 8),
      child: TextField(
        focusNode: _focusNode,
        controller: _searchController,
        decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            hintText: AppLocalizations.of(context)!.search,
            contentPadding: EdgeInsets.zero,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _filter.isEmpty
                ? null
                : IconButton(
                    focusNode: _clearFocusNode,
                    onPressed: () {
                      if (_filter.isNotEmpty) {
                        widget.onSearch(null);
                      }
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear))),
        onTap: () {},
        onChanged: (_) {},
        onTapOutside: (_) => _focusNode.unfocus(),
        onSubmitted: (res) {
          setState(() {});
          _clearFocusNode.requestFocus();
          final search = res.trim();
          widget.onSearch(search.isEmpty ? null : search);
        },
      ),
    );
    return MobileBuilder(
        builder: (context, isMobile, _) => isMobile
            ? Expanded(child: Padding(padding: const EdgeInsets.only(left: 8), child: search))
            : _focused
                ? SizedBox(width: 300, child: search)
                : IconButton(
                    onPressed: () {
                      setState(() {
                        _focused = true;
                      });
                      _focusNode.requestFocus();
                    },
                    icon: const Icon(Icons.search)));
  }

  updateState() {
    if (!_focusNode.hasFocus && _focused && _filter.isEmpty) {
      setState(() {
        _focused = false;
        _clearFocusNode.unfocus();
        _focusNode.unfocus();
      });
    }
  }
}
