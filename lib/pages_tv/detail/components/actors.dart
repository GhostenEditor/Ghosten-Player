import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/focusable_image.dart';

class ActorSection extends StatelessWidget {
  const ActorSection({super.key, required this.actors});

  final List<Actor> actors;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 32),
      itemCount: actors.length,
      itemBuilder: (context, index) => _ActorListTile(actor: actors[index], autofocus: index == 0),
    );
  }
}

class _ActorListTile extends StatefulWidget {
  const _ActorListTile({required this.actor, this.autofocus = false});

  final Actor actor;
  final bool autofocus;

  @override
  State<_ActorListTile> createState() => _ActorListTileState();
}

class _ActorListTileState extends State<_ActorListTile> {
  late final actor = widget.actor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 2,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: FocusableImage(
                autofocus: widget.autofocus,
                poster: actor.profile,
                placeholderIcon: Icons.account_circle_outlined,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actor.name, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                  if (actor.character != null) Text('${AppLocalizations.of(context)!.actAs} ${actor.character}', style: Theme.of(context).textTheme.bodySmall),
                  Text(AppLocalizations.of(context)!.gender(actor.gender.toString())),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xff86caa5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Text('TMDB', style: TextStyle(fontSize: 8, color: Color(0xff86caa5))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
