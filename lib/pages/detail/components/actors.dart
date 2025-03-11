import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/utils.dart';
import '../../components/image_card.dart';
import '../../media/filter.dart';

class ActorsSection extends StatelessWidget {
  const ActorsSection({super.key, required this.actors});

  final List<Actor> actors;

  @override
  Widget build(BuildContext context) {
    return actors.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(AppLocalizations.of(context)!.titleCast, style: Theme.of(context).textTheme.titleMedium),
              ),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  itemCount: actors.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final actor = actors[index];
                    return ImageCard(
                      actor.profile,
                      width: 120,
                      height: 180,
                      title: Text(actor.name),
                      subtitle: actor.character != null ? Text('${AppLocalizations.of(context)!.actAs} ${actor.character}') : null,
                      onTap: () => navigateTo(context, FilterPage(queryType: QueryType.actor, id: actor.id)),
                    );
                  },
                ),
              ),
            ],
          )
        : Container();
  }
}
