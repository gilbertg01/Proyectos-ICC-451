import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../entidades/pokemon_data.dart';
import '../servicios/pokemon_favorites_controller.dart';
import '../widgets/menu_widget.dart';
import '../servicios/graphql_calls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PerfilPokemon extends StatefulWidget {
  final int currentIndex;
  final List<PokemonData> pokemonList;

  const PerfilPokemon({super.key, required this.currentIndex, required this.pokemonList});

  @override
  State<PerfilPokemon> createState() => _PerfilPokemonState();
}

class _PerfilPokemonState extends State<PerfilPokemon> {
  late int currentPokemonIndex;
  late PokemonData currentPokemon;
  late Color cardColor;
  bool isLoading = true;
  bool isFavorite = false;
  final PokemonFavoritesController favoritesController = PokemonFavoritesController();

  final Map<String, Color> typeColors = {
    "normal": Colors.brown,
    "fighting": Colors.orange,
    "flying": Colors.blue,
    "poison": Colors.purple,
    "ground": Colors.brown,
    "rock": Colors.grey,
    "bug": Colors.lightGreen,
    "ghost": Colors.indigo,
    "steel": Colors.blueGrey,
    "fire": Colors.redAccent,
    "water": Colors.blue,
    "grass": Colors.green,
    "electric": Colors.yellow,
    "psychic": Colors.pink,
    "ice": Colors.cyan,
    "dragon": Colors.indigo,
    "dark": Colors.black,
    "fairy": Colors.pinkAccent,
  };

  final GraphQLCalls _graphqlCalls = GraphQLCalls();

  @override
  void initState() {
    super.initState();
    currentPokemonIndex = widget.currentIndex;
    currentPokemon = widget.pokemonList[currentPokemonIndex];
    _setCardColor();
    favoritesController.init().then((_) {
      _checkIfFavorite();
    });
    _fetchPokemonDetails();
  }

  void _setCardColor() {
    if (currentPokemon.types.isNotEmpty) {
      final primaryType = currentPokemon.types.first.toLowerCase();
      cardColor = typeColors[primaryType] ?? Colors.grey;
    } else {
      cardColor = Colors.grey;
    }
  }

  Future<void> _fetchPokemonDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final details = await _graphqlCalls.getPokemonDetails(currentPokemon.id);
      if (mounted) {
        setState(() {
          currentPokemon = details;
          _setCardColor();
        });
        _checkIfFavorite();
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _checkIfFavorite() async {
    bool favoriteStatus = await favoritesController.isPokemonFavorite(currentPokemon.id);
    if (mounted) {
      setState(() {
        isFavorite = favoriteStatus;
      });
    }
  }

  void _toggleFavorite() async {
    await favoritesController.toggleFavoritePokemon(currentPokemon.id);
    _checkIfFavorite();
  }

  void _goToNextPokemon() {
    if (currentPokemonIndex < widget.pokemonList.length - 1) {
      setState(() {
        currentPokemonIndex++;
        currentPokemon = widget.pokemonList[currentPokemonIndex];
        _setCardColor();
      });
      _fetchPokemonDetails();
    }
  }

  void _goToPreviousPokemon() {
    if (currentPokemonIndex > 0) {
      setState(() {
        currentPokemonIndex--;
        currentPokemon = widget.pokemonList[currentPokemonIndex];
        _setCardColor();
      });
      _fetchPokemonDetails();
    }
  }

  Future<Uint8List> _createShareableImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(400, 600);
    final paint = Paint()..color = cardColor;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final imageProvider = NetworkImage(currentPokemon.imageUrl);
    final completer = Completer<ui.Image>();
    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }, onError: (dynamic exception, StackTrace? stackTrace) {
        completer.completeError(exception, stackTrace);
      }),
    );

    try {
      final ui.Image image = await completer.future;

      final double imageWidth = 180;
      final double imageHeight = 200;
      final Offset imageOffset = Offset(25, 25);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(imageOffset.dx, imageOffset.dy, imageWidth, imageHeight),
        Paint(),
      );

      final nameTextStyle = TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
          fontFamily: "PokemonSolid"
      );

      final nameTextSpan = TextSpan(
        text: "${currentPokemon.name.toUpperCase()} #${currentPokemon.id}",
        style: nameTextStyle,
      );

      final nameTextPainter = TextPainter(
        text: nameTextSpan,
        textDirection: TextDirection.ltr,
      );

      nameTextPainter.layout(
        minWidth: 0,
        maxWidth: size.width - imageOffset.dx - imageWidth - 25,
      );

      final Offset nameTextOffset = Offset(
        imageOffset.dx + imageWidth + 25,
        imageOffset.dy + (imageHeight / 2) - (nameTextPainter.height / 2),
      );

      nameTextPainter.paint(canvas, nameTextOffset);

      double currentY = imageOffset.dy + imageHeight + 25;

      if (currentPokemon.stats != null) {
        final statsTitleStyle = TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
            fontFamily: "PokemonSolid"
        );

        final statsTitleSpan = TextSpan(
          text: "Stats:",
          style: statsTitleStyle,
        );

        final statsTitlePainter = TextPainter(
          text: statsTitleSpan,
          textDirection: TextDirection.ltr,
        );

        statsTitlePainter.layout(
          minWidth: 0,
          maxWidth: size.width - 50,
        );

        statsTitlePainter.paint(canvas, Offset(25, currentY));
        currentY += statsTitlePainter.height + 10;

        final statsTextStyle = TextStyle(
          color: Colors.white,
          fontSize: 20,
            fontFamily: "PokemonBold"
        );

        final stats = currentPokemon.stats!;
        final statsInfo = "HP: ${stats.hp ?? 'N/A'}\n"
            "Attack: ${stats.attack ?? 'N/A'}\n"
            "Defense: ${stats.defense ?? 'N/A'}\n"
            "Sp. Atk: ${stats.specialAttack ?? 'N/A'}\n"
            "Sp. Def: ${stats.specialDefence ?? 'N/A'}\n"
            "Speed: ${stats.speed ?? 'N/A'}";

        final statsSpan = TextSpan(
          text: statsInfo,
          style: statsTextStyle,
        );

        final statsPainter = TextPainter(
          text: statsSpan,
          textDirection: TextDirection.ltr,
        );

        statsPainter.layout(
          minWidth: 0,
          maxWidth: size.width - 50,
        );

        statsPainter.paint(canvas, Offset(25, currentY));
        currentY += statsPainter.height + 25;
      }

      if (currentPokemon.info != null || currentPokemon.moreInfo != null) {
        final infoTitleStyle = TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
            fontFamily: "PokemonSolid"
        );

        final infoTitleSpan = TextSpan(
          text: "Info:",
          style: infoTitleStyle,
        );

        final infoTitlePainter = TextPainter(
          text: infoTitleSpan,
          textDirection: TextDirection.ltr,
        );

        infoTitlePainter.layout(
          minWidth: 0,
          maxWidth: size.width - 50,
        );

        infoTitlePainter.paint(canvas, Offset(25, currentY));
        currentY += infoTitlePainter.height + 10;

        final infoTextStyle = TextStyle(
          color: Colors.white,
          fontSize: 20,
            fontFamily: "PokemonBold"
        );

        String infoData = "";

        if (currentPokemon.info != null) {
          infoData += "Habitat: ${currentPokemon.info!.habitat}\n";
          infoData += "Capture Rate: ${currentPokemon.info!.captureRate}\n";
          infoData += "Base Happiness: ${currentPokemon.info!.baseHappiness}\n";
          infoData += "Growth Rate: ${currentPokemon.info!.growthRate}\n";
          infoData += "Egg Groups: ${currentPokemon.info!.eggGroups.join(', ')}\n";
        }

        if (currentPokemon.moreInfo != null) {
          infoData += "Height: ${currentPokemon.moreInfo!.height ?? 'N/A'}\n";
          infoData += "Weight: ${currentPokemon.moreInfo!.weight ?? 'N/A'}\n";
          infoData += "Abilities: ${currentPokemon.moreInfo!.abilities?.join(', ') ?? 'N/A'}\n";
        }

        final infoSpan = TextSpan(
          text: infoData,
          style: infoTextStyle,
        );

        final infoPainter = TextPainter(
          text: infoSpan,
          textDirection: TextDirection.ltr,
        );

        infoPainter.layout(
          minWidth: 0,
          maxWidth: size.width - 50,
        );

        infoPainter.paint(canvas, Offset(25, currentY));
        currentY += infoPainter.height + 25;
      }

    } catch (e) {
      print('Error al generar la imagen: $e');
      rethrow;
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _sharePokemon() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de almacenamiento denegado')),
          );
        }
        return;
      }

      final Uint8List imageBytes = await _createShareableImage();

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/pokemon_${currentPokemon.id}.png';
      final file = await File(filePath).create();
      await file.writeAsBytes(imageBytes);

      final xFile = XFile(filePath);

      if (mounted) {
        await Share.shareXFiles(
          [xFile],
          text: 'Look at ${currentPokemon.name} #${currentPokemon.id} in my Pokedex!',
          subject: 'Pokedex',
        );
      }
    } catch (e) {
      print('Error al compartir: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${currentPokemon.name} #${currentPokemon.id}",
          style: const TextStyle(
            color: Colors.yellowAccent,
            fontFamily: 'PokemonBold',
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: _sharePokemon,
          ),
        ],
        centerTitle: true,
      ),
      backgroundColor: cardColor,
      body: Stack(
        children: [
          Container(
            color: cardColor,
          ),
          Column(
            children: <Widget>[
              Container(
                color: cardColor,
                width: double.infinity,
                child: Column(
                  children: [
                    Hero(
                      tag: currentPokemon.id,
                      child: CachedNetworkImage(
                        imageUrl: currentPokemon.imageUrl,
                        height: 200,
                        width: 200,
                        placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Container(
                  color: cardColor,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : MenuWidget(
                  pokemon: currentPokemon,
                  menuColor: cardColor,
                ),
              ),
            ],
          ),
          if (widget.pokemonList.length > 1) ...[
            Positioned(
              left: 16,
              top: 120,
              child: Visibility(
                visible: currentPokemonIndex > 0,
                child: FloatingActionButton(
                  heroTag: "prev_$currentPokemonIndex",
                  onPressed: _goToPreviousPokemon,
                  backgroundColor: Colors.yellowAccent,
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 120,
              child: Visibility(
                visible: currentPokemonIndex < widget.pokemonList.length - 1,
                child: FloatingActionButton(
                  heroTag: "next_$currentPokemonIndex",
                  onPressed: _goToNextPokemon,
                  backgroundColor: Colors.yellowAccent,
                  child: const Icon(Icons.arrow_forward, color: Colors.black),
                ),
              ),
            ),
          ],
          if (isLoading)
            Container(
              color: cardColor.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
