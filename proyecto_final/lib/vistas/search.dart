import 'package:flutter/material.dart';
import '../widgets/search_widget.dart';
import '../main.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  void showErrorSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (MediaQuery.of(context).viewInsets.bottom > 0) {
              FocusManager.instance.primaryFocus?.unfocus();
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        backgroundColor: Colors.black,
        title: const Text(
          'Search Pokemons',
          style: TextStyle(
            color: Colors.yellowAccent,
            fontFamily: "PokemonBold",
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SearchWidget(onError: showErrorSnackBar),
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
