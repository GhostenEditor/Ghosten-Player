import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../menus/movie.dart';
import '../../../view_models/view_models.dart';
import 'components/components.dart';
import 'titles/movie.dart';

class MoviePage extends StatelessWidget {
  const MoviePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          textStyle: Theme.of(context).textTheme.labelSmall,
          tapTargetSize: .shrinkWrap,
        ),
      ),
      child: ViewModelConsumer<MovieViewModel, Movie>(
        builder: (context, item, _) => DetailScaffold(
          onRefresh: () async => context.read<MovieViewModel>().load(),
          themeColor: item.themeColor,
          image: item.backdrop != null ? AsyncImage(item.backdrop!) : null,
          menus: MovieMenu(item),
          slivers: [
            LogoSection(logo: item.logo),
            TopButtons(item: item, type: .movie),
            MovieTitle(item: item),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            OverviewSection(text: item.overview, poster: item.poster, trimLines: 8),
            StudiosSection(type: MediaType.movie, studios: item.studios),
            GenresSection(type: MediaType.movie, genres: item.genres),
            KeywordsSection(type: MediaType.movie, keywords: item.keywords),
            CastSection(type: MediaType.movie, cast: item.mediaCast),
            CrewSection(type: MediaType.movie, crew: item.mediaCrew),
            if (item.fileId != null) FileInfoSection(fileId: item.fileId!),
          ],
        ),
      ),
    );
  }
}
