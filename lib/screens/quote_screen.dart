import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const QuoteScreen({super.key, this.onToggleTheme});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String quote = 'Нажми кнопку, чтобы получить цитату.';
  List<String> favorites = [];
  List<String> history = [];
  String selectedCategory = 'motivation';

  final Map<String, String> categories = {
    'motivation': 'Мотивация',
    'humor': 'Юмор',
    'wisdom': 'Мудрость',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedQuotes();
  }

  Future<void> _loadSavedQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
      history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _saveQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites);
    await prefs.setStringList('history', history);
  }

  Future<void> fetchQuote() async {
    try {
      final response = await http.get(
  Uri.parse('http://127.0.0.1:5055/quote?category=$selectedCategory'),
);



      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newQuote = data['quote'];

        setState(() {
          quote = newQuote;
          if (!history.contains(newQuote)) {
            history.insert(0, newQuote);
            if (history.length > 20) history.removeLast();
          }
        });

        _saveQuotes();
      } else {
        setState(() => quote = 'Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => quote = 'Ошибка подключения к серверу.');
    }
  }

  Future<void> fetchQuoteFromAI() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5050/gpt-quote?category=$selectedCategory'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiQuote = data['quote'];

        setState(() {
          quote = aiQuote;
          if (!history.contains(aiQuote)) {
            history.insert(0, aiQuote);
            if (history.length > 20) history.removeLast();
          }
        });

        _saveQuotes();
      } else {
        setState(() => quote = 'Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => quote = 'Ошибка подключения к серверу.');
    }
  }

  void saveToFavorites() {
    if (!favorites.contains(quote)) {
      setState(() {
        favorites.add(quote);
      });
      _saveQuotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавлено в избранное!')),
      );
    }
  }

  void shareQuote() {
    Share.share(quote);
  }

  void _showListModal(String title, List<String> items) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: items.map((q) => ListTile(title: Text(q))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мотиватор дня'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Сменить тему',
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'История',
            onPressed: () => _showListModal('История', history),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Избранное',
            onPressed: () => _showListModal('Избранное', favorites),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                quote,
                style: const TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // Выбор категории
            DropdownButton<String>(
              value: selectedCategory,
              items: categories.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: fetchQuote,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Новая цитата'),
                ),
                ElevatedButton.icon(
                  onPressed: fetchQuoteFromAI,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Цитата от ИИ'),
                ),
                ElevatedButton.icon(
                  onPressed: saveToFavorites,
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('В избранное'),
                ),
                ElevatedButton.icon(
                  onPressed: shareQuote,
                  icon: const Icon(Icons.share),
                  label: const Text('Поделиться'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
