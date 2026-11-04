# Netztechnik Lern-App

iOS-App (SwiftUI, Liquid Glass) zum Skript „Kommunikations- und Netztechnik“ (T4INF2101), Teil 1 und 2.

## Öffnen und aufs iPhone bringen

1. `NetztechnikLernApp.xcodeproj` in Xcode öffnen. Nötig ist **Xcode 16 oder neuer**, für echtes Liquid Glass **Xcode 26**.
2. Target *NetztechnikLernApp* → *Signing & Capabilities* → eigenes **Team** wählen. Falls die Bundle-ID belegt ist, eine eigene eintragen.
3. iPhone auswählen und starten. Mindestversion ist iOS 17. Liquid Glass erscheint ab iOS 26, darunter gibt es eine Material-Optik.

**Originalfolien:** Die Skripte (WS 2026/27) liegen als `skript_teil1.pdf` und `skript_teil2.pdf` in `NetztechnikLernApp/Resources/PDF`. Die Altklausuren liegen in `Unterlagen/Klausuren`.

## Aufbau

| Ordner | Inhalt |
| --- | --- |
| `App` | App-Start, Tabs, Liquid-Glass-Design (`Theme.swift`) |
| `Models` | Datenmodell der Inhalte, Lernstand und Wiederholplanung |
| `Views` | Lernen, Lesen, Fragen, Wiederholen, Rechnen, Klausur |
| `Viz` | Animierte Diagramme und interaktive Labore |
| `Calc` | Rechenaufgaben mit zufälligen Zahlen und Rechenweg |
| `Resources/Content` | Lerninhalte als `module_*.json` |
| `Resources/PDF` | Die beiden Skripte, aus denen die Originalfolien angezeigt werden |

Neue Dateien im Ordner `NetztechnikLernApp` nimmt Xcode automatisch ins Projekt auf.

## Inhalte erweitern

Neue Dateien `Resources/Content/module_*.json` werden beim Start automatisch geladen. `module_25_altklausur.json` enthält die Aufgaben der Altklausuren (`src` nennt die Herkunft) und unter `exams` die Originalklausuren in ihrer Reihenfolge.

Fragetypen (`k`): `mc`, `ms`, `tf`, `num`, `ord`, `match`, `open`.
Blocktypen (`t`): `p`, `b`, `k`, `f`, `tb`, `sl`, `seq`, `net`, `frame`, `bars`, `x`.

Danach die Inhalte prüfen:

```
node tools/validate-content.js
```

Der Lernstand liegt in `Application Support/lernstand.json` auf dem Gerät. IDs von Fragen sollten sich nicht ändern, sonst geht deren Lernstand verloren.
