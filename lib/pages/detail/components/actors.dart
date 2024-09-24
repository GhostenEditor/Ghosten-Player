import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/image_card.dart';
import '../../../components/scrollbar.dart';
import '../../../utils/utils.dart';
import '../../media/filter.dart';

class ActorsSection extends StatelessWidget {
  final List<Actor> actors;

  const ActorsSection({super.key, required this.actors});

  @override
  Widget build(BuildContext context) {
    return actors.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(AppLocalizations.of(context)!.titleCast, style: Theme.of(context).textTheme.titleLarge),
              ),
              SizedBox(
                height: 290,
                child: ScrollbarListView.builder(
                  itemCount: actors.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final actor = actors[index];
                    return ImageCard(
                      image: actor.profile,
                      scale: 1.05,
                      width: 140,
                      onTap: () => navigateTo(context, FilterPage(queryType: QueryType.actor, id: actor.id)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(actor.name, overflow: TextOverflow.ellipsis),
                          if (actor.character != null)
                            Text('${AppLocalizations.of(context)!.actAs} ${actor.character}',
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall)
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : Container();
  }
}
