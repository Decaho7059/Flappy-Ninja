import 'package:flutter/material.dart';
import 'dart:math';
import 'homepage.dart';

class MyWelcome extends StatefulWidget {
  const MyWelcome({super.key});

  @override
  State<MyWelcome> createState() => _MyWelcomeState();
}

class _MyWelcomeState extends State<MyWelcome>
    with SingleTickerProviderStateMixin {
  final List<String> avatars = [
    for (var i in [
      'gaara',
      'naruto',
      'sasuke',
      'itachi',
      'boruto',
      'hidan',
      'hinata',
      'jiraya',
      'kizame',
      'kurama',
      'madara',
      'nagato',
      'orochimaru',
      'pain',
      'tobi',
      'sasuke1',
    ])
      'lib/images/$i.png',
  ];

  String selectedAvatar = 'lib/images/gaara.png';
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation pour faire pulser le logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF90CAF9), Color(0xFF42A5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),

              // ---- LOGO ANIMÉ ----
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double scale = 1 + 0.05 * sin(_controller.value * 2 * pi);
                  return Transform.scale(
                    scale: scale,
                    child: Column(
                      children: [
                        Image.asset(
                          'lib/images/kurama.png',
                          width: 120,
                          height: 120,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Flappy Ninja",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black45,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ---- LISTE DES AVATARS ----
              Column(
                children: [
                  const Text(
                    'Choisis ton Avatar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: avatars.length,
                      itemBuilder: (context, index) {
                        final avatar = avatars[index];
                        final isSelected = avatar == selectedAvatar;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedAvatar = avatar);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.amberAccent
                                    : Colors.transparent,
                                width: 4,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  const BoxShadow(
                                    color: Colors.amber,
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                avatar,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ---- BOUTON DE DÉMARRAGE ----
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.black54,
                  elevation: 10,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomePage(selectedAvatar: selectedAvatar),
                    ),
                  );
                },
                child: const Text(
                  "COMMENCER",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---- SECTION CRÉDITS ----
              Container(
                width: double.infinity,
                color: Colors.blue[900]?.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: Column(
                  children: const [
                    Text(
                      "© 2025 Flappy Ninja",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Conçu et développé par Decaho Gbegbe",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Tous droits réservés | v1.0.0",
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
