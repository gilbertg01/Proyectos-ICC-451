import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../entidades/pokemon_data.dart';

class PokemonCard extends StatelessWidget {
  final PokemonData pokemonResult;

  const PokemonCard({super.key, required this.pokemonResult});

  @override
  Widget build(BuildContext context) {
    final String id = pokemonResult.id;
    String imageUrl = pokemonResult.imageUrl;

    return InkWell(
      onTap: () {
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: SvgPicture.asset(
                      "lib/images/pokeball.svg",
                      width: MediaQuery.of(context).size.width / 3.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Hero(
                      tag: id,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blueAccent,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Column(
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 40),
                              const SizedBox(height: 4),
                              const Text(
                                'Imagen no disponible',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              pokemonResult.name,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "#${id.padLeft(5, '0')}",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
