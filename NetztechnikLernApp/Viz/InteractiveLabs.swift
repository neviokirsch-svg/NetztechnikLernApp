import SwiftUI

/// Interaktive Labore, referenziert aus den Inhalten über `{"t":"x","viz":"name"}`.
struct InteractiveViz: View {
    let name: String

    var body: some View {
        switch name {
        case "wave": WaveLab()
        case "nvp": NVPRaceLab()
        case "multiplex": MultiplexLab()
        case "cwnd": CwndLab()
        case "srtt": SrttLab()
        case "flow": FlowControlLab()
        case "aloha": AlohaLab()
        case "backoff": BackoffLab()
        case "manchester": ManchesterLab()
        case "b4b5": B4B5Lab()
        case "parity": ParityLab()
        case "can": CanSignalLab()
        case "cell": CellReuseLab()
        case "qos": QosQueueLab()
        case "httprtt": HttpRttLab()
        default: Text("Visualisierung „\(name)“ nicht gefunden.").foregroundStyle(.secondary)
        }
    }
}

// MARK: - Wellenlänge (T1 S.36, S.114)

struct WaveLab: View {
    private let presets: [(String, Double)] = [
        ("LTE 700 MHz", 700e6), ("GSM 900 MHz", 900e6), ("GSM 1,8 GHz", 1.8e9),
        ("UMTS 2,1 GHz", 2.1e9), ("LTE 2,6 GHz", 2.6e9), ("5G 3,4 GHz", 3.4e9),
        ("5G 3,8 GHz", 3.8e9), ("5G mm wave 24,2 GHz", 24.2e9)
    ]
    @State private var index = 1

    var body: some View {
        let frequency = presets[index].1
        let lambda = 3e8 / frequency
        VizCard(title: "Labor: Frequenz und Wellenlänge") {
            Picker("Technik", selection: $index) {
                ForEach(0..<presets.count, id: \.self) { i in
                    Text(presets[i].0).tag(i)
                }
            }
            .pickerStyle(.menu)
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let phase = timeline.date.timeIntervalSinceReferenceDate * 3.0
                    let periods = 1.0 / lambda
                    var path = Path()
                    var x: CGFloat = 0
                    while x <= size.width {
                        let progress = Double(x / size.width)
                        let y = sin(progress * periods * 2 * .pi - phase)
                        let point = CGPoint(x: x, y: size.height / 2 - CGFloat(y) * size.height * 0.4)
                        if x == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                        x += 1
                    }
                    context.stroke(path, with: .color(Theme.primary), lineWidth: 2)
                }
            }
            .frame(height: 90)
            Text("Sichtfenster: 1 Meter").font(.caption2).foregroundStyle(.secondary)
            CaptionBox(text: "**λ = c / f** = 300.000.000 m/s ÷ \(deNumber(frequency / 1e6)) MHz = **\(deNumber(lambda * 100, maxDigits: 2)) cm**\nHöhere Frequenz → kürzere Wellenlänge (umgekehrt proportional).")
        }
    }
}

// MARK: - NVP-Wettrennen (T1 S.37)

struct NVPRaceLab: View {
    private let media: [(String, Double)] = [
        ("Funk", 1.0), ("Koax", 0.82), ("Cat7", 0.79), ("Glasfaser", 0.67), ("Cat5e", 0.64)
    ]
    @State private var running = false
    @State private var km = 1000.0

    var body: some View {
        VizCard(title: "Labor: Wie schnell ist welches Medium?") {
            ForEach(Array(media.enumerated()), id: \.offset) { _, medium in
                let ms = km / (300_000 * medium.1) * 1000
                HStack(spacing: 6) {
                    Text(medium.0).font(.caption2).frame(width: 58, alignment: .trailing)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.secondary.opacity(0.15))
                            Circle()
                                .fill(Theme.primary)
                                .frame(width: 14, height: 14)
                                .offset(x: running ? geo.size.width - 14 : 0)
                                .animation(
                                    running ? Animation.linear(duration: 2.2 / medium.1) : Animation.default,
                                    value: running
                                )
                        }
                    }
                    .frame(height: 14)
                    Text("\(deNumber(ms, maxDigits: 2)) ms")
                        .font(.caption2.monospacedDigit())
                        .frame(width: 58, alignment: .leading)
                }
            }
            HStack {
                Text("Strecke: \(Int(km)) km").font(.caption)
                Slider(value: $km, in: 100...10000, step: 100)
            }
            Button(running ? "Zurück" : "Start") { running.toggle() }
                .liquidButton()
            CaptionBox(text: "**t = d / (NVP · c)** – das Medium „bremst“ das Signal. Funk ist fast so schnell wie Licht im Vakuum, Cat5e schafft nur 64 %.")
        }
    }
}

// MARK: - Multiplexverfahren (T1 S.38)

struct MultiplexLab: View {
    @State private var mode = 0
    private let names = ["FDM", "TDM", "CDM", "Raum", "WDM"]
    private let texts = [
        "**Frequenzmultiplex:** Einzelne Kanäle liegen in benachbarten Trägerfrequenzbändern – alle senden gleichzeitig.",
        "**Zeitmultiplex:** Synchron mit festen Zeitschlitzen pro Kanal, asynchron mit Paketen nach Bedarf.",
        "**Codemultiplex:** Alle senden gleichzeitig auf derselben Frequenz. Datenpakete werden anhand ihrer Codierung erkannt (z. B. UMTS).",
        "**Raummultiplex:** Physische Trennung – z. B. Bündel von Kabeln oder sektorisierte Antennen.",
        "**Wellenlängenmultiplex:** Auf Glasfaser, Prinzip wie FDM. Unterschieden werden DWDM (Dense) und CWDM (Coarse)."
    ]
    private let colors: [Color] = [Theme.primary, Theme.good, Theme.warn, Theme.violet]

    var body: some View {
        VizCard(title: "Labor: Multiplexverfahren") {
            Picker("Verfahren", selection: $mode) {
                ForEach(0..<names.count, id: \.self) { i in
                    Text(names[i]).tag(i)
                }
            }
            .pickerStyle(.segmented)
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    draw(context: context, size: size, t: t)
                }
            }
            .frame(height: 130)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            HStack {
                Text(mode == 3 ? "Nebeneinander im Raum" : "Zeit →")
                Spacer()
                Text(mode == 3 || mode == 4 ? "" : "Höhe = Frequenz")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            CaptionBox(text: texts[mode])
        }
    }

    private func draw(context: GraphicsContext, size: CGSize, t: Double) {
        let n = colors.count
        switch mode {
        case 0, 4:
            let h = size.height / CGFloat(n)
            for i in 0..<n {
                let rect = CGRect(x: 0, y: CGFloat(i) * h + 2, width: size.width, height: h - 4)
                context.fill(Path(rect), with: .color(colors[i].opacity(0.75)))
            }
        case 1:
            let w = size.width / 8
            let offset = CGFloat(t.truncatingRemainder(dividingBy: 4.0) / 4.0) * w * CGFloat(n)
            for i in -n..<12 {
                let rect = CGRect(x: CGFloat(i) * w + offset, y: 0, width: w - 2, height: size.height)
                let colorIndex = ((i % n) + n) % n
                context.fill(Path(rect), with: .color(colors[colorIndex].opacity(0.75)))
            }
        case 2:
            for i in 0..<n {
                var path = Path()
                var x: CGFloat = 0
                let amp = size.height * 0.30
                let frequency = Double(i + 1) * 3
                while x <= size.width {
                    let phase = Double(x / size.width) * frequency * 2 * .pi + t * 2
                    let code: Double = sin(phase) >= 0 ? 1 : -1
                    let y = size.height / 2 + CGFloat(code) * amp * CGFloat(1 - Double(i) * 0.2)
                    if x == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    x += 2
                }
                context.stroke(path, with: .color(colors[i].opacity(0.8)), lineWidth: 1.5)
            }
        default:
            let h = size.height / CGFloat(n)
            for i in 0..<n {
                let y = CGFloat(i) * h + h / 2
                var line = Path()
                line.move(to: CGPoint(x: 0, y: y))
                line.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(line, with: .color(Color.secondary.opacity(0.5)), lineWidth: 5)
                let x = CGFloat((t * 0.25 + Double(i) * 0.3).truncatingRemainder(dividingBy: 1.0)) * size.width
                let dot = CGRect(x: x - 7, y: y - 7, width: 14, height: 14)
                context.fill(Path(ellipseIn: dot), with: .color(colors[i]))
            }
        }
    }
}

// MARK: - TCP Slow Start & Stauvermeidung (T1 S.105-106)

struct CwndLab: View {
    @State private var threshold = 16
    @State private var values: [(cwnd: Int, thresh: Int)] = [(1, 16)]

    private var currentThreshold: Int { values.last?.thresh ?? threshold }
    private var cwnd: Int { values.last?.cwnd ?? 1 }

    var body: some View {
        VizCard(title: "Labor: Staukontrolle live") {
            Canvas { context, size in
                let maxY = CGFloat(max(40, (values.map { max($0.cwnd, $0.thresh) }.max() ?? 40) + 4))
                let maxX = CGFloat(max(30, values.count))
                func point(_ i: Int, _ v: Int) -> CGPoint {
                    CGPoint(x: CGFloat(i) / maxX * size.width, y: size.height - CGFloat(v) / maxY * size.height)
                }
                var threshPath = Path()
                var linePath = Path()
                for (i, value) in values.enumerated() {
                    if i == 0 {
                        threshPath.move(to: point(i, value.thresh))
                        linePath.move(to: point(i, value.cwnd))
                    } else {
                        threshPath.addLine(to: point(i, value.thresh))
                        linePath.addLine(to: point(i, value.cwnd))
                    }
                }
                context.stroke(threshPath, with: .color(Theme.warn), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                context.stroke(linePath, with: .color(Theme.bad), lineWidth: 2.5)
            }
            .frame(height: 150)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            HStack {
                Text("CWND: \(cwnd) MSS").bold()
                Spacer()
                Text("Schwellwert: \(currentThreshold) MSS").foregroundStyle(Theme.warn)
            }
            .font(.caption)
            CaptionBox(text: cwnd < currentThreshold
                ? "**Slow Start:** exponentiell – jedes ACK verdoppelt das CWND, bis der Schwellwert erreicht ist."
                : "**Stauvermeidung:** Ab dem Schwellwert wächst das Fenster nur noch linear, bis eine Zeitüberschreitung eintritt.")
            HStack {
                Button("ACK empfangen") { ack() }
                    .liquidButton()
                Button("Timeout!") { timeout() }
                    .liquidButton(prominent: false)
                    .tint(Theme.bad)
                Button("Neu") { values = [(1, 16)] }
                    .liquidButton(prominent: false)
            }
        }
    }

    private func ack() {
        let t = currentThreshold
        let next = cwnd < t ? min(cwnd * 2, t) : cwnd + 1
        withAnimation { values.append((next, t)) }
    }

    private func timeout() {
        let t = max(currentThreshold / 2, 1)
        withAnimation { values.append((1, t)) }
    }
}

// MARK: - SRTT (T1 S.99)

struct SrttLab: View {
    private let alpha = 0.875
    @State private var rtt = 100.0
    @State private var srtt = 100.0
    @State private var beta = 2.0
    @State private var backoffs = 0
    @State private var history: [(rtt: Double, srtt: Double)] = [(100, 100)]

    var body: some View {
        let timeoutValue = beta * srtt * pow(2, Double(backoffs))
        VizCard(title: "Labor: Geglättete RTT") {
            Canvas { context, size in
                let top = max(history.map { max($0.rtt, $0.srtt) }.max() ?? 1, 1) * 1.15
                func line(_ values: [Double], _ color: Color, _ width: CGFloat) {
                    var path = Path()
                    for (i, v) in values.enumerated() {
                        let x = values.count > 1 ? CGFloat(i) / CGFloat(values.count - 1) * size.width : 0
                        let point = CGPoint(x: x, y: size.height - CGFloat(v / top) * size.height)
                        if i == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                    context.stroke(path, with: .color(color), lineWidth: width)
                }
                line(history.map { $0.rtt }, Color.secondary.opacity(0.7), 1.5)
                line(history.map { $0.srtt }, Theme.primary, 3)
            }
            .frame(height: 110)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            HStack {
                Label("gemessene RTT", systemImage: "minus").foregroundStyle(.secondary)
                Label("SRTT", systemImage: "minus").foregroundStyle(Theme.primary)
            }
            .font(.caption2)
            HStack {
                Text("RTT \(Int(rtt)) ms").font(.caption).frame(width: 84, alignment: .leading)
                Slider(value: $rtt, in: 10...400, step: 5)
            }
            HStack {
                Text("β = \(deNumber(beta, maxDigits: 1))").font(.caption).frame(width: 84, alignment: .leading)
                Slider(value: $beta, in: 1.2...4, step: 0.1)
            }
            CaptionBox(text: "SRTT = 0,875 · SRTT + 0,125 · RTT = **\(deNumber(srtt, maxDigits: 2)) ms**\nTimeout = β · SRTT\(backoffs > 0 ? " · 2^\(backoffs)" : "") = **\(deNumber(timeoutValue, maxDigits: 2)) ms**")
            HStack {
                Button("ACK eintreffen lassen") {
                    srtt = alpha * srtt + (1 - alpha) * rtt
                    backoffs = 0
                    withAnimation { history.append((rtt, srtt)) }
                }
                .liquidButton()
                Button("Timeout (Back-off)") { backoffs += 1 }
                    .liquidButton(prominent: false)
                    .tint(Theme.bad)
            }
        }
    }
}

// MARK: - Flusskontrolle (T1 S.102)

struct FlowControlLab: View {
    private struct State2 {
        let fill: Double
        let offset: Double
        let text: String
    }
    private let states: [State2] = [
        State2(fill: 0, offset: 0, text: "Der Empfangspuffer ist **4K** groß und leer."),
        State2(fill: 2, offset: 0, text: "Sender schickt **2K (SEQ=0)**. Empfänger: **ACK=2048, WIN=2048** – noch 2K frei."),
        State2(fill: 4, offset: 0, text: "Sender schickt **2K (SEQ=2048)**. Empfänger: **ACK=4096, WIN=0** – Puffer voll, der Sender ist blockiert."),
        State2(fill: 2, offset: 2, text: "Die Applikation liest 2K. Empfänger: **ACK=4096, WIN=2048** – der Sender darf wieder bis zu 2K schicken."),
        State2(fill: 3, offset: 2, text: "Sender schickt **1K (SEQ=4096)**. Damit sind 3K im Puffer. Die Window Size zeigt immer den noch freien Platz.")
    ]
    @State private var step = 0

    var body: some View {
        let state = states[step]
        VizCard(title: "Labor: Empfangspuffer") {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6).fill(Theme.primary.opacity(0.12))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.primary)
                        .frame(width: geo.size.width * CGFloat(state.fill / 4))
                    Text("\(deNumber(state.fill))K belegt · WIN = \(deNumber((4 - state.fill) * 1024)) Bytes")
                        .font(.caption.bold())
                        .padding(.leading, 8)
                        .foregroundStyle(state.fill > 1 ? Color.white : Color.primary)
                }
            }
            .frame(height: 38)
            .animation(.spring(response: 0.5), value: step)
            CaptionBox(text: state.text)
            StepControls(step: $step, maxStep: states.count - 1, interval: 3.0)
        }
    }
}

// MARK: - Slotted ALOHA (T2 S.43-44)

struct AlohaLab: View {
    @State private var p = 0.33
    @State private var slots: [[Bool]] = AlohaLab.roll(p: 0.33)
    @State private var revealed = 0
    private static let slotCount = 24

    private static func roll(p: Double) -> [[Bool]] {
        (0..<3).map { _ in (0..<slotCount).map { _ in Double.random(in: 0...1) < p } }
    }

    private func letter(_ i: Int) -> String {
        let senders = slots.filter { $0[i] }.count
        return senders == 0 ? "E" : (senders == 1 ? "S" : "C")
    }

    var body: some View {
        let shown = min(revealed, Self.slotCount)
        let success = (0..<shown).filter { letter($0) == "S" }.count
        VizCard(title: "Labor: Slotted ALOHA") {
            VStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { node in
                    HStack(spacing: 1) {
                        Text("K\(node + 1)").font(.caption2).frame(width: 22)
                        ForEach(0..<Self.slotCount, id: \.self) { slot in
                            Rectangle()
                                .fill(slot < shown && slots[node][slot] ? nodeColor(node) : Color.secondary.opacity(0.1))
                                .frame(height: 16)
                        }
                    }
                }
                HStack(spacing: 1) {
                    Spacer().frame(width: 22)
                    ForEach(0..<Self.slotCount, id: \.self) { slot in
                        let l = slot < shown ? letter(slot) : " "
                        Text(l)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(l == "S" ? Theme.good : (l == "C" ? Theme.bad : Color.secondary))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            HStack {
                Text("p = \(deNumber(p, maxDigits: 2))").font(.caption).frame(width: 60, alignment: .leading)
                Slider(value: $p, in: 0.05...0.9, step: 0.05)
            }
            CaptionBox(text: "**S** = Erfolg, **C** = Kollision, **E** = leer.\nGenutzt: **\(success) von \(shown)** Slots. Laut Skript sind maximal **37 %** der Kanalkapazität nutzbar (unslotted ALOHA: 18 %).")
            Button("Neu würfeln") { restart() }
                .liquidButton()
        }
        .task(id: revealed) {
            guard revealed < Self.slotCount else { return }
            try? await Task.sleep(nanoseconds: 180_000_000)
            if !Task.isCancelled { revealed += 1 }
        }
    }

    private func restart() {
        slots = Self.roll(p: p)
        revealed = 0
    }

    private func nodeColor(_ node: Int) -> Color {
        [Theme.warn, Theme.good, Theme.violet][node]
    }
}

// MARK: - Exponential Backoff (T2 S.55)

struct BackoffLab: View {
    @State private var m = 1
    @State private var picked = 0
    private let bitrate = 10.0

    var body: some View {
        let count = Int(pow(2.0, Double(m)))
        VizCard(title: "Labor: Exponential Backoff") {
            Stepper("m-te Kollision: **\(m)**", value: $m, in: 1...6)
                .onChange(of: m) { _, _ in picked = 0 }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 16), spacing: 3) {
                ForEach(0..<count, id: \.self) { k in
                    Text("\(k)")
                        .font(.system(size: 9, weight: .semibold).monospacedDigit())
                        .foregroundStyle(k == picked ? Color.white : Color.primary)
                        .frame(maxWidth: .infinity, minHeight: 18)
                        .background(k == picked ? Theme.warn : Theme.primary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
            CaptionBox(text: "K wird zufällig aus **{0 … \(count - 1)}** gewählt (2^m − 1 = \(count - 1)).\nGewählt: **K = \(picked)** → Wartezeit K × 512 Bit = **\(picked * 512) Bitzeiten**, das sind bei 10 Mbit/s **\(deNumber(Double(picked) * 512 / bitrate, maxDigits: 1)) µs**.")
            Button("Adapter würfelt K") {
                withAnimation(.spring(response: 0.3)) { picked = Int.random(in: 0..<count) }
            }
            .liquidButton()
        }
    }
}

// MARK: - Manchester (T2 S.47)

struct ManchesterLab: View {
    @State private var bits = [1, 0, 0, 0, 1, 0, 0, 1]

    var body: some View {
        VizCard(title: "Labor: Manchester Encoding") {
            Text("Tippe auf die Bits, um sie umzuschalten.").font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 0) {
                ForEach(0..<bits.count, id: \.self) { i in
                    Button {
                        withAnimation { bits[i] = 1 - bits[i] }
                    } label: {
                        Text("\(bits[i])")
                            .font(.headline.monospaced())
                            .frame(maxWidth: .infinity, minHeight: 32)
                            .background(bits[i] == 1 ? Theme.primary.opacity(0.2) : Color.secondary.opacity(0.08))
                    }
                    .buttonStyle(.plain)
                }
            }
            Text("Binär").font(.caption2).foregroundStyle(.secondary)
            signal(manchester: false).frame(height: 44)
            Text("Manchester").font(.caption2).foregroundStyle(.secondary)
            signal(manchester: true).frame(height: 44)
            CaptionBox(text: "**Jedes Bit hat einen Übergang** in der Bitmitte (hier wie auf der Folie: 1 = hoch→tief, 0 = tief→hoch). Dadurch können sich Sender und Empfänger ohne zentrale Uhr synchronisieren.")
        }
    }

    private func signal(manchester: Bool) -> some View {
        Canvas { context, size in
            let w = size.width / CGFloat(bits.count)
            let hi: CGFloat = 4
            let lo = size.height - 4
            var path = Path()
            for (i, bit) in bits.enumerated() {
                let x = CGFloat(i) * w
                if manchester {
                    let first = bit == 1 ? hi : lo
                    let second = bit == 1 ? lo : hi
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: first))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: first))
                    }
                    path.addLine(to: CGPoint(x: x + w / 2, y: first))
                    path.addLine(to: CGPoint(x: x + w / 2, y: second))
                    path.addLine(to: CGPoint(x: x + w, y: second))
                } else {
                    let y = bit == 1 ? hi : lo
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    path.addLine(to: CGPoint(x: x + w, y: y))
                }
            }
            context.stroke(path, with: .color(manchester ? Theme.bad : Theme.primary), lineWidth: 2)
            for i in 0...bits.count {
                var grid = Path()
                grid.move(to: CGPoint(x: CGFloat(i) * w, y: 0))
                grid.addLine(to: CGPoint(x: CGFloat(i) * w, y: size.height))
                context.stroke(grid, with: .color(Color.secondary.opacity(0.25)), lineWidth: 0.5)
            }
        }
    }
}

// MARK: - 4B/5B (T2 S.48)

enum Code4B5B {
    static let table: [String: String] = [
        "0000": "11110", "0001": "01001", "0010": "10100", "0011": "10101",
        "0100": "01010", "0101": "01011", "0110": "01110", "0111": "01111",
        "1000": "10010", "1001": "10011", "1010": "10110", "1011": "10111",
        "1100": "11010", "1101": "11011", "1110": "11100", "1111": "11101"
    ]
}

struct B4B5Lab: View {
    @State private var bits = [0, 0, 0, 0]

    var body: some View {
        let key = bits.map { String($0) }.joined()
        let coded = Code4B5B.table[key] ?? ""
        VizCard(title: "Labor: 4B/5B Code") {
            Text("Original: 4 Bit (tippen)").font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    Button {
                        withAnimation { bits[i] = 1 - bits[i] }
                    } label: {
                        Text("\(bits[i])")
                            .font(.title3.monospaced().bold())
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .background(Theme.primary.opacity(bits[i] == 1 ? 0.3 : 0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
            Image(systemName: "arrow.down").frame(maxWidth: .infinity).foregroundStyle(Theme.primary)
            HStack(spacing: 6) {
                ForEach(Array(coded.enumerated()), id: \.offset) { _, c in
                    Text(String(c))
                        .font(.title3.monospaced().bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 42)
                        .background(Theme.good)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            CaptionBox(text: "**\(key) → \(coded)**\nDie Codierung stellt mindestens einen Übergang sicher: maximal **3** aufeinanderfolgende 0-er und maximal **8** aufeinanderfolgende 1-er Bits. Aus 4 Datenbits werden 5 Leitungsbits.")
        }
    }
}

// MARK: - Zweidimensionale Parität (T2 S.40)

struct ParityLab: View {
    private let original: [[Int]] = [
        [1, 0, 1, 0, 1, 1],
        [1, 1, 1, 1, 0, 0],
        [0, 1, 1, 1, 0, 1],
        [0, 0, 1, 0, 1, 0]
    ]
    @State private var grid: [[Int]] = [
        [1, 0, 1, 0, 1, 1],
        [1, 1, 1, 1, 0, 0],
        [0, 1, 1, 1, 0, 1],
        [0, 0, 1, 0, 1, 0]
    ]

    private var badRows: [Int] {
        grid.indices.filter { r in grid[r].reduce(0, +) % 2 != 0 }
    }

    private var badColumns: [Int] {
        (0..<grid[0].count).filter { c in grid.map { $0[c] }.reduce(0, +) % 2 != 0 }
    }

    var body: some View {
        VizCard(title: "Labor: Two Dimensional Bit Parity") {
            Text("Tippe auf ein Bit, um einen Übertragungsfehler zu erzeugen.")
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(spacing: 3) {
                ForEach(grid.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(grid[r].indices, id: \.self) { c in
                            cell(r, c)
                        }
                    }
                }
            }
            CaptionBox(text: resultText)
            Button("Zurücksetzen") { withAnimation { grid = original } }
                .liquidButton(prominent: false)
        }
    }

    private func cell(_ r: Int, _ c: Int) -> some View {
        let isParity = r == grid.count - 1 || c == grid[0].count - 1
        let flagged = badRows.contains(r) || badColumns.contains(c)
        let changed = grid[r][c] != original[r][c]
        let background: Color = changed ? Theme.bad : (flagged ? Theme.warn.opacity(0.35) : (isParity ? Theme.teal.opacity(0.22) : Theme.primary.opacity(0.1)))
        return Button {
            withAnimation { grid[r][c] = 1 - grid[r][c] }
        } label: {
            Text("\(grid[r][c])")
                .font(.body.monospaced().bold())
                .foregroundStyle(changed ? Color.white : Color.primary)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }

    private var resultText: String {
        if badRows.isEmpty && badColumns.isEmpty {
            return "**Keine Fehler erkannt:** Jede Zeile und Spalte hat eine gerade Anzahl Einsen. Blaugrün = Paritätsbits."
        }
        if badRows.count == 1 && badColumns.count == 1 {
            return "**Korrigierbarer 1-Bit-Fehler:** Paritätsfehler in Zeile \(badRows[0] + 1) und Spalte \(badColumns[0] + 1). Der Schnittpunkt ist das falsche Bit."
        }
        return "**Fehler erkannt:** \(badRows.count) Zeile(n) und \(badColumns.count) Spalte(n) fallen auf. Der Fehler lässt sich nicht eindeutig einem Bit zuordnen."
    }
}

// MARK: - CAN Differenzsignal (T2 S.75)

struct CanSignalLab: View {
    @State private var disturbance = false
    private let bits = [1, 0, 1, 0, 0, 1, 0, 1]

    var body: some View {
        VizCard(title: "Labor: CAN High / CAN Low") {
            Toggle("Externe Störung einkoppeln", isOn: $disturbance.animation())
            Canvas { context, size in
                let w = size.width / CGFloat(bits.count)
                let scale = size.height / 4.5
                func y(_ volt: Double) -> CGFloat { size.height - CGFloat(volt) * scale }
                var high = Path()
                var low = Path()
                for (i, bit) in bits.enumerated() {
                    let x = CGFloat(i) * w
                    let spike = disturbance && (i == 2 || i == 5) ? 0.5 : 0.0
                    let hv = (bit == 0 ? 3.5 : 2.5) + spike
                    let lv = (bit == 0 ? 1.5 : 2.5) + spike
                    if i == 0 {
                        high.move(to: CGPoint(x: x, y: y(hv)))
                        low.move(to: CGPoint(x: x, y: y(lv)))
                    } else {
                        high.addLine(to: CGPoint(x: x, y: y(hv)))
                        low.addLine(to: CGPoint(x: x, y: y(lv)))
                    }
                    high.addLine(to: CGPoint(x: x + w, y: y(hv)))
                    low.addLine(to: CGPoint(x: x + w, y: y(lv)))
                }
                context.stroke(high, with: .color(Theme.warn), lineWidth: 2.5)
                context.stroke(low, with: .color(Theme.good), lineWidth: 2.5)
            }
            .frame(height: 120)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            HStack(spacing: 0) {
                ForEach(0..<bits.count, id: \.self) { i in
                    Text(bits[i] == 0 ? "dom" : "rez")
                        .font(.system(size: 9))
                        .foregroundStyle(bits[i] == 0 ? Theme.bad : Color.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            MiniTable(title: nil, head: ["Zustand", "CAN High", "CAN Low", "Differenz", "Bit"], rows: [
                ["Rezessiv", "2,5 V", "2,5 V", "0 V", "1"],
                ["Dominant", "3,5 V", "1,5 V", "2 V", "0"]
            ])
            CaptionBox(text: disturbance
                ? "**Störung:** Beide Leitungen werden gleich beeinflusst – die Differenz bleibt bei 2 V, die Nachricht ist geschützt."
                : "Orange = CAN High, Grün = CAN Low. Ausgewertet wird die **Spannungsdifferenz** zwischen beiden.")
        }
    }
}

// MARK: - Zellulare Netze (T1 S.118)

struct CellReuseLab: View {
    @State private var small = false
    private let colors: [Color] = [Theme.primary, Theme.good, Theme.warn]

    var body: some View {
        VizCard(title: "Labor: Frequenz-Wiederverwendung") {
            Toggle("Kleinere Zellen (dicht besiedelt)", isOn: $small.animation())
            Canvas { context, size in
                let r: CGFloat = small ? 15 : 30
                let dx = r * 1.5
                let dy = r * sqrt(3.0)
                var col = 0
                var x: CGFloat = 0
                while x < size.width + r {
                    var row = 0
                    var y: CGFloat = col % 2 == 0 ? 0 : dy / 2
                    while y < size.height + r {
                        var hex = Path()
                        for k in 0..<6 {
                            let a = CGFloat(k) * .pi / 3
                            let p = CGPoint(x: x + r * cos(a), y: y + r * sin(a))
                            if k == 0 {
                                hex.move(to: p)
                            } else {
                                hex.addLine(to: p)
                            }
                        }
                        hex.closeSubpath()
                        let group = (((row * 2 + (col % 2)) % 3) + (col / 2) * 2) % 3
                        context.fill(hex, with: .color(colors[group].opacity(0.45)))
                        context.stroke(hex, with: .color(Color.white), lineWidth: 1)
                        row += 1
                        y += dy
                    }
                    col += 1
                    x += dx
                }
            }
            .frame(height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            CaptionBox(text: small
                ? "**Kleinere Zellen:** Dieselben drei Kanalgruppen werden viel öfter wiederverwendet – die Kapazität steigt, aber auch die Interferenz wird zum Hauptproblem."
                : "**Jede Farbe = eine Kanalgruppe.** Benachbarte Zellen bekommen unterschiedliche Gruppen. Durch begrenzte Funkreichweite lassen sich Gruppen in entfernten Zellen wiederverwenden.")
        }
    }
}

// MARK: - QoS Warteschlange (T2 S.97-98)

struct QosQueueLab: View {
    private enum Packet { case media, ftp }
    @State private var queue: [Packet] = []
    @State private var priority = false
    @State private var mediaLost = 0
    @State private var mediaSent = 0
    @State private var tick = 0
    private let capacity = 8

    var body: some View {
        VizCard(title: "Labor: Warteschlange am Router R1") {
            Toggle("Medienpakete priorisieren", isOn: $priority)
            HStack(spacing: 3) {
                ForEach(0..<capacity, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color(at: i))
                        .frame(height: 28)
                }
                Image(systemName: "arrow.right").foregroundStyle(.secondary)
                Text("1,5 Mbps").font(.caption2)
            }
            .animation(.easeInOut(duration: 0.25), value: queue.count)
            HStack {
                Label("Medien", systemImage: "square.fill").foregroundStyle(Theme.bad)
                Label("FTP-Burst", systemImage: "square.fill").foregroundStyle(Theme.primary)
            }
            .font(.caption2)
            CaptionBox(text: "Verworfene Medienpakete: **\(mediaLost)** von \(mediaLost + mediaSent).\n" + (priority
                ? "Mit Kennzeichnung und Vorrangregel verdrängen Medienpakete FTP-Pakete aus der Warteschlange (Prinzip 1)."
                : "Ohne Vorrang können FTP-Bursts den Router überlasten – Medienpakete werden verworfen."))
            Button("Zähler zurücksetzen") {
                mediaLost = 0
                mediaSent = 0
            }
            .liquidButton(prominent: false)
        }
        .task(id: tick) {
            try? await Task.sleep(nanoseconds: 450_000_000)
            if Task.isCancelled { return }
            simulate()
            tick += 1
        }
    }

    private func color(at index: Int) -> Color {
        guard index < queue.count else { return Color.secondary.opacity(0.1) }
        return queue[index] == .media ? Theme.bad : Theme.primary
    }

    private func simulate() {
        if !queue.isEmpty { queue.removeFirst() }
        if tick % 2 == 0 { enqueue(.media) }
        if tick % 12 < 6 {
            enqueue(.ftp)
            enqueue(.ftp)
        }
    }

    private func enqueue(_ packet: Packet) {
        if packet == .media && priority {
            if queue.count >= capacity, let index = queue.lastIndex(of: .ftp) {
                queue.remove(at: index)
            }
            if queue.count < capacity {
                let insertAt = queue.lastIndex(of: .media).map { $0 + 1 } ?? 0
                queue.insert(.media, at: insertAt)
                mediaSent += 1
            } else {
                mediaLost += 1
            }
            return
        }
        if queue.count < capacity {
            queue.append(packet)
            if packet == .media { mediaSent += 1 }
        } else if packet == .media {
            mediaLost += 1
        }
    }
}

// MARK: - HTTP RTT-Vergleich (T2 S.11-12)

struct HttpRttLab: View {
    @State private var objects = 5.0

    var body: some View {
        let n = Int(objects)
        let rows: [(String, Int, Color)] = [
            ("Non-persistent", 2 * (n + 1), Theme.bad),
            ("Persistent ohne Pipelining", n + 2, Theme.warn),
            ("Persistent mit Pipelining", n > 0 ? 3 : 2, Theme.good)
        ]
        let top = max(rows.map { $0.1 }.max() ?? 1, 1)
        VizCard(title: "Labor: Wie viele RTTs braucht eine Webseite?") {
            HStack {
                Text("\(n) referenzierte Objekte").font(.caption).frame(width: 150, alignment: .leading)
                Slider(value: $objects, in: 0...20, step: 1)
            }
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.0).font(.caption2)
                    GeometryReader { geo in
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(row.2)
                                .frame(width: max((geo.size.width - 60) * CGFloat(row.1) / CGFloat(top), 4))
                            Text("\(row.1) RTT").font(.caption.bold().monospacedDigit())
                        }
                    }
                    .frame(height: 18)
                }
            }
            .animation(.spring(response: 0.4), value: n)
            CaptionBox(text: "Die Webseite = 1 HTML-Basisdatei + \(n) Objekte (ohne Übertragungszeit, im besten Fall).\nNon-persistent: 2 RTT pro Objekt. Persistent: 1 RTT TCP-Aufbau + 1 RTT Basisdatei + 1 RTT je Objekt – mit Pipelining 1 RTT für alle Objekte zusammen.")
        }
    }
}
