import 'package:flutter/material.dart';
import 'package:taktiktuk/utilities.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'TAK TIK TUK'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Player {
  static const none = '';
  static const X = 'X';
  static const O = 'O';
}

class _MyHomePageState extends State<MyHomePage> {
  static final countMatrix = 3;
  static final size = 92.0;

  late String lastMove = Player.none;

  late List<List<String>> matrix;

  @override
  void initState() {
    super.initState();

    setEmptyFields();
  }

  void setEmptyFields() => setState(() => matrix = List.generate(
        countMatrix,
        (_) => List.generate(countMatrix, (_) => Player.none),
      ));

  Color setBackgroundColor() {
    final thisMove = lastMove == Player.X ? Player.O : Player.X;

    return buildColor(thisMove).withAlpha(150);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: setBackgroundColor(),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: Utilities.modelBuilder(matrix, (x, value) => buildRow(x)),
      ),
    );
  }

  Widget buildRow(int x) {
    final values = matrix[x];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Utilities.modelBuilder(
        values,
        (y, value) => buildField(x, y),
      ),
    );
  }

  Color buildColor(String value) {
    switch (value) {
      case Player.O:
        return Colors.red;
      case Player.X:
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  Widget buildField(int x, int y) {
    final value = matrix[x][y];
    final color = buildColor(value);

    return Container(
      margin: EdgeInsets.all(5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(size, size),
          primary: color,
        ),
        child: Text(
          value,
          style: TextStyle(color: Colors.black, fontSize: 32),
        ),
        onPressed: () => selectField(value, x, y),
      ),
    );
  }

  void selectField(String value, int x, int y) {
    if (value == Player.none) {
      final newValue = lastMove == Player.X ? Player.O : Player.X;

      setState(() {
        lastMove = newValue;
        matrix[x][y] = newValue;
      });

      if (isWinner(x, y)) {
        showEndDialog('Player $newValue Won');
      } else if (isEnd()) {
        showEndDialog('Match Drawn');
      }
    }
  }

  bool isEnd() =>
      matrix.every((values) => values.every((value) => value != Player.none));

  bool isWinner(int x, int y) {
    var col = 0, row = 0, diag = 0, rdiag = 0;
    final player = matrix[x][y];
    final n = countMatrix;

    for (int i = 0; i < n; i++) {
      if (matrix[x][i] == player) col++;
      if (matrix[i][y] == player) row++;
      if (matrix[i][i] == player) diag++;
      if (matrix[i][n - i - 1] == player) rdiag++;
    }

    return row == n || col == n || diag == n || rdiag == n;
  }

  Future showEndDialog(String title) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text('Press to Restart the Game'),
          actions: [
            ElevatedButton(
              onPressed: () {
                setEmptyFields();
                Navigator.of(context).pop();
              },
              child: Text('Restart'),
            )
          ],
        ),
      );
}
