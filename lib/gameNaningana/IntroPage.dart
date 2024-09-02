import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Naninganapage extends StatefulWidget {
  const Naninganapage({Key? key}) : super(key: key);

  @override
  _Naninganapage createState() => _Naninganapage();
}

class _Naninganapage extends State<Naninganapage> {
  late AudioPlayer _audioPlayer;
  int _currentInstructionIndex = 0;
  final List<Color> _availableColors = [Colors.red, Colors.blue, Colors.yellow];
  late List<Map<String, dynamic>> _instructions = [];

  Timer? _globalTimer;
  int _globalTimeLeft = 0; // 3 minutes = 180 seconds

  Timer? _instructionTimer;
  int _instructionTimeLeft = 0;
  bool _isSoundEnabled = true;

  // Add this line
  List<int> _highlightedBlocks = [];
  int? _selectedBlock;
  int? _selectedStar;
  Color? _selectedColor;
  Map<int, List<int>> _userSelections = {};

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _generateInstructions(); // Generate instructions
    _playMusic(); // Play music
    _startGame(); // Start the game
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateInstructions() {
    _instructions.clear(); // Effacer les instructions précédentes

    // Définir les motifs de couleur fixes
    final List<List<Color>> colorPatterns = [
      [
        Colors.red,
        Colors.blue,
        Colors.amber,
        Colors.red,
        Colors.blue,
        Colors.amber
      ],
      [
        Colors.blue,
        Colors.amber,
        Colors.red,
        Colors.blue,
        Colors.amber,
        Colors.red
      ],
      [
        Colors.amber,
        Colors.red,
        Colors.blue,
        Colors.amber,
        Colors.red,
        Colors.blue
      ],
    ];

    // Définir les instructions pour chaque bloc
    final List<Map<String, dynamic>> instructions = [
      {
        "bloc": 13,
        "color": Colors.red,
        "instruction": "PA: Je pose mon pied gauche sur le rouge en dansant",
        "highlight": [13],
        "image": "assets/images/danse.gif"
      },
      {
        "bloc": 18,
        "color": Colors.yellow,
        "instruction": "AD: Je pose mon pied droit sur le jaune en dansant  ",
        "highlight": [18],
        "image": "assets/images/danse2.gif"
      },
      {
        "bloc": 14,
        "color": Colors.blue,
        "instruction":
            "PA: Je pose mon 2e pied sur la couleur à  côté et je danse en balançant les bras.",
        "highlight": [14],
        "image": "assets/images/danse.gif"
      },
      {
        "bloc": 17,
        "color": Colors.blue,
        "instruction":
            "AD: Je pose mon 2e pied sur la couleur à  côté et je danse en balançant les bras",
        "highlight": [17],
        "image": "assets/images/danse.gif"
      },
      {
        "bloc": 8,
        "color": Colors.red,
        "instruction":
            "PA: J'avance sur la couleur de mon 2e pied et je tapotte mes cuisses en dansant.   ",
        "highlight": [8],
        "image": "assets/images/danse.gif"
      },
      {
        "bloc": 12,
        "color": Colors.yellow,
        "instruction":
            "AD: J'avance sur la couleur de mon 2e pied et je  tapotte mes cuisses en dansant.   ",
        "highlight": [12],
        "image": "assets/images/danse.gif"
      },
      {
        "bloc": 7,
        "color": Colors.red,
        "instruction":
            "PA: J'avance sur la couleur qui était à côté de ma jambe droite et je tourne sur moi en balançant mes bras ",
        "highlight": [7],
        "image": "assets/images/walk.gif"
      },
      {
        "bloc": 11,
        "color": Colors.yellow,
        "instruction":
            "AD: J'avance sur la couleur qui était à côté de ma jambe droite et je tourne sur moi en balançant mes bras. ",
        "highlight": [11],
        "image": "assets/images/walk.gif"
      },
      {
        "bloc": 9,
        "color": Colors.red,
        "instruction": "PA: J'avance sur le rectangle en face.",
        "highlight": [9],
        "image": "assets/images/walk1.gif"
      },
      {
        "bloc": 10,
        "color": Colors.yellow,
        "instruction": "AD: J'avance sur le rectangle en face.",
        "highlight": [10],
        "image": "assets/images/walk1.gif"
      },
      {
        "bloc": 11,
        "color": Colors.red,
        "instruction":
            "PA: J'avance sur la couleur occupée à la 3e ligne et je reprends tous les gestes. ",
        "highlight": [11],
        "image": "assets/images/bring.gif"
      },
      {
        "bloc": 12,
        "color": Colors.yellow,
        "instruction":
            "AD: J'avance sur la couleur occupée à la 3e ligne et je reprends tous les gestes. ",
        "highlight": [12],
        "image": "assets/images/bring.gif"
      },
      {
        "bloc": 17,
        "color": Colors.yellow,
        "instruction": "PA:  je reprends tous les gestes. ",
        "highlight": [17],
        "image": "assets/images/danse.gif"
      },
      {
        "bloc": 18,
        "color": Colors.yellow,
        "instruction": "AD: je reprends tous les gestes. ",
        "highlight": [18],
        "image": "assets/images/danse.gif"
      },
      {
        "bloc": 13,
        "color": Colors.red,
        "instruction":
            "PA: Je regarde mon compagnon et lui dis grâce à toi, je vis heureux et en paix",
        "highlight": [13],
        "image": "assets/images/ilove.gif"
      },
      {
        "bloc": 14,
        "color": Colors.yellow,
        "instruction":
            "AD: Je regarde mon compagnon et lui dis grâce à toi, je vis heureux et en paix",
        "highlight": [14],
        "image": "assets/images/ilove.gif"
      },
      {
        "bloc": 15,
        "color": Colors.red,
        "instruction": "Puis nous avançons sur l étoile",
        "highlight": [15],
        "image": "assets/images/together.gif"
      },
      {
        "bloc": 16,
        "color": Colors.yellow,
        "instruction": " Nous nous faisons un câlin",
        "highlight": [16],
        "image": "assets/images/calin.gif"
      }
      // Ajoutez d'autres instructions ici
    ];

    int instructionIndex = 0;

    // Commencer avec la troisième ligne
    for (int i = 2; i >= 0; i--) {
      List<Color> lineColors = colorPatterns[i];
      for (int j = 0; j < lineColors.length; j++) {
        // Vérifiez si l'index d'instruction est valide
        String instructionText = instructionIndex < instructions.length
            ? instructions[instructionIndex]["instruction"]
            : "Pose-toi sur le bloc ${(2 - i) * lineColors.length + j + 1} et fais une action !";

        List<int> highlight = instructionIndex < instructions.length
            ? instructions[instructionIndex]["highlight"]
            : [];
        String image = instructionIndex < instructions.length
            ? instructions[instructionIndex]["image"]
            : "";

        var blocNumber = (2 - i) * lineColors.length + j + 1;

        _instructions.add({
          "bloc": blocNumber,
          "color": lineColors[j],
          "instruction": instructionText,
          "highlight": highlight,
          "image": image // Ajoutez l'URL de l'image ici
        });

        print(
            'Bloc $blocNumber $instructionText ajouté avec highlight: $highlight');

        instructionIndex++;
      }
    }

    print(
        'Instructions générées: $_instructions'); // Débogage : Vérifiez si les instructions sont générées
  }

  void _startGame() {
    _startGlobalTimer();
    _playMusic();
    // Supprimez l'appel à _startInstructionTimer();
  }

  void _startGlobalTimer() {
    _globalTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _globalTimeLeft++; // Incrémentez le temps global
      });
    });
  }

  void _nextInstruction() {
    if (_selectedBlock != null) {
      if (_currentInstructionIndex < _instructions.length - 1) {
        setState(() {
          // Sauvegarder la sélection actuelle de l'utilisateur
          _userSelections[_currentInstructionIndex] =
              List<int>.from(_highlightedBlocks);

          _currentInstructionIndex++;
          final currentInstruction = _instructions[_currentInstructionIndex];
          _highlightedBlocks = List<int>.from(currentInstruction["highlight"]);

          // Restaurer la sélection de l'utilisateur pour la nouvelle instruction
          _highlightedBlocks = _userSelections[_currentInstructionIndex] ?? [];
          _selectedBlock =
              _highlightedBlocks.isNotEmpty ? _highlightedBlocks.first : null;
          _selectedColor = _instructions.firstWhere(
              (instruction) => instruction["bloc"] == _selectedBlock,
              orElse: () => {"color": Colors.transparent})["color"] as Color?;
        });
      } else {
        _endGame();
      }
    } else {
      _showError();
    }
  }

  // Méthode pour aller à l'instruction précédente
  void _previousInstruction() {
    if (_currentInstructionIndex > 0) {
      setState(() {
        // Sauvegarder la sélection actuelle de l'utilisateur
        _userSelections[_currentInstructionIndex] =
            List<int>.from(_highlightedBlocks);

        _currentInstructionIndex--;
        final currentInstruction = _instructions[_currentInstructionIndex];
        _highlightedBlocks = List<int>.from(currentInstruction["highlight"]);

        // Restaurer les sélections de l'utilisateur pour l'instruction précédente
        _highlightedBlocks = _userSelections[_currentInstructionIndex] ?? [];
        _selectedBlock =
            _highlightedBlocks.isNotEmpty ? _highlightedBlocks.first : null;
        _selectedColor = _instructions.firstWhere(
            (instruction) => instruction["bloc"] == _selectedBlock,
            orElse: () => {"color": Colors.transparent})["color"] as Color?;
      });
    }
  }

  // Méthode pour gérer la sélection des blocs
  void _onBlocSelected(int blocNumber) {
    setState(() {
      // Réinitialiser la sélection des étoiles si un bloc est sélectionné
      _selectedStar = null;

      // Trouver la couleur du bloc sélectionné
      Color? color = _instructions.firstWhere(
              (instruction) => instruction["bloc"] == blocNumber,
          orElse: () => {"color": Colors.transparent})["color"] as Color?;

      // Si le bloc sélectionné est déjà le bloc actuel, on le désélectionne
      if (_highlightedBlocks.isNotEmpty &&
          _highlightedBlocks.first == blocNumber) {
        _highlightedBlocks.clear();
        _selectedBlock = null;
        _selectedColor = null; // Réinitialiser la couleur
      } else {
        // Si un bloc est déjà sélectionné, on le désélectionne
        _highlightedBlocks.clear();
        // Sélectionne le nouveau bloc
        _highlightedBlocks.add(blocNumber);
        _selectedBlock = blocNumber;
        _selectedColor = color; // Mettre à jour la couleur
      }

      // Conserver la sélection de l'utilisateur pour l'instruction actuelle
      _userSelections[_currentInstructionIndex] =
      List<int>.from(_highlightedBlocks);
    });
  }


  void _showError() {
    // Afficher une erreur si le bloc sélectionné est incorrect
    print('Erreur: bloc incorrect sélectionné.');
  }

  void _stopMusic() async {
    await _audioPlayer.stop();
  }

  void _toggleSound() {
    setState(() {
      _isSoundEnabled = !_isSoundEnabled;
      if (_isSoundEnabled) {
        _audioPlayer.resume(); // Reprendre la musique si le son est activé
      } else {
        _audioPlayer.pause(); // Arrêter la musique si le son est désactivé
      }
    });
  }

  void _outgame() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                  "Vous êtes sur le point de quitter la partie. Voulez-vous continuer ?"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _endGame();
                      Navigator.pushNamed(context, '/home_page');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Quitter",
                            style: TextStyle(color: Colors.white))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Continuer",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                ],
              ),
            ));
  }

  void _endGame() {
    _globalTimer?.cancel();
    _stopMusic();

    // Calcul du score
    int score = 0;
    for (int i = 0; i < _instructions.length; i++) {
      final instruction = _instructions[i];
      if (_userSelections.length > i) {
        var selected = _userSelections[i];
        if (selected is int) {
          // Vérifier si la sélection correspond à un bloc
          Color? selectedColor = _instructions.firstWhere(
              (inst) => inst["bloc"] == selected,
              orElse: () => {"color": Colors.transparent})["color"] as Color?;

          if (selectedColor == instruction["color"]) {
            score++;
          }
        } else if (selected is int?) {
          // Vérifier si la sélection correspond à une zone spécifique (étoile ou rectangle)
          if (instruction["highlight"].contains(selected)) {
            score++;
          }
        }
      }
    }

    // Calculer le nombre d'étoiles basé sur le score
    int totalInstructions = _instructions.length;
    int stars = (score / totalInstructions * 3)
        .floor(); // Déterminez le nombre d'étoiles

    // Ajuster la logique pour attribuer les étoiles
    if (stars < 0) stars = 0; // Assurez-vous que le nombre d'étoiles est >= 0
    if (stars > 3) stars = 3; // Assurez-vous que le nombre d'étoiles est <= 3

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Félicitations !"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Bravo ! Vous avez terminé toutes les instructions !"),
            SizedBox(height: 16),
            Text("Temps total passé : ${_globalTimeLeft} secondes."),
            SizedBox(height: 16),
            Text("Score : $score/$totalInstructions"), // Afficher le score
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                stars,
                (index) => Icon(Icons.star, color: Colors.yellow),
              ),
            ),
            SizedBox(height: 16),
            Text("Merci d'avoir joué. Vous avez fait un excellent travail !"),
          ],
        ),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/home_page');
            },
            child: Text(
              "Retour à la maison",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    // Réinitialiser le temps
    _globalTimeLeft = 0;

    // Réinitialiser l'index des instructions
    _currentInstructionIndex = 0;

    // Réinitialiser les blocs mis en surbrillance
    _highlightedBlocks = _instructions.isNotEmpty
        ? List<int>.from(_instructions[0]["highlight"])
        : [];

    // Réinitialiser les sélections des utilisateurs
    _userSelections.clear();

    // Arrêter le minuteur si en cours
    _globalTimer?.cancel();

    // Réinitialiser l'audio
    _audioPlayer.stop();
    _audioPlayer.seek(Duration.zero);

    _startGame();
    Navigator.pop(context);
  }

  void _menu() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Menu'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: _resetGame,
                      child: Text(
                        'Recommencer la partie',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _outgame();

                      },
                      child: Text(
                        'Quitter la partie',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.red),
                      ))
                ],
              ),
            ));
  }

  void _playMusic() async {
    if (_isSoundEnabled) {
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/music.mpeg'));
    }
  }

  // Method to check if a bloc should be highlighted based on the current instruction
  bool _isBlocHighlighted(int bloc) {
    final instruction = _instructions[_currentInstructionIndex]["instruction"];
    return instruction.contains("bloc $bloc");
  }

  @override
  Widget build(BuildContext context) {
    // Ensure instructions are available before accessing the index
    if (_instructions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('Aucune instruction disponible'),
        ),
      );
    }

    final instruction = _instructions[_currentInstructionIndex];

    return Scaffold(
      backgroundColor: Colors.black12,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              image: DecorationImage(
                image: AssetImage('assets/images/background.webp'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Column(
                children: [
                  _header(),
                  SizedBox(height: 10.0),
                  _quiz(instruction),
                  SizedBox(
                    height: 10,
                  ),
                  _starEnd(),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(color: Colors.black26),
                        child: _palleteGame()),
                  ),
                  _bottomButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    String _formatDuration(int totalSeconds) {
      final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
      return "$minutes:$seconds";
    }

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(50.0),
          bottomLeft: Radius.circular(50.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: IconButton(
                    icon: Icon(
                      _isSoundEnabled ? Icons.volume_down : Icons.volume_off,
                      color: Colors.lightBlue,
                    ),
                    onPressed: _toggleSound,
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: Text(
                      _formatDuration(_globalTimeLeft),
                      // Affiche le temps écoulé
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.list,
                      color: Colors.lightBlue,
                    ),
                    color: Colors.lightBlue,
                    onPressed: _menu,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quiz(Map<String, dynamic> instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Afficher l'image associée à l'instruction
            if (instruction["image"] != null && instruction["image"].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  instruction["image"],
                  height: 50.0,
                  // Ajustez la hauteur de l'image
                  width: 50.0,
                  // Ajustez la largeur de l'image
                  fit: BoxFit.cover,
                  // Ajuste l'image pour couvrir le conteneur

                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Center(
                      child: Icon(Icons.error, color: Colors.red, size: 40.0),
                    );
                  },
                ),
              ),
            // Afficher le texte de l'instruction
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                instruction["instruction"],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _starEnd() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.star,
            size: 70,
            color: Colors.amber,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      // Réinitialiser la sélection du bloc si une étoile est sélectionnée
                      _selectedBlock = null;

                      _selectedStar = 1; // Marquer le premier container comme sélectionné
                    });
                  },
                  child: Container(
                    width: 140,
                    height: 70,
                    color: _selectedStar == 1 ? Colors.blueAccent : Colors.blue,
                    // Changer la couleur en fonction de la sélection
                    child: Center(
                      child: _selectedStar == 1
                          ? Icon(Icons.check, color: Colors.white) // Afficher une icône de sélection
                          : null,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      // Réinitialiser la sélection du bloc si une étoile est sélectionnée
                      _selectedBlock = null;

                      _selectedStar = 2; // Marquer le deuxième container comme sélectionné
                    });
                  },
                  child: Container(
                    width: 140,
                    height: 70,
                    color: _selectedStar == 2 ? Colors.redAccent : Colors.red,
                    // Changer la couleur en fonction de la sélection
                    child: Center(
                      child: _selectedStar == 2
                          ? Icon(Icons.check, color: Colors.white) // Afficher une icône de sélection
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _palleteGame() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
        ),
        itemCount: _instructions.length,
        itemBuilder: (context, index) {
          final instruction = _instructions[index];
          final isSelected = _selectedBlock == instruction["bloc"];

          return GestureDetector(
            onTap: () => _onBlocSelected(instruction["bloc"]),
            child: Container(
              margin: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: instruction["color"],
                borderRadius: BorderRadius.circular(4.0),
                border: isSelected
                    ? Border.all(
                        color: Colors.green,
                        width: 4.0,
                      )
                    : null,
              ),
              child: Center(
                child:
                    isSelected ? Icon(Icons.check, color: Colors.white) : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              _previousInstruction();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _nextInstruction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
