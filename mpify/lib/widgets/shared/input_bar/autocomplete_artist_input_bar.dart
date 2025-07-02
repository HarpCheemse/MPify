import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:provider/provider.dart';

class AutocompleteArtistInputBar extends StatelessWidget {
  final TextEditingController controller;
  const AutocompleteArtistInputBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    context.read<SongModels>().loadArtistList();
    final List<String> artistList = context.read<SongModels>().artistList;
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        return artistList.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              style: montserratStyle(context: context),
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
              decoration: InputDecoration(
                hintText: 'Artist Name',
                hintStyle: montserratStyle(
                  context: context,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                ),
                fillColor: const Color.fromARGB(134, 95, 95, 95),
                prefixIcon: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            final int highLighted = AutocompleteHighlightedOption.of(context);
            final scrollController = ScrollController();

            final itemKeys = List.generate(options.length, (_) => GlobalKey());

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (highLighted != null &&
                  highLighted >= 0 &&
                  highLighted < itemKeys.length) {
                final key = itemKeys[highLighted];
                if (key.currentContext != null) {
                  Scrollable.ensureVisible(
                    key.currentContext!,
                    duration: const Duration(milliseconds: 100),
                    alignment: 0.5,
                  );
                }
              }
            });
            return Align(
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Material(
                  elevation: 8.0,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: options.length * 60 > 200
                          ? 200
                          : options.length * 60,
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        final bool isHighLighed = index == highLighted;
                        return SizedBox(
                          key: itemKeys[index],
                          width: 100,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Material(
                              color: isHighLighed
                                  ? Theme.of(context).colorScheme.surface
                                  : Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  onSelected(option);
                                },
                                hoverColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    option,
                                    style: montserratStyle(context: context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
    );
  }
}
