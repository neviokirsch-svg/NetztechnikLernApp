import SwiftUI

enum ReviewBuilder {
    /// Baut aus Lernstand-IDs Fragen; Rechenaufgaben erhalten neue Zahlen.
    static func questions(ids: [String], library: ContentLibrary) -> [Question] {
        ids.compactMap { id -> Question? in
            if let generator = CalcEngine.generator(id: id) { return generator.make() }
            return library.question(id: id)?.0
        }
    }
}

// MARK: - Wiederholen

struct ReviewHubView: View {
    @EnvironmentObject var library: ContentLibrary
    @EnvironmentObject var progress: ProgressStore
    @State private var tab = 0
    @State private var quiz: QuizConfig?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("Ansicht", selection: $tab) {
                        Text("Fällig").tag(0)
                        Text("Schwächen").tag(1)
                        Text("Gelerntes").tag(2)
                    }
                    .pickerStyle(.segmented)

                    switch tab {
                    case 0: dueView
                    case 1: weakView
                    default: learnedView
                    }
                }
                .padding()
            }
            .liquidScreen()
            .navigationTitle("Wiederholen")
            .fullScreenCover(item: $quiz) { QuizSessionView(config: $0) }
        }
    }

    private var dueView: some View {
        let due = progress.dueItemIDs()
        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(due.isEmpty ? "Alles erledigt" : "\(due.count) Aufgaben sind fällig")
                    .font(.title3.bold())
                Text("Die App merkt sich jede Antwort. Richtig beantwortete Aufgaben kommen in immer größeren Abständen wieder, falsche schon nach kurzer Zeit.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                if !due.isEmpty {
                    Button {
                        quiz = QuizConfig(title: "Wiederholung", questions: ReviewBuilder.questions(ids: due, library: library))
                    } label: {
                        Label("Jetzt wiederholen", systemImage: "play.fill").mainAction()
                    }
                    .liquidButton()
                }
            }
            .card()
            itemList(due)
        }
    }

    private var weakView: some View {
        let weak = progress.weakItemIDs()
        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(weak.isEmpty ? "Keine Schwächen gespeichert" : "\(weak.count) Schwachstellen")
                    .font(.title3.bold())
                Text("Aufgaben, die du zuletzt falsch hattest oder noch nicht sicher kannst.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                if !weak.isEmpty {
                    Button {
                        quiz = QuizConfig(title: "Schwächen trainieren", questions: ReviewBuilder.questions(ids: weak, library: library))
                    } label: {
                        Label("Schwächen trainieren", systemImage: "bolt.fill").mainAction()
                    }
                    .liquidButton()
                }
            }
            .card()
            itemList(weak)
        }
    }

    private var learnedView: some View {
        let learned = progress.learnedItemIDs()
        let readModules = library.modules.filter { m in m.sections.contains { progress.isRead($0.id) } }
        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Alles, was du schon gelernt hast").font(.title3.bold())
                Text("\(progress.data.readSections.count) Abschnitte gelesen · \(learned.count) Aufgaben bearbeitet")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                if !learned.isEmpty {
                    Button {
                        let sample = Array(learned.shuffled().prefix(15))
                        quiz = QuizConfig(title: "Gemischte Wiederholung", questions: ReviewBuilder.questions(ids: sample, library: library))
                    } label: {
                        Label("15 zufällige Aufgaben", systemImage: "shuffle").mainAction()
                    }
                    .liquidButton()
                }
            }
            .card()
            if !readModules.isEmpty {
                Text("Nochmal lesen").font(.headline)
                ForEach(readModules) { module in
                    NavigationLink {
                        ModuleDetailView(module: module)
                    } label: {
                        ModuleRow(module: module)
                    }
                    .buttonStyle(.plain)
                }
            }
            if !learned.isEmpty {
                Text("Bearbeitete Aufgaben").font(.headline)
                itemList(learned)
            }
        }
    }

    @ViewBuilder
    private func itemList(_ ids: [String]) -> some View {
        ForEach(ids.prefix(60), id: \.self) { id in
            let state = progress.state(id)
            Button {
                quiz = QuizConfig(title: "Einzelaufgabe", questions: ReviewBuilder.questions(ids: [id], library: library))
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: (state?.lastCorrect ?? false) ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle((state?.lastCorrect ?? false) ? Theme.good : Theme.bad)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(itemTitle(id))
                            .font(.subheadline)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Text("\(state?.correct ?? 0)× richtig, \(state?.wrong ?? 0)× falsch")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .card(cornerRadius: 16)
            }
            .buttonStyle(.plain)
        }
    }

    private func itemTitle(_ id: String) -> String {
        if let generator = CalcEngine.generator(id: id) { return generator.title }
        let raw = library.question(id: id)?.0.q ?? id
        return raw.replacingOccurrences(of: "**", with: "")
    }
}

// MARK: - Rechentrainer

struct CalcHubView: View {
    @EnvironmentObject var progress: ProgressStore
    @State private var quiz: QuizConfig?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rechentrainer").font(.title3.bold())
                        Text("Jede Aufgabe wird mit neuen Zahlen erzeugt und mit Rechenweg erklärt. Alle Formeln und Werte stammen aus dem Skript.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Button {
                            let mix = CalcEngine.all.shuffled().prefix(10).map { $0.make() }
                            quiz = QuizConfig(title: "Rechen-Mix", questions: Array(mix))
                        } label: {
                            Label("10 gemischte Aufgaben", systemImage: "shuffle").mainAction()
                        }
                        .liquidButton()
                    }
                    .card()

                    ForEach(CalcEngine.groups, id: \.self) { group in
                        Text(group).font(.headline).padding(.top, 6)
                        ForEach(CalcEngine.all.filter { $0.group == group }) { generator in
                            Button {
                                let tasks = (0..<5).map { _ in generator.make() }
                                quiz = QuizConfig(title: generator.title, questions: tasks)
                            } label: {
                                CalcRow(generator: generator, state: progress.state(generator.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .liquidScreen()
            .navigationTitle("Rechnen")
            .fullScreenCover(item: $quiz) { QuizSessionView(config: $0) }
        }
    }
}

struct CalcRow: View {
    let generator: CalcGenerator
    let state: ItemState?

    var body: some View {
        HStack(spacing: 12) {
            GlassIcon(systemName: generator.icon, color: Theme.teal, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(generator.title).font(.subheadline.bold()).multilineTextAlignment(.leading)
                Text(generator.formula)
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            if let state = state {
                Image(systemName: state.lastCorrect ? "checkmark.circle.fill" : "arrow.clockwise.circle")
                    .foregroundStyle(state.lastCorrect ? Theme.good : Theme.warn)
            }
        }
        .card(cornerRadius: 18)
    }
}

// MARK: - Klausur-Simulation

struct ExamConfig: Identifiable {
    let id = UUID()
    let minutes: Int
    let questions: [Question]
}

struct ExamHubView: View {
    @EnvironmentObject var library: ContentLibrary
    @EnvironmentObject var progress: ProgressStore
    @State private var minutes = 60
    @State private var partFilter = 0
    @State private var exam: ExamConfig?

    private func buildExam() -> ExamConfig {
        // Annahme bis zur Altklausur: etwa 1 Punkt pro Minute.
        let modules = library.modules.filter { partFilter == 0 || $0.part == partFilter }
        var pool = modules.flatMap { $0.questions }.filter { $0.lvl >= 2 }.shuffled()
        let calcIDs = Set(modules.flatMap { $0.calcIDs })
        var calcs = CalcEngine.all.filter { calcIDs.contains($0.id) }.shuffled().map { $0.make() }
        var picked: [Question] = []
        var points = 0
        var usedTopics: [String: Int] = [:]
        while points < minutes && (!pool.isEmpty || !calcs.isEmpty) {
            // Etwa jede dritte Aufgabe ist eine Rechenaufgabe.
            let next: Question
            if picked.count % 3 == 2, let c = calcs.popLast() {
                next = c
            } else if let q = pool.popLast() {
                next = q
            } else if let c = calcs.popLast() {
                next = c
            } else {
                break
            }
            let topic = String(next.id.prefix(3))
            if usedTopics[topic, default: 0] >= 4 && !next.id.hasPrefix("calc.") && !pool.isEmpty { continue }
            usedTopics[topic, default: 0] += 1
            picked.append(next)
            points += next.pts
        }
        return ExamConfig(minutes: minutes, questions: picked)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Klausur simulieren").font(.title3.bold())
                        Text("Mit Zeitlimit, ohne Hilfe und ohne Lösungen bis zur Abgabe. Fragen aus den Modulen und Rechenaufgaben werden gemischt.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Picker("Dauer", selection: $minutes) {
                            Text("30 Min").tag(30)
                            Text("60 Min").tag(60)
                            Text("90 Min").tag(90)
                        }
                        .pickerStyle(.segmented)
                        Picker("Stoff", selection: $partFilter) {
                            Text("Alles").tag(0)
                            Text("Teil 1").tag(1)
                            Text("Teil 2").tag(2)
                        }
                        .pickerStyle(.segmented)
                        Button {
                            exam = buildExam()
                        } label: {
                            Label("Klausur starten", systemImage: "timer").mainAction()
                        }
                        .liquidButton()
                        Text("Aufbau vorläufig nach Skript (ca. 1 Punkt pro Minute). Mit der Altklausur wird er angepasst.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .card()

                    if !progress.data.exams.isEmpty {
                        Text("Bisherige Versuche").font(.headline)
                        ForEach(progress.data.exams) { result in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(result.date.formatted(date: .abbreviated, time: .shortened)).font(.subheadline)
                                    Text("\(result.minutes) Minuten · \(result.count) Aufgaben")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(Int(result.percent.rounded())) %")
                                    .font(.title3.bold().monospacedDigit())
                                    .foregroundStyle(result.percent >= 50 ? Theme.good : Theme.bad)
                            }
                            .card(cornerRadius: 16)
                        }
                    }
                }
                .padding()
            }
            .liquidScreen()
            .navigationTitle("Klausur")
            .fullScreenCover(item: $exam) { ExamRunView(config: $0) }
        }
    }
}

struct ExamRunView: View {
    let config: ExamConfig
    @EnvironmentObject var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    private enum Stage { case running, reviewOpen, result }

    @State private var stage: Stage = .running
    @State private var index = 0
    @State private var drafts: [String: AnswerDraft] = [:]
    @State private var secondsLeft = 0
    @State private var showAbortAlert = false
    @State private var saved = false

    init(config: ExamConfig) {
        self.config = config
        _secondsLeft = State(initialValue: config.minutes * 60)
        var initial: [String: AnswerDraft] = [:]
        for q in config.questions { initial[q.id] = AnswerDraft.fresh(for: q) }
        _drafts = State(initialValue: initial)
    }

    private var maxPoints: Int { config.questions.reduce(0) { $0 + $1.pts } }

    private func binding(for q: Question) -> Binding<AnswerDraft> {
        Binding(
            get: { drafts[q.id] ?? AnswerDraft.fresh(for: q) },
            set: { drafts[q.id] = $0 }
        )
    }

    private var achieved: Double {
        config.questions.reduce(0.0) { sum, q in
            sum + (drafts[q.id]?.score(for: q) ?? 0) * Double(q.pts)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    switch stage {
                    case .running: runningView
                    case .reviewOpen: reviewOpenView
                    case .result: resultView
                    }
                }
                .padding()
            }
            .liquidScreen()
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(stage == .running ? timeText : "Auswertung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(stage == .result ? "Schließen" : "Abbrechen") {
                        if stage == .result {
                            dismiss()
                        } else {
                            showAbortAlert = true
                        }
                    }
                }
            }
            .alert("Klausur abbrechen?", isPresented: $showAbortAlert) {
                Button("Abbrechen", role: .destructive) { dismiss() }
                Button("Weiter schreiben", role: .cancel) {}
            } message: {
                Text("Dieser Versuch wird nicht gespeichert.")
            }
        }
        .task(id: stage == .running) {
            while stage == .running && secondsLeft > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                secondsLeft -= 1
            }
            if stage == .running { submit() }
        }
    }

    private var timeText: String {
        String(format: "%02d:%02d", secondsLeft / 60, secondsLeft % 60)
    }

    @ViewBuilder
    private var runningView: some View {
        if index < config.questions.count {
            let q = config.questions[index]
            ProgressView(value: Double(index + 1), total: Double(config.questions.count))
                .tint(secondsLeft < 300 ? Theme.bad : Theme.primary)
            HStack {
                Text("Aufgabe \(index + 1) von \(config.questions.count)")
                Spacer()
                Text("\(maxPoints) Punkte gesamt")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 14) {
                QuestionHeader(q: q)
                if let fig = q.fig { BlockView(block: fig) }
            }
            .card()
            .id("head-\(q.id)")
            QuestionInputView(q: q, draft: binding(for: q), locked: false, showSolution: false)
                .card()
                .id("input-\(q.id)")
            HStack {
                Button {
                    if index > 0 { index -= 1 }
                } label: {
                    Label("Zurück", systemImage: "chevron.left").frame(maxWidth: .infinity, minHeight: 30)
                }
                .liquidButton(prominent: false)
                .disabled(index == 0)
                if index + 1 < config.questions.count {
                    Button {
                        index += 1
                    } label: {
                        Label("Weiter", systemImage: "chevron.right").frame(maxWidth: .infinity, minHeight: 30)
                    }
                    .liquidButton()
                } else {
                    Button {
                        submit()
                    } label: {
                        Label("Abgeben", systemImage: "paperplane.fill").frame(maxWidth: .infinity, minHeight: 30)
                    }
                    .liquidButton()
                }
            }
        }
    }

    private var openQuestions: [Question] { config.questions.filter { $0.k == .open } }

    private func submit() {
        stage = openQuestions.isEmpty ? .result : .reviewOpen
        if stage == .result { saveResult() }
    }

    private var reviewOpenView: some View {
        VStack(spacing: 14) {
            Text("Offene Fragen selbst bewerten").font(.title3.bold())
            ForEach(openQuestions) { q in
                VStack(alignment: .leading, spacing: 10) {
                    QuestionHeader(q: q)
                    QuestionInputView(q: q, draft: binding(for: q), locked: true, showSolution: true)
                }
                .card()
            }
            Button {
                stage = .result
                saveResult()
            } label: {
                Text("Auswertung anzeigen").mainAction()
            }
            .liquidButton()
        }
    }

    private func saveResult() {
        guard !saved else { return }
        saved = true
        for q in config.questions {
            let score = drafts[q.id]?.score(for: q) ?? 0
            let rating: AnswerRating = score >= 0.999 ? .good : (score >= 0.5 ? .hard : .wrong)
            progress.record(id: q.id, rating: rating)
        }
        progress.addExam(ExamResult(
            date: Date(),
            points: achieved,
            maxPoints: Double(maxPoints),
            minutes: config.minutes,
            count: config.questions.count
        ))
    }

    private var resultView: some View {
        let ratio = maxPoints > 0 ? achieved / Double(maxPoints) : 0
        return VStack(spacing: 14) {
            VStack(spacing: 10) {
                ZStack {
                    ProgressRing(value: ratio, color: ratio >= 0.5 ? Theme.good : Theme.bad, lineWidth: 12)
                        .frame(width: 130, height: 130)
                    Text("\(Int((ratio * 100).rounded())) %").font(.title.bold())
                }
                Text("\(deNumber(achieved, maxDigits: 1)) von \(maxPoints) Punkten").font(.headline)
            }
            .frame(maxWidth: .infinity)
            .card()
            ForEach(config.questions) { q in
                let draft = binding(for: q)
                VStack(alignment: .leading, spacing: 10) {
                    QuestionHeader(q: q)
                    if let fig = q.fig { BlockView(block: fig) }
                    QuestionInputView(q: q, draft: draft, locked: true, showSolution: true)
                    SolutionPanel(q: q, score: draft.wrappedValue.score(for: q))
                }
                .card()
            }
        }
    }
}
