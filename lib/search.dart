import 'package:flutter/material.dart';
import 'Rolls/roll.dart';
import 'Rolls/user_mappings.dart';

class SearchCadet extends StatefulWidget {
  final String rollname;

  const SearchCadet({Key? key, required this.rollname}) : super(key: key);

  @override
  State<SearchCadet> createState() => _SearchCadetState();
}

class _SearchCadetState extends State<SearchCadet> {
  final TextEditingController _textEditingController = TextEditingController();
  String _lastSuccessfulMark = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Search Cadet"),
      content: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(
                color: Color(0xFF1d572d),
                width: 2.0,
              ),
            ),
            color: const Color(0xff12261e),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  children: [
                    const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    const Text(
                      '  Last successful mark:    ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_lastSuccessfulMark.split(" - ")[0]),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF30363d),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return UserMappings.getAllNames().where(
                  (String option) {
                    return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                  },
                );
              },
              onSelected: (String selection) {},
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                _textEditingController.value = textEditingController.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        onSubmitted: (String value) {
                          _lastSuccessfulMark = value;
                          RollManager.addAttendee(
                              widget.rollname, UserMappings.getId(value));
                          setState(() {});
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        textEditingController.clear();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _lastSuccessfulMark = textEditingController.text;
                        RollManager.addAttendee(widget.rollname,
                            UserMappings.getId(textEditingController.text));
                        setState(() {});
                      },
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
