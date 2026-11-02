import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({super.key, this.autofocus = false, required this.controller, this.onSubmitted});

  final bool autofocus;
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final TextEditingController _searchController = widget.controller;

  final _focusNode = FocusNode();
  final _clearFocusNode = FocusNode();

  String get _filter => _searchController.value.text;

  @override
  void dispose() {
    _focusNode.dispose();
    _clearFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return TextField(
      autofocus: widget.autofocus,
      focusNode: _focusNode,
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        isDense: true,
        visualDensity: .compact,
        filled: true,
        hintText: AppLocalizations.of(context)!.searchHint,
        hintStyle: Theme.of(context).textTheme.labelMedium,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _filter.isEmpty
            ? const Icon(null)
            : IconButton(
                focusNode: _clearFocusNode,
                onPressed: () {
                  _searchController.clear();
                  widget.onSubmitted?.call(_searchController.text);
                  setState(() {});
                },
                style: const ButtonStyle(tapTargetSize: .shrinkWrap),
                icon: const Icon(Icons.clear),
              ),
      ),
      onChanged: (_) {
        setState(() {});
      },
      onTapOutside: (_) => _focusNode.unfocus(),
      onSubmitted: widget.onSubmitted,
    );
  }
}
