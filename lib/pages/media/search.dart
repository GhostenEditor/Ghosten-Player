import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _focused = false;

  String get _filter => _searchController.value.text;
  final _focusNode = FocusNode();
  final _clearFocusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(_updateState);
    _searchController.addListener(_updateState);
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
    return Scaffold(
      appBar: AppBar(
        title: IconButtonTheme(
          data: IconButtonThemeData(
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              iconSize: 16,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          child: TextField(
            autofocus: true,
            focusNode: _focusNode,
            controller: _searchController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              filled: true,
              hintText: AppLocalizations.of(context)!.search,
              contentPadding: EdgeInsets.zero,
              prefixIcon: const Icon(Icons.search),
              prefixIconConstraints: const BoxConstraints(maxHeight: 32, minWidth: 32),
              suffix: _filter.isEmpty
                  ? null
                  : IconButton(
                      focusNode: _clearFocusNode,
                      onPressed: () {
                        if (_filter.isNotEmpty) {
                          // widget.onSearch(null);
                        }
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear)),
              suffixIconConstraints: const BoxConstraints(minHeight: 36, minWidth: 36),
              suffixIcon: IconButton(
                  onPressed: () async {
                    // final stt.SpeechToText speech = stt.SpeechToText();
                    // final bool available = await speech.initialize();
                    // if (available) {
                    //   speech.listen(onResult: (_) {});
                    // } else {
                    // print('The user has denied the use of speech recognition.');
                    // }
                    // speech.cancel();
                  },
                  icon: const Icon(Icons.mic_rounded)),
            ),
            onTap: () {},
            onChanged: (_) {},
            onTapOutside: (_) => _focusNode.unfocus(),
            onSubmitted: (res) {
              // setState(() {});
              // _clearFocusNode.requestFocus();
            },
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        ],
      ),
      body: Center(
        child: Text(AppLocalizations.of(context)!.tipsStayTuned),
      ),
    );
  }

  void _updateState() {
    if (!_focusNode.hasFocus && _focused && _filter.isEmpty) {
      setState(() {
        _focused = false;
        _clearFocusNode.unfocus();
        _focusNode.unfocus();
      });
    }
  }
}
