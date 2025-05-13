import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            Text(
              "HD2MM",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFamily: "Blockletter",
              ),
            ),
            FlutterLogo(
              size: 150,
              style: FlutterLogoStyle.stacked,
            ),
          ],
        ),
        Expanded(
          child: Row(
            spacing: 5,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      "• Author: teutinsa",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 300,
                child: Column(
                  spacing: 3,
                  children: [
                    Text(
                      "Thank you to all my supporters!",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: FutureBuilder(
                          future: _fetchSupporters(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 5,
                                  children: [
                                    Text(
                                      "Error",
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      snapshot.error!.toString(),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              final data = snapshot.data!;
                              return ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final (url, name) = data[index];
                                  return ListTile(
                                    leading: Image.network(
                                      url,
                                      fit: BoxFit.contain,
                                    ),
                                    title: Text(name),
                                  );
                                },
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: Text("Back"),
        ),
      ],
    );
  }

  Future<List<(String imageUrl, String name)>> _fetchSupporters() async {
    throw UnimplementedError();
  }
}