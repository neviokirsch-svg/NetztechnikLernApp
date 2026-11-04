import SwiftUI

// MARK: - Modulübersicht

struct ModuleListView: View {
    @EnvironmentObject var library: ContentLibrary
    @EnvironmentObject var progress: ProgressStore

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if !library.loadErrors.isEmpty {
                        VStack(alignment: .leading) {
                            Label("Inhalte konnten nicht geladen werden", systemImage: "exclamationmark.triangle")
                                .font(.headline)
                            ForEach(library.loadErrors, id: \.self) { Text($0).font(.caption2) }
                        }
                        .card()
                    }
                    ForEach([3, 1, 2], id: \.self) { part in
                        Text(part == 3 ? "Klausurvorbereitung" : "Skript Teil \(part)")
                            .font(.title3.bold())
                            .padding(.top, 8)
                        ForEach(library.modules.filter { $0.part == part }) { module in
                            NavigationLink {
                                ModuleDetailView(module: module)
                            } label: {
                                ModuleRow(module: module)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .liquidScreen()
            .navigationTitle("Lernen")
        }
    }
}

struct ModuleRow: View {
    let module: LearningModule
    @EnvironmentObject var progress: ProgressStore

    var body: some View {
        HStack(spacing: 12) {
            GlassIcon(systemName: module.icon, color: Theme.partColor(module.part))
            VStack(alignment: .leading, spacing: 2) {
                Text(module.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(module.pages)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            ZStack {
                ProgressRing(value: progress.readFraction(module), color: Theme.teal, lineWidth: 4)
                    .frame(width: 38, height: 38)
                ProgressRing(value: progress.mastery(module), color: Theme.good, lineWidth: 4)
                    .frame(width: 26, height: 26)
            }
        }
        .card()
    }
}

// MARK: - Moduldetail: erst lesen, dann üben

struct ModuleDetailView: View {
    let module: LearningModule
    @EnvironmentObject var progress: ProgressStore
    @State private var quiz: QuizConfig?
    @State private var showEarlyHint = false

    private var moduleQuestions: [Question] {
        let calcs = module.calcIDs.compactMap { CalcEngine.generator(id: $0)?.make() }
        return (module.questions + calcs).shuffled()
    }

    var body: some View {
        let readFraction = progress.readFraction(module)
        let fullyRead = progress.isFullyRead(module)
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        GlassIcon(systemName: module.icon, color: Theme.partColor(module.part), size: 54)
                        VStack(alignment: .leading) {
                            Text(module.part == 3 ? module.pages : "Skript Teil \(module.part), \(module.pages)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(module.title).font(.title3.bold())
                        }
                    }
                    RichText(module.goal).font(.callout)
                }
                .card()

                // Schritt 1: Lesen
                VStack(alignment: .leading, spacing: 8) {
                    stepTitle(1, "Skript durcharbeiten", done: fullyRead)
                    ProgressView(value: readFraction).tint(Theme.teal)
                    ForEach(Array(module.sections.enumerated()), id: \.element.id) { i, section in
                        NavigationLink {
                            LessonReaderView(module: module, startIndex: i)
                        } label: {
                            HStack {
                                Image(systemName: progress.isRead(section.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(progress.isRead(section.id) ? Theme.good : Color.secondary)
                                Text(section.title)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .card()

                // Schritt 2: Üben
                VStack(alignment: .leading, spacing: 8) {
                    stepTitle(2, "Gelerntes abfragen", done: progress.mastery(module) >= 0.8)
                    let total = module.questions.count + module.calcIDs.count
                    Text("\(total) Aufgaben · \(progress.answeredCount(module)) bearbeitet · \(Int((progress.mastery(module) * 100).rounded())) % beherrscht")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        if fullyRead {
                            quiz = QuizConfig(title: module.title, questions: moduleQuestions)
                        } else {
                            showEarlyHint = true
                        }
                    } label: {
                        Label("Übung starten", systemImage: fullyRead ? "play.fill" : "lock.fill").mainAction()
                    }
                    .liquidButton()
                    if !fullyRead {
                        Text("Erst lesen, dann üben: Die Übung ist für nach dem Skript gedacht.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .card()
            }
            .padding()
        }
        .liquidScreen()
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $quiz) { QuizSessionView(config: $0) }
        .alert("Noch nicht alles gelesen", isPresented: $showEarlyHint) {
            Button("Trotzdem üben") {
                quiz = QuizConfig(title: module.title, questions: moduleQuestions)
            }
            Button("Erst lesen", role: .cancel) {}
        } message: {
            Text("Du hast noch nicht alle Abschnitte dieses Moduls abgeschlossen.")
        }
    }

    private func stepTitle(_ number: Int, _ title: String, done: Bool) -> some View {
        HStack(spacing: 8) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(done ? Theme.good : Theme.primary, in: Circle())
            Text(title).font(.headline)
            Spacer()
            if done {
                Image(systemName: "checkmark").foregroundStyle(Theme.good)
            }
        }
    }
}

// MARK: - Lesemodus

struct LessonReaderView: View {
    let module: LearningModule
    @State var startIndex: Int
    @EnvironmentObject var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let section = module.sections[startIndex]
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ProgressView(value: Double(startIndex + 1), total: Double(module.sections.count))
                    .tint(Theme.teal)
                Text(section.title)
                    .font(.title2.bold())
                ForEach(Array(section.blocks.enumerated()), id: \.offset) { _, block in
                    if block.t == "p" || block.t == "b" {
                        BlockView(block: block).card()
                    } else {
                        BlockView(block: block)
                    }
                }
                Button {
                    finishSection(section)
                } label: {
                    Label(
                        startIndex + 1 < module.sections.count ? "Verstanden – weiter" : "Modul abschließen",
                        systemImage: "checkmark"
                    )
                    .mainAction()
                }
                .liquidButton()
                .padding(.top, 6)
            }
            .padding()
        }
        .id(section.id)
        .liquidScreen()
        .navigationTitle("\(startIndex + 1) von \(module.sections.count)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func finishSection(_ section: LessonSection) {
        progress.markRead(sectionID: section.id, moduleID: module.id)
        if startIndex + 1 < module.sections.count {
            withAnimation { startIndex += 1 }
        } else {
            dismiss()
        }
    }
}

// MARK: - Startseite

struct HomeView: View {
    @EnvironmentObject var library: ContentLibrary
    @EnvironmentObject var progress: ProgressStore
    @State private var quiz: QuizConfig?
    @State private var showResetAlert = false

    private var nextModule: LearningModule? {
        library.modules.first { !progress.isFullyRead($0) } ?? library.modules.first { progress.mastery($0) < 0.8 }
    }

    var body: some View {
        let due = progress.dueItemIDs()
        let overall = progress.overallMastery(library.modules)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 16) {
                        ZStack {
                            ProgressRing(value: overall, color: Theme.good, lineWidth: 10)
                                .frame(width: 84, height: 84)
                            Text("\(Int((overall * 100).rounded())) %").font(.headline.monospacedDigit())
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dein Lernstand").font(.headline)
                            Text("\(progress.data.readSections.count) Abschnitte gelesen, \(progress.data.items.count) Aufgaben bearbeitet.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .card()

                    HStack(spacing: 12) {
                        StatTile(value: "\(progress.streak)", label: "Tage in Folge", icon: "flame.fill", color: Theme.warn)
                        StatTile(value: "\(progress.answersToday)", label: "Heute", icon: "checkmark.circle.fill", color: Theme.good)
                        StatTile(value: "\(due.count)", label: "Fällig", icon: "clock.fill", color: Theme.violet)
                    }

                    if !due.isEmpty {
                        Button {
                            quiz = QuizConfig(title: "Wiederholung", questions: ReviewBuilder.questions(ids: due, library: library))
                        } label: {
                            Label("\(due.count) Wiederholungen starten", systemImage: "arrow.triangle.2.circlepath").mainAction()
                        }
                        .liquidButton()
                    }

                    if let module = nextModule {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Als Nächstes").font(.caption.bold()).foregroundStyle(.secondary)
                            NavigationLink {
                                ModuleDetailView(module: module)
                            } label: {
                                HStack(spacing: 12) {
                                    GlassIcon(systemName: module.icon, color: Theme.partColor(module.part))
                                    VStack(alignment: .leading) {
                                        Text(module.title).font(.headline).multilineTextAlignment(.leading)
                                        Text(module.pages).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .card()
                    }

                    activityChart
                }
                .padding()
            }
            .liquidScreen()
            .navigationTitle("Netztechnik")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Lernstand zurücksetzen", role: .destructive) { showResetAlert = true }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .fullScreenCover(item: $quiz) { QuizSessionView(config: $0) }
            .alert("Gesamten Lernstand löschen?", isPresented: $showResetAlert) {
                Button("Löschen", role: .destructive) { progress.resetAll() }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Gelesene Abschnitte, Antworten und Klausurergebnisse gehen verloren.")
            }
        }
    }

    private var activityChart: some View {
        let days = progress.lastDays(7)
        let top = max(days.map { $0.count }.max() ?? 1, 1)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Letzte 7 Tage").font(.caption.bold()).foregroundStyle(.secondary)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: 4) {
                        Text("\(day.count)").font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Theme.primary)
                            .frame(height: max(4, 70 * CGFloat(day.count) / CGFloat(top)))
                        Text(day.label).font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .card()
    }
}
