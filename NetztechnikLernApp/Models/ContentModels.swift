import Combine
import Foundation

// MARK: - Module & Lektion

struct LearningModule: Codable, Identifiable, Hashable {
    let id: String
    let part: Int
    let order: Int
    let title: String
    let pages: String
    let icon: String
    let goal: String
    let sections: [LessonSection]
    let questions: [Question]
    let calcs: [String]?

    var calcIDs: [String] { calcs ?? [] }
    static func == (lhs: LearningModule, rhs: LearningModule) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct LessonSection: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let blocks: [Block]
    static func == (lhs: LessonSection, rhs: LessonSection) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Inhaltsblöcke

/// Ein Block eines Skript-Abschnitts. `t` bestimmt, welche Felder gesetzt sind:
/// p (Text), b (Stichpunkte), k (Merke), f (Formel), tb (Tabelle), sl (Originalfolie),
/// seq (Sequenzdiagramm), net (Netzdiagramm), frame (Paketformat), bars (Balken), x (interaktiv).
struct Block: Codable {
    let t: String
    var x: String?
    var i: [String]?
    var head: [String]?
    var rows: [[String]]?
    var part: Int?
    var page: Int?
    var title: String?
    var lifelines: [String]?
    var msgs: [SeqMessage]?
    var nodes: [NetNode]?
    var edges: [NetEdge]?
    var steps: [NetStep]?
    var frames: [FrameRow]?
    var reveal: Bool?
    var bars: [BarItem]?
    var unit: String?
    var viz: String?
}

struct SeqMessage: Codable {
    let f: Int
    let to: Int
    let l: String
    var n: String?
    var c: String?
}

struct NetNode: Codable {
    let id: String
    let l: String
    let x: Double
    let y: Double
    var s: String?
}

struct NetEdge: Codable {
    let a: String
    let b: String
    var l: String?
}

struct NetPacket: Codable {
    let a: String
    let b: String
    var l: String?
    var c: String?
}

struct NetTable: Codable {
    var title: String?
    let head: [String]
    let rows: [[String]]
}

struct NetStep: Codable {
    let x: String
    var hn: [String]?
    var he: [[String]]?
    var dn: [String]?
    var de: [[String]]?
    var p: [NetPacket]?
    var tb: NetTable?
}

struct FrameRow: Codable {
    var l: String?
    let segs: [FrameSeg]
}

struct FrameSeg: Codable {
    let t: String
    let w: Double
    var c: String?
    var d: String?
}

struct BarItem: Codable {
    let l: String
    let v: Double
    var v2: Double?
    var c: String?
}

// MARK: - Fragen

enum QuestionKind: String, Codable {
    case mc, ms, tf, num, ord, match, open
}

struct TFStatement: Codable, Hashable {
    let s: String
    let v: Bool
}

struct Question: Codable, Identifiable, Hashable {
    let id: String
    let k: QuestionKind
    let lvl: Int
    let pts: Int
    let q: String
    var o: [String]?
    var a: [Int]?
    var st: [TFStatement]?
    var num: Double?
    var tol: Double?
    var unit: String?
    var steps: [String]?
    var seq: [String]?
    var pairs: [[String]]?
    var model: [String]?
    var e: String?
    var ref: String?
    var src: String?
    var fig: Block?

    static func == (lhs: Question, rhs: Question) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    /// Skript-Folie aus der Referenz, z.B. "T1 S.48" -> (1, 48)
    var slideReference: (part: Int, page: Int)? {
        guard let ref = ref else { return nil }
        let parts = ref.replacingOccurrences(of: "–", with: "-").split(separator: " ")
        guard parts.count >= 2, parts[0].hasPrefix("T"), let p = Int(parts[0].dropFirst()) else { return nil }
        let rest = parts[1].replacingOccurrences(of: "S.", with: "")
        guard let first = rest.split(separator: "-").first, let page = Int(first) else { return nil }
        return (p, page)
    }
}

// MARK: - Inhalts-Bibliothek

final class ContentLibrary: ObservableObject {
    @Published private(set) var modules: [LearningModule] = []
    @Published private(set) var loadErrors: [String] = []
    private var questionIndex: [String: (Question, LearningModule)] = [:]

    init() { load() }

    private func load() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        var loaded: [LearningModule] = []
        var errors: [String] = []
        let decoder = JSONDecoder()
        for url in urls where url.lastPathComponent.hasPrefix("module_") {
            do {
                let data = try Data(contentsOf: url)
                loaded.append(try decoder.decode(LearningModule.self, from: data))
            } catch {
                errors.append("\(url.lastPathComponent): \(error)")
            }
        }
        loaded.sort { $0.order < $1.order }
        modules = loaded
        loadErrors = errors
        for m in loaded {
            for q in m.questions { questionIndex[q.id] = (q, m) }
        }
    }

    func question(id: String) -> (Question, LearningModule)? { questionIndex[id] }

    var allQuestions: [Question] { modules.flatMap { $0.questions } }

    func module(id: String) -> LearningModule? { modules.first { $0.id == id } }

    func module(forCalc calcID: String) -> LearningModule? {
        modules.first { $0.calcIDs.contains(calcID) }
    }
}
