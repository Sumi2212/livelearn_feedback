import 'package:flutter/material.dart';
import 'feedback_model.dart';

class MainText extends StatefulWidget {
  const MainText({super.key});

  @override
  State<MainText> createState() => _MainTextState();
}

class _MainTextState extends State<MainText> {
  List<FeedbackEntry> eintraege = [];

  int verstehen = 0;
  int tempo = 0;
  int engagement = 0;

  final extremCtrl = TextEditingController();
  final freiCtrl = TextEditingController();

  int durchschnitt(List<FeedbackEntry> list, String feld) {
    if (list.isEmpty) return 0;
    double summe = 0;

    for (var e in list) {
      if (feld == "verstehen") summe += e.verstehen;
      if (feld == "tempo") summe += e.tempo;
      if (feld == "engagement") summe += e.engagement;
    }

    return (summe / list.length).round();
  }

  Widget simpleDiagram() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: eintraege.map((e) {
        double avg = (e.verstehen + e.tempo + e.engagement) / 3;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 18,
          height: avg * 18,
          color: Colors.lightBlueAccent,
        );
      }).toList(),
    );
  }

  Widget starRow(String title, int value, Function(int) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            return IconButton(
              icon: Icon(
                i < value ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
              onPressed: () => setState(() => onChange(i + 1)),
            );
          }),
        ),
      ],
    );
  }

  void showError() {
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Unvollständige Bewertung"),
        content: const Text(
          "Bitte bewerte alle Kriterien (Verständlichkeit, Tempo und Engagement), bevor du speicherst.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    bool extremeReached =
        verstehen == 1 || verstehen == 5 ||
        tempo == 1 || tempo == 5 ||
        engagement == 1 || engagement == 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 OBERER BEREICH
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LINKS: Durchschnitt + Diagramm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Durchschnitt",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      "Verständlichkeit: ${durchschnitt(eintraege, "verstehen")}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Tempo: ${durchschnitt(eintraege, "tempo")}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Engagement: ${durchschnitt(eintraege, "engagement")}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    simpleDiagram(),
                  ],
                ),
              ),

              /// RECHTS: Sterne
              Column(
                children: [
                  starRow("Verständlichkeit", verstehen, (v) => verstehen = v),
                  starRow("Tempo", tempo, (v) => tempo = v),
                  starRow("Engagement", engagement, (v) => engagement = v),
                ],
              ),
            ],
          ),

          const Divider(color: Colors.white),

          /// 🔹 KOMMENTARE
          if (extremeReached)
            TextField(
              controller: extremCtrl,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Kommentar (wegen Extremwert)",
              ),
            ),

          const SizedBox(height: 8),

          TextField(
            controller: freiCtrl,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: "Freitext (optional)",
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
            if (verstehen == 0 || tempo == 0 || engagement == 0) {
              showError();
              return;
            }

            setState(() {
              eintraege.add(
                FeedbackEntry(
                  date: DateTime.now(),
                  verstehen: verstehen,
                  tempo: tempo,
                  engagement: engagement,
                  extremKommentar: extremeReached ? extremCtrl.text : null,
                  freiText: freiCtrl.text.isEmpty ? null : freiCtrl.text,
                ),
              );

              verstehen = 0;
              tempo = 0;
              engagement = 0;
              extremCtrl.clear();
              freiCtrl.clear();
            });
          },

            child: const Text("Feedback speichern"),
          ),

          const Divider(color: Colors.white),

          /// 🔹 VERLAUF
          const Text(
            "Bewertungsverlauf",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 220,
            child: ListView(
              children: eintraege.map((e) {
                return Card(
                  child: ListTile(
                    title: Text(
                      e.date.toString().substring(0, 16),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "V: ${e.verstehen}, T: ${e.tempo}, E: ${e.engagement}\n"
                      "Extrem: ${e.extremKommentar ?? '-'}\n"
                      "Frei: ${e.freiText ?? '-'}",
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
