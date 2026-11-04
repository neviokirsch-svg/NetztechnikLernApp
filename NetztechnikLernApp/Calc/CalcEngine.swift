import Foundation

/// Rechenaufgaben-Typ. Erzeugt bei jedem Aufruf eine neue Aufgabe mit neuen Zahlen.
struct CalcGenerator: Identifiable {
    let id: String
    let title: String
    let group: String
    let icon: String
    let formula: String
    let ref: String
    let lvl: Int
    let pts: Int
    let make: () -> Question
}

enum CalcEngine {
    static let all: [CalcGenerator] = [
        CalcGenerator(id: "calc.wavelength", title: "Wellenlänge & Frequenz", group: "Übertragung", icon: "waveform", formula: "λ = c / f", ref: "T1 S.36", lvl: 1, pts: 2, make: wavelength),
        CalcGenerator(id: "calc.propagation", title: "Signallaufzeit mit NVP", group: "Übertragung", icon: "timer", formula: "t = d / (NVP · c)", ref: "T1 S.37", lvl: 2, pts: 3, make: propagation),
        CalcGenerator(id: "calc.transmission", title: "Sendedauer eines Pakets", group: "Übertragung", icon: "shippingbox", formula: "t = Datenmenge / Datenrate", ref: "T1 S.20", lvl: 1, pts: 2, make: transmission),
        CalcGenerator(id: "calc.total", title: "Sendedauer + Laufzeit", group: "Übertragung", icon: "clock.arrow.2.circlepath", formula: "t = L / R + d / (NVP · c)", ref: "T1 S.37", lvl: 3, pts: 4, make: totalDelay),
        CalcGenerator(id: "calc.verlust", title: "Verlust im Verlustsystem", group: "Verkehrstheorie", icon: "chart.bar", formula: "V = Restverkehr / Angebot bzw. / Leistung", ref: "T1 S.21", lvl: 2, pts: 3, make: verlust),
        CalcGenerator(id: "calc.addresses", title: "Adressraum aus Bitlängen", group: "IP & Adressen", icon: "number", formula: "Anzahl = 2^Bits", ref: "T1 S.57", lvl: 1, pts: 2, make: addresses),
        CalcGenerator(id: "calc.overhead", title: "Protokoll-Overhead", group: "IP & Adressen", icon: "square.stack.3d.up", formula: "Anteil = Nutzdaten / (Nutzdaten + Header)", ref: "T1 S.48", lvl: 2, pts: 3, make: overhead),
        CalcGenerator(id: "calc.dijkstra", title: "Kürzester Weg (Dijkstra)", group: "Routing", icon: "point.3.connected.trianglepath.dotted", formula: "minimale Summe der Linkkosten", ref: "T1 S.81", lvl: 3, pts: 4, make: dijkstra),
        CalcGenerator(id: "calc.srtt", title: "Geglättete RTT (SRTT)", group: "TCP", icon: "waveform.path.ecg", formula: "SRTT = α · SRTT + (1 − α) · RTT", ref: "T1 S.99", lvl: 2, pts: 3, make: srtt),
        CalcGenerator(id: "calc.timeout", title: "Timeout & Back-off", group: "TCP", icon: "hourglass", formula: "Timeout = β · SRTT, je Timeout × 2", ref: "T1 S.99", lvl: 2, pts: 3, make: timeout),
        CalcGenerator(id: "calc.slowstart", title: "Slow Start & Stauvermeidung", group: "TCP", icon: "chart.line.uptrend.xyaxis", formula: "exponentiell bis Schwellwert, dann linear", ref: "T1 S.105", lvl: 3, pts: 4, make: slowStart),
        CalcGenerator(id: "calc.congestion", title: "CWND nach einem Timeout", group: "TCP", icon: "exclamationmark.triangle", formula: "Schwellwert halbieren, CWND = 1 MSS", ref: "T1 S.105", lvl: 3, pts: 4, make: congestion),
        CalcGenerator(id: "calc.ack", title: "ACK-Nummer bestimmen", group: "TCP", icon: "checkmark.seal", formula: "ACK = SEQ + Bytes", ref: "T1 S.102", lvl: 2, pts: 2, make: ackNumber),
        CalcGenerator(id: "calc.window", title: "Window Size", group: "TCP", icon: "rectangle.split.3x1", formula: "WIN = Puffer − unverarbeitet", ref: "T1 S.102", lvl: 1, pts: 2, make: window),
        CalcGenerator(id: "calc.tdma", title: "TDMA-Zeitschlitze", group: "Mobilfunk", icon: "antenna.radiowaves.left.and.right", formula: "Kanäle = Intervall / Zeitspanne", ref: "T1 S.117", lvl: 1, pts: 2, make: tdma),
        CalcGenerator(id: "calc.http", title: "RTTs einer Webseite", group: "HTTP & Medien", icon: "globe", formula: "non-persistent: 2 RTT je Objekt", ref: "T2 S.11", lvl: 2, pts: 3, make: httpRtt),
        CalcGenerator(id: "calc.rtp", title: "Bytes pro Audio-Sample", group: "HTTP & Medien", icon: "speaker.wave.2", formula: "Bytes = Rate · Dauer / 8", ref: "T2 S.30", lvl: 2, pts: 2, make: rtpSample),
        CalcGenerator(id: "calc.parity", title: "Paritätsbit", group: "Link Layer", icon: "checkmark.square", formula: "gerade Anzahl Einsen", ref: "T2 S.40", lvl: 1, pts: 1, make: parity),
        CalcGenerator(id: "calc.aloha", title: "Nutzbare Kanalkapazität", group: "Link Layer", icon: "dot.radiowaves.left.and.right", formula: "Rate · maximaler Nutzungsgrad", ref: "T2 S.45", lvl: 1, pts: 2, make: aloha),
        CalcGenerator(id: "calc.4b5b", title: "4B/5B Datenrate", group: "Link Layer", icon: "number.square", formula: "Leitungsrate = Nutzrate · 5/4", ref: "T2 S.48", lvl: 2, pts: 2, make: b4b5),
        CalcGenerator(id: "calc.backoff", title: "Backoff-Wartezeit", group: "Ethernet", icon: "dice", formula: "t = K · 512 Bit / R", ref: "T2 S.55", lvl: 2, pts: 3, make: backoff),
        CalcGenerator(id: "calc.ethernet", title: "Ethernet-Frame", group: "Ethernet", icon: "rectangle.split.3x1", formula: "8 + 6 + 6 + 2 + Nutzdaten + 4 Bytes", ref: "T2 S.53", lvl: 2, pts: 3, make: ethernet),
        CalcGenerator(id: "calc.energy", title: "Energieintensität & Verbrauch", group: "Energie", icon: "bolt", formula: "Energie / Datenvolumen", ref: "T2 S.87", lvl: 1, pts: 2, make: energy)
    ]

    static func generator(id: String) -> CalcGenerator? { all.first { $0.id == id } }

    static var groups: [String] {
        var seen: [String] = []
        for g in all where !seen.contains(g.group) { seen.append(g.group) }
        return seen
    }

    // MARK: Hilfen

    private static func task(_ id: String, _ prompt: String, answer: Double, tol: Double, unit: String, steps: [String], fig: Block? = nil) -> Question {
        let gen = all.first { $0.id == id }
        var q = Question(id: id, k: .num, lvl: gen?.lvl ?? 2, pts: gen?.pts ?? 2, q: prompt)
        q.num = answer
        q.tol = tol
        q.unit = unit
        q.steps = steps
        q.ref = gen?.ref
        q.src = "rechner"
        q.fig = fig
        return q
    }

    private static func n(_ v: Double, _ digits: Int = 3) -> String { deNumber(v, maxDigits: digits) }

    // MARK: Übertragung

    private static func wavelength() -> Question {
        let list: [(String, Double)] = [
            ("GSM mit 900 MHz", 900), ("GSM mit 1,8 GHz", 1800), ("UMTS mit 1,9 GHz", 1900),
            ("UMTS mit 2,1 GHz", 2100), ("LTE mit 700 MHz", 700), ("LTE mit 2,6 GHz", 2600),
            ("5G mit 3,4 GHz", 3400), ("5G mit 3,8 GHz", 3800)
        ]
        let item = list.randomElement() ?? list[0]
        let cm = 300_000_000.0 / (item.1 * 1_000_000) * 100
        return task("calc.wavelength",
            "Berechnen Sie die Wellenlänge für **\(item.0)** in Zentimetern. Rechnen Sie mit c = 300.000.000 m/s.",
            answer: cm, tol: 0.1, unit: "cm",
            steps: ["λ = c / f", "λ = 300.000.000 m/s ÷ \(n(item.1 * 1_000_000, 0)) Hz = \(n(cm / 100, 4)) m", "λ = **\(n(cm, 2)) cm**"])
    }

    private static func propagation() -> Question {
        let media: [(String, Double)] = [("Cat5e-Kabel", 0.64), ("Glasfaser", 0.67), ("Koaxialkabel (82 %)", 0.82), ("Cat7-Kabel (74 %)", 0.74)]
        let m = media.randomElement() ?? media[0]
        let km = Double([50, 100, 200, 500, 800, 1000, 2000].randomElement() ?? 100)
        let speed = 300_000 * m.1
        let ms = km / speed * 1000
        return task("calc.propagation",
            "Ein Signal läuft über **\(n(km, 0)) km \(m.0)**. NVP = \(n(m.1 * 100, 0)) %, c = 300.000 km/s.\nWie lange ist es unterwegs (in ms)?",
            answer: ms, tol: 0.02, unit: "ms",
            steps: ["Geschwindigkeit im Medium: v = NVP · c = \(n(m.1, 2)) · 300.000 km/s = \(n(speed, 0)) km/s", "t = d / v = \(n(km, 0)) km ÷ \(n(speed, 0)) km/s", "t = **\(n(ms, 3)) ms**"])
    }

    private static func transmission() -> Question {
        let bytes = Double([64, 512, 1000, 1500].randomElement() ?? 1500)
        let mbit = Double([10, 100, 1000].randomElement() ?? 100)
        let us = bytes * 8 / mbit
        return task("calc.transmission",
            "Wie lange dauert das Senden von **\(n(bytes, 0)) Bytes** bei einer Datenübertragungsrate von **\(n(mbit, 0)) Mbit/s** (in µs)?",
            answer: us, tol: 0.02, unit: "µs",
            steps: ["\(n(bytes, 0)) Bytes = \(n(bytes * 8, 0)) Bit", "t = \(n(bytes * 8, 0)) Bit ÷ \(n(mbit, 0)) Mbit/s", "t = **\(n(us, 3)) µs**"])
    }

    private static func totalDelay() -> Question {
        let bytes = Double([500, 1000, 1500].randomElement() ?? 1500)
        let mbit = Double([10, 100].randomElement() ?? 100)
        let km = Double([100, 201, 402, 1005].randomElement() ?? 201)
        let sendMs = bytes * 8 / (mbit * 1000)
        let propMs = km / (300_000 * 0.67) * 1000
        return task("calc.total",
            "Ein Paket mit **\(n(bytes, 0)) Bytes** wird über **\(n(km, 0)) km Glasfaser** (NVP 67 %, c = 300.000 km/s) mit **\(n(mbit, 0)) Mbit/s** gesendet.\nWann ist das letzte Bit beim Empfänger (in ms nach Sendebeginn)?",
            answer: sendMs + propMs, tol: 0.02, unit: "ms",
            steps: ["Sendedauer: \(n(bytes * 8, 0)) Bit ÷ \(n(mbit, 0)) Mbit/s = \(n(sendMs, 3)) ms", "Laufzeit: \(n(km, 0)) km ÷ 201.000 km/s = \(n(propMs, 3)) ms", "Summe = **\(n(sendMs + propMs, 3)) ms**"])
    }

    // MARK: Verkehrstheorie

    private static func verlust() -> Question {
        let angebot = Double(Int.random(in: 8...20) * 50)
        let rest = Double(Int.random(in: 1...3) * 25)
        let leistung = angebot - rest
        let onOffer = Bool.random()
        let result = onOffer ? rest / angebot : rest / leistung
        let base = onOffer ? "das **Angebot**" : "die **Leistung**"
        return task("calc.verlust",
            "Einem Verlustsystem werden \(n(angebot, 0)) Belegungen angeboten, \(n(rest, 0)) davon werden abgewiesen.\nBerechnen Sie den Verlust bezogen auf \(base) (als Dezimalzahl).",
            answer: result, tol: 0.002, unit: "",
            steps: ["Restverkehr = abgewiesener Teil = \(n(rest, 0))", "Leistung = Angebot − Restverkehr = \(n(leistung, 0))", onOffer ? "Verlust = Restverkehr / Angebot = \(n(rest, 0)) / \(n(angebot, 0))" : "Verlust = Restverkehr / Leistung = \(n(rest, 0)) / \(n(leistung, 0))", "= **\(n(result, 4))**"])
    }

    // MARK: IP

    private static func addresses() -> Question {
        let net = [8, 12, 16, 20, 24].randomElement() ?? 24
        let host = 32 - net
        let count = pow(2.0, Double(host))
        return task("calc.addresses",
            "Eine IPv4-Adresse ist 32 Bit lang. Die Net-ID belegt **\(net) Bit**, der Rest ist die Host-ID.\nWie viele Adresswerte kann die Host-ID darstellen?",
            answer: count, tol: 0.5, unit: "Adressen",
            steps: ["Host-ID = 32 − \(net) = \(host) Bit", "Anzahl = 2^\(host) = **\(n(count, 0))**"])
    }

    private static func overhead() -> Question {
        let transports: [(String, Double)] = [("TCP (20 Bytes ohne Options)", 20), ("UDP (8 Bytes)", 8)]
        let nets: [(String, Double)] = [("IPv4 (20 Bytes ohne Options)", 20), ("IPv6 (40 Bytes)", 40)]
        let t = transports.randomElement() ?? transports[0]
        let ip = nets.randomElement() ?? nets[0]
        let payload = Double([100, 160, 200, 500, 1000].randomElement() ?? 200)
        let percent = payload / (payload + t.1 + ip.1) * 100
        return task("calc.overhead",
            "Ein IP-Paket transportiert **\(n(payload, 0)) Bytes** Nutzdaten über \(t.0) und \(ip.0).\nWie groß ist der Nutzdatenanteil am gesamten IP-Paket (in %)?",
            answer: percent, tol: 0.1, unit: "%",
            steps: ["Paketgröße = \(n(payload, 0)) + \(n(t.1, 0)) + \(n(ip.1, 0)) = \(n(payload + t.1 + ip.1, 0)) Bytes", "Anteil = \(n(payload, 0)) / \(n(payload + t.1 + ip.1, 0))", "= **\(n(percent, 2)) %**"])
    }

    // MARK: Routing

    private static func dijkstra() -> Question {
        let names = ["A", "B", "C", "D", "E", "F"]
        let links: [(Int, Int)] = [(0, 1), (0, 3), (1, 2), (1, 4), (3, 4), (2, 4), (2, 5), (4, 5)]
        var weights: [Int] = []
        for _ in links { weights.append(Int.random(in: 1...9)) }
        var dist = [Int](repeating: Int.max, count: 6)
        var prev = [Int](repeating: -1, count: 6)
        var done = [Bool](repeating: false, count: 6)
        dist[0] = 0
        var log: [String] = []
        for _ in 0..<6 {
            var u = -1
            for i in 0..<6 where !done[i] && dist[i] != Int.max {
                if u == -1 || dist[i] < dist[u] { u = i }
            }
            if u == -1 { break }
            done[u] = true
            log.append("\(names[u]) fest mit Distanz \(dist[u])")
            for (index, link) in links.enumerated() {
                let other: Int
                if link.0 == u {
                    other = link.1
                } else if link.1 == u {
                    other = link.0
                } else {
                    continue
                }
                if !done[other] && dist[u] + weights[index] < dist[other] {
                    dist[other] = dist[u] + weights[index]
                    prev[other] = u
                }
            }
        }
        var path: [String] = []
        var cursor = 5
        while cursor != -1 {
            path.insert(names[cursor], at: 0)
            cursor = prev[cursor]
        }
        var fig = Block(t: "net")
        fig.title = "Linkkosten"
        fig.nodes = [
            NetNode(id: "A", l: "A", x: 0, y: 0.1), NetNode(id: "B", l: "B", x: 0.45, y: 0),
            NetNode(id: "C", l: "C", x: 0.8, y: 0.1), NetNode(id: "D", l: "D", x: 0.1, y: 0.9),
            NetNode(id: "E", l: "E", x: 0.5, y: 0.9), NetNode(id: "F", l: "F", x: 1, y: 0.75)
        ]
        var edges: [NetEdge] = []
        for (index, link) in links.enumerated() {
            edges.append(NetEdge(a: names[link.0], b: names[link.1], l: String(weights[index])))
        }
        fig.edges = edges
        var steps = ["Dijkstra ab A: immer den Knoten mit der kleinsten bekannten Distanz festlegen."]
        steps.append(contentsOf: log)
        steps.append("Kürzester Weg: \(path.joined(separator: " → ")) mit Kosten **\(dist[5])**")
        return task("calc.dijkstra",
            "Ein Link-State-Router berechnet mit dem Dijkstra-Algorithmus den kürzesten Weg.\nWelche **Gesamtkosten** hat der kürzeste Weg von **A nach F**?",
            answer: Double(dist[5]), tol: 0.01, unit: "",
            steps: steps, fig: fig)
    }

    // MARK: TCP

    private static func srtt() -> Question {
        let old = Double(Int.random(in: 8...30) * 10)
        let rtt = Double(Int.random(in: 8...40) * 10)
        let alpha = 0.875
        let result = alpha * old + (1 - alpha) * rtt
        return task("calc.srtt",
            "Die bisherige SRTT beträgt **\(n(old, 0)) ms**. Ein ACK trifft mit einer gemessenen RTT von **\(n(rtt, 0)) ms** ein. α = 0,875.\nWie groß ist die neue SRTT (in ms)?",
            answer: result, tol: 0.05, unit: "ms",
            steps: ["SRTT = α · SRTT + (1 − α) · RTT", "= 0,875 · \(n(old, 0)) + 0,125 · \(n(rtt, 0))", "= \(n(alpha * old, 3)) + \(n((1 - alpha) * rtt, 3)) = **\(n(result, 3)) ms**"])
    }

    private static func timeout() -> Question {
        let s = Double(Int.random(in: 5...40) * 10)
        let beta = [1.5, 2.0, 2.5].randomElement() ?? 2.0
        let count = Int.random(in: 1...3)
        let value = beta * s * pow(2.0, Double(count))
        return task("calc.timeout",
            "SRTT = **\(n(s, 0)) ms**, β = **\(n(beta, 1))**. Der Timer läuft **\(count)-mal in Folge** ab (Back-off).\nWie groß ist der Timeout-Wert danach (in ms)?",
            answer: value, tol: 0.05, unit: "ms",
            steps: ["Timeout = β · SRTT = \(n(beta, 1)) · \(n(s, 0)) = \(n(beta * s, 1)) ms", "Back-off: Bei jedem Timeout verdoppeln → · 2^\(count)", "= **\(n(value, 1)) ms**"])
    }

    /// Mechanismus wie im Skript: CWND verdoppelt sich je ACK bis zum Schwellwert, danach +1 MSS je ACK.
    private static func cwndTrace(start: Int, threshold: Int, acks: Int) -> [Int] {
        var values = [start]
        var c = start
        for _ in 0..<acks {
            c = c < threshold ? min(c * 2, threshold) : c + 1
            values.append(c)
        }
        return values
    }

    private static func slowStart() -> Question {
        let threshold = [8, 16, 32].randomElement() ?? 16
        let acks = Int.random(in: 3...9)
        let trace = cwndTrace(start: 1, threshold: threshold, acks: acks)
        let result = trace.last ?? 1
        return task("calc.slowstart",
            "Eine neue TCP-Verbindung startet mit CWND = 1 MSS. Schwellwert = **\(threshold) MSS**.\nGemäß Skript verdoppelt jedes ACK das CWND bis zum Schwellwert, danach wächst es um 1 MSS je ACK.\nWie groß ist das CWND nach **\(acks) ACKs** (in MSS)?",
            answer: Double(result), tol: 0.01, unit: "MSS",
            steps: ["Verlauf: " + trace.map { String($0) }.joined(separator: " → "), "CWND = **\(result) MSS**"])
    }

    private static func congestion() -> Question {
        let threshold = [16, 24, 32].randomElement() ?? 16
        let newThreshold = threshold / 2
        let acks = Int.random(in: 2...7)
        let trace = cwndTrace(start: 1, threshold: newThreshold, acks: acks)
        let result = trace.last ?? 1
        return task("calc.congestion",
            "Der Schwellwert beträgt **\(threshold) MSS**, als ein Timeout erkannt wird.\nWie groß ist das CWND **\(acks) ACKs** nach dem Neustart mit Slow Start (in MSS)?",
            answer: Double(result), tol: 0.01, unit: "MSS",
            steps: ["Timeout: Schwellwert halbieren → \(newThreshold) MSS, Neustart mit Slow Start bei 1 MSS", "Verlauf: " + trace.map { String($0) }.joined(separator: " → "), "CWND = **\(result) MSS**"])
    }

    private static func ackNumber() -> Question {
        let seq = Int.random(in: 1...40) * 512
        let bytes = [256, 512, 1024, 2048].randomElement() ?? 512
        let ack = seq + bytes
        return task("calc.ack",
            "Ein Sender schickt ein Segment mit **SEQ = \(seq)** und **\(bytes) Bytes** Nutzdaten.\nWelche ACK-Nummer sendet der Empfänger zurück (Zählweise wie im Flusskontroll-Beispiel: 2K mit SEQ=0 → ACK=2048)?",
            answer: Double(ack), tol: 0.01, unit: "",
            steps: ["TCP nutzt Bytes als Sequenznummern, nicht Pakete.", "ACK = SEQ + Bytes = \(seq) + \(bytes)", "ACK = **\(ack)**"])
    }

    private static func window() -> Question {
        let buffer = [4096, 8192, 16384].randomElement() ?? 4096
        let used = Int.random(in: 1...(buffer / 1024 - 1)) * 1024
        let win = buffer - used
        return task("calc.window",
            "Der Empfangspuffer ist **\(buffer) Bytes** groß, davon sind **\(used) Bytes** noch unverarbeitet.\nWelchen Wert meldet der Empfänger im Feld „Window Size“?",
            answer: Double(win), tol: 0.01, unit: "Bytes",
            steps: ["Die Window Size zeigt den noch verfügbaren Platz im Empfängerpuffer an.", "WIN = \(buffer) − \(used) = **\(win) Bytes**"])
    }

    // MARK: Mobilfunk

    private static func tdma() -> Question {
        let slotMs = [50.0, 100.0, 125.0, 200.0, 250.0].randomElement() ?? 125.0
        let channels = 1000 / slotMs
        return task("calc.tdma",
            "Bei TDMA erhält jeder Übertragungskanal **\(n(slotMs, 0)) ms** innerhalb eines Zeitintervalls von **1 s**.\nWie viele Kanäle passen maximal in dieses Intervall?",
            answer: channels, tol: 0.01, unit: "Kanäle",
            steps: ["Kanäle = Zeitintervall / Zeitspanne", "= 1000 ms ÷ \(n(slotMs, 0)) ms = **\(n(channels, 0))**"])
    }

    // MARK: HTTP & Medien

    private static func httpRtt() -> Question {
        let objects = Int.random(in: 2...12)
        let mode = Int.random(in: 0...2)
        let names = ["non-persistent HTTP", "persistent HTTP **ohne** Pipelining", "persistent HTTP **mit** Pipelining (bester Fall)"]
        let value: Int
        let steps: [String]
        switch mode {
        case 0:
            value = 2 * (objects + 1)
            steps = ["Non-persistent: 2 RTT pro Objekt (TCP-Aufbau + Request/Response)", "Objekte = 1 Basisdatei + \(objects) = \(objects + 1)", "2 · \(objects + 1) = **\(value) RTT**"]
        case 1:
            value = objects + 2
            steps = ["1 RTT TCP-Aufbau + 1 RTT HTML-Basisdatei", "+ 1 RTT für jedes der \(objects) referenzierten Objekte", "= **\(value) RTT**"]
        default:
            value = 3
            steps = ["1 RTT TCP-Aufbau + 1 RTT HTML-Basisdatei", "Im besten Fall nur 1 RTT für alle referenzierten Objekte", "= **3 RTT**"]
        }
        return task("calc.http",
            "Eine Webseite besteht aus einer HTML-Basisdatei und **\(objects) referenzierten Objekten**.\nWie viele RTTs werden mit \(names[mode]) benötigt? (Übertragungszeiten vernachlässigen)",
            answer: Double(value), tol: 0.01, unit: "RTT",
            steps: steps)
    }

    private static func rtpSample() -> Question {
        let rate = [64.0, 16.0].randomElement() ?? 64.0
        let bytes = rate * 1000 * 0.0125 / 8
        return task("calc.rtp",
            "Ein Audio-Codec arbeitet mit **\(n(rate, 0)) kBit/s**. Ein Sample ist **12,5 ms** lang.\nWie viele Bytes Nutzdaten entstehen pro Sample?",
            answer: bytes, tol: 0.01, unit: "Bytes",
            steps: ["\(n(rate, 0)) kBit/s · 12,5 ms = \(n(rate * 12.5, 0)) Bit", "\(n(rate * 12.5, 0)) Bit ÷ 8 = **\(n(bytes, 0)) Bytes**"])
    }

    // MARK: Link Layer

    private static func parity() -> Question {
        let bits = (0..<12).map { _ in Int.random(in: 0...1) }
        let ones = bits.reduce(0, +)
        let bit = ones % 2
        return task("calc.parity",
            "Bestimmen Sie das Paritätsbit für die Daten **\(bits.map { String($0) }.joined())** (gerade Parität wie auf der Folie).",
            answer: Double(bit), tol: 0.01, unit: "",
            steps: ["Anzahl Einsen = \(ones)", "Für eine gerade Gesamtzahl: Paritätsbit = **\(bit)**"])
    }

    private static func aloha() -> Question {
        let list: [(String, Double)] = [("Slotted ALOHA", 0.37), ("ALOHA (unslotted)", 0.18), ("CSMA/CD im günstigsten Fall", 0.70)]
        let item = list.randomElement() ?? list[0]
        let rate = Double([1, 10, 50, 100].randomElement() ?? 10)
        let usable = rate * item.1
        return task("calc.aloha",
            "Ein Kanal hat eine Rate von **\(n(rate, 0)) Mbit/s**. Wie viel Mbit/s können mit **\(item.0)** maximal genutzt werden (Werte aus dem Skript)?",
            answer: usable, tol: 0.01, unit: "Mbit/s",
            steps: ["\(item.0): maximal \(n(item.1 * 100, 0)) % der Kapazität", "\(n(rate, 0)) · \(n(item.1, 2)) = **\(n(usable, 2)) Mbit/s**"])
    }

    private static func b4b5() -> Question {
        let net = Double([4, 8, 40, 80, 100].randomElement() ?? 100)
        let line = net * 5 / 4
        return task("calc.4b5b",
            "Nutzdaten sollen mit **\(n(net, 0)) Mbit/s** übertragen werden und werden 4B/5B-codiert.\nWelche Bitrate ist auf der Leitung nötig?",
            answer: line, tol: 0.01, unit: "Mbit/s",
            steps: ["4 Bits werden mit 5 Bits codiert → Faktor 5/4", "\(n(net, 0)) · 5/4 = **\(n(line, 1)) Mbit/s**"])
    }

    // MARK: Ethernet

    private static func backoff() -> Question {
        let m = Int.random(in: 1...5)
        let maxK = Int(pow(2.0, Double(m))) - 1
        let k = Int.random(in: 1...max(maxK, 1))
        let rate = Double([10, 100].randomElement() ?? 10)
        let us = Double(k) * 512 / rate
        return task("calc.backoff",
            "Nach der **\(m). Kollision** wählt der Adapter K = **\(k)** aus {0, …, \(maxK)}. Die Datenrate ist **\(n(rate, 0)) Mbit/s**.\nWie lange wartet der Adapter (in µs)?",
            answer: us, tol: 0.02, unit: "µs",
            steps: ["Wartezeit = K × 512 Bit = \(k * 512) Bit", "t = \(k * 512) Bit ÷ \(n(rate, 0)) Mbit/s = **\(n(us, 2)) µs**"])
    }

    private static func ethernet() -> Question {
        let payload = Double([64, 100, 500, 1000, 1500].randomElement() ?? 1500)
        let tagged = Bool.random()
        let header = 8 + 6 + 6 + 2 + 4 + (tagged ? 4.0 : 0.0)
        let total = header + payload
        let percent = payload / total * 100
        return task("calc.ethernet",
            "Ein Ethernet-Frame\(tagged ? " mit 802.1q Tag" : "") trägt **\(n(payload, 0)) Bytes** Nutzdaten (Präambel mitgerechnet).\nWie groß ist der Nutzdatenanteil am Frame (in %)?",
            answer: percent, tol: 0.1, unit: "%",
            steps: ["Präambel 8 + Adressen 6 + 6 + Typ 2 + CRC 4\(tagged ? " + Tag 4" : "") = \(n(header, 0)) Bytes", "Gesamt = \(n(total, 0)) Bytes", "\(n(payload, 0)) / \(n(total, 0)) = **\(n(percent, 2)) %**"])
    }

    // MARK: Energie

    private static func energy() -> Question {
        if Bool.random() {
            let list: [(String, Double, Double)] = [("2021", 13187, 129), ("2022", 13142, 144)]
            let item = list.randomElement() ?? list[0]
            let value = item.1 / item.2
            return task("calc.energy",
                "Deutsche Telekom \(item.0): Energieverbrauch **\(n(item.1, 0)) Mio. kWh**, IP-Datenvolumen **\(n(item.2, 0)) Mio. Terabyte**.\nWie hoch ist die Energieintensität in kWh/Terabyte?",
                answer: value, tol: 1, unit: "kWh/TB",
                steps: ["Energieintensität = Energieverbrauch / Datenvolumen", "\(n(item.1, 0)) / \(n(item.2, 0)) ≈ **\(n(value, 1)) kWh/TB**"])
        }
        let gb = Double(Int.random(in: 1...20) * 5)
        let kwh = gb * 0.22
        return task("calc.energy",
            "Im Mobilfunk lag der Energieverbrauch 2020 bei **0,22 kWh/Gigabyte**.\nWie viel Energie entfällt damit auf **\(n(gb, 0)) GB**?",
            answer: kwh, tol: 0.02, unit: "kWh",
            steps: ["\(n(gb, 0)) GB · 0,22 kWh/GB = **\(n(kwh, 2)) kWh**"])
    }
}
