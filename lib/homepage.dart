import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flappy_bird/barriers.dart';
import 'package:flutter_flappy_bird/bird.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flappy_bird/welcome.dart';

class HomePage extends StatefulWidget {
  final String selectedAvatar;

  const HomePage({super.key, required this.selectedAvatar});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Variables
  Timer? gameTimer;
  static double birdYaxis = 0;
  //final String selectedAvatar;
  int score = 0;
  int best = 0;
  double time = 0;
  double height = 0;
  double initialHeight = 0;
  bool gameHasStarted = false;
  bool scoredOne = false;
  bool scoredTwo = false;
  static double barrierXone = 1;
  double barrierXtwo = barrierXone + 1.5;

  // Initialise le jeu avec un temps de "0"
  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdYaxis;
    });
  }

  // recommencer le jeu
  void resetGame() {
    setState(() {
      birdYaxis = 0;
      time = 0;
      height = 0;
      initialHeight = 0;
      gameHasStarted = false;

      barrierXone = 1;
      barrierXtwo = barrierXone + 1.5;

      score = 0;
      scoredOne = false;
      scoredTwo = false;
    });
  }

  // Jeu terminer
  void gameOver() {
    gameTimer?.cancel();
    gameHasStarted = false;

    if (score > best) {
      best = score;
      _saveBest();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue[50],
        title: const Text(
          '🎮 Fin de la partie',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              'SCORE',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Text(
              '$score',
              style: const TextStyle(
                fontSize: 50,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Meilleur score : $best',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // Rejouer
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text(
              '🔁 REJOUER',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          ),

          // Quitter vers la page MyWelcome
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ferme la boîte
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyWelcome()),
              );
            },
            child: const Text(
              '🚪 ARRÊTER',
              style: TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // Gère la logique de jeu (Calcule la hauteur et la durée du jeu)
  void startGame() {
    gameHasStarted = true;
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      // gravité / saut
      time += 0.05;
      height = -4.9 * time * time + 2.8 * time;
      double newBirdY = initialHeight - height;

      // déplacement obstacles + reset quand sort de l'écran
      double newX1, newX2;

      if (barrierXone < -2) {
        newX1 = barrierXone + 3.5;
        scoredOne = false; // on recomptera quand il repassera au centre
      } else {
        newX1 = barrierXone - 0.05;
      }

      if (barrierXtwo < -2) {
        newX2 = barrierXtwo + 3.5;
        scoredTwo = false;
      } else {
        newX2 = barrierXtwo - 0.05;
      }

      // SCORING: quand l’obstacle passe le centre (x <= 0)
      if (!scoredOne && newX1 <= 0) {
        score++;
        scoredOne = true;
      }
      if (!scoredTwo && newX2 <= 0) {
        score++;
        scoredTwo = true;
      }

      // --- COLLISIONS ---
      bool hitBounds = newBirdY > 1 || newBirdY < -1;

      // même logique de trou
      const double hitWidth = 0.15;
      const double gapCenter = 0.0;
      const double gapHalf = 0.30;

      bool hitBarrier(double bx) {
        if (bx.abs() < hitWidth) {
          if (newBirdY < gapCenter - gapHalf ||
              newBirdY > gapCenter + gapHalf) {
            return true;
          }
        }
        return false;
      }

      bool hit = hitBounds || hitBarrier(newX1) || hitBarrier(newX2);

      setState(() {
        birdYaxis = newBirdY;
        barrierXone = newX1;
        barrierXtwo = newX2;
      });

      if (hit) {
        gameOver();
      }
    });
  }

  void dispose() {
    // Toujours annuler le timer pour éviter les fuites mémoire
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      best = prefs.getInt('best') ?? 0;
    });
  }

  Future<void> _saveBest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best', best);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              //permet de faire sauter autant de fois qu'on clique sur l'ecran
              //Sinon reviens a la position initial
              flex: 2,
              child: Stack(
                children: [
                  AnimatedContainer(
                    alignment: Alignment(0, birdYaxis),
                    duration: Duration(milliseconds: 0),
                    color: Colors.blue,
                    child: MyBird(selectedAvatar: widget.selectedAvatar),
                  ),

                  // Afficher le text tant que le jeu n'a pas commencé
                  Container(
                    alignment: Alignment(0, -0.3),
                    child: gameHasStarted
                        ? Text(" ")
                        : Text("TAP TO PLAY", style: TextStyle(fontSize: 20)),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXone, 1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(size: 200.0),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXone, -1.5),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(size: 200.0),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXtwo, 1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(size: 150.0),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXtwo, -1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(size: 200.0),
                  ),
                ],
              ),
            ),

            // Separer la zone de jeu de la zone du score
            Container(height: 15, color: Colors.green),
            // Affichage du text en bas du jeu
            // Affiche le score actuel et le meilleur score
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "SCORE",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "$score",
                          style: TextStyle(color: Colors.white, fontSize: 35),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "BEST",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "$best",
                          style: TextStyle(color: Colors.white, fontSize: 35),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
