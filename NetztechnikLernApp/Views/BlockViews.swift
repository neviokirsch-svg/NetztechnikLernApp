import SwiftUI
import PDFKit

// MARK: - Originalfolien

final class SlideRepository {
    static let shared = SlideRepository()
    private var documents: [Int: PDFDocument] = [:]
    private let cache = NSCache<NSString, UIImage>()

    func document(part: Int) -> PDFDocument? {
        if let d = documents[part] { return d }
        guard let url = Bundle.main.url(forResource: "skript_teil\(part)", withExtension: "pdf"),
              let d = PDFDocument(url: url) else { return nil }
        documents[part] = d
        return d
    }

    func image(part: Int, page: Int) -> UIImage? {
        let key = "\(part)-\(page)" as NSString
        if let cached = cache.object(forKey: key) { return cached }
        guard let pdfPage = document(part: part)?.page(at: page - 1) else { return nil }
        let image = pdfPage.thumbnail(of: CGSize(width: 1080, height: 810), for: .mediaBox)
        cache.setObject(image, forKey: key)
        return image
    }
}

struct SlideThumbnail: View {
    let part: Int
    let page: Int
    var caption: String?
    @State private var image: UIImage?
    @State private var showViewer = false

    var body: some View {
        Button {
            showViewer = true
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .bottomTrailing) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.1))
                            .aspectRatio(4.0 / 3.0, contentMode: .fit)
                    }
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.caption.bold())
                        .padding(7)
                        .background(.ultraThinMaterial, in: Circle())
                        .padding(8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(caption ?? "Originalfolie")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Skript Teil \(part), Seite \(page)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
        .task { image = SlideRepository.shared.image(part: part, page: page) }
        .fullScreenCover(isPresented: $showViewer) {
            SlideViewer(part: part, page: page)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument
    let page: Int

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = document
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        if let target = document.page(at: page - 1) {
            view.go(to: target)
        }
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

/// Vollbild-Skript: Originalfolie mit Zoom und Blättern.
struct SlideViewer: View {
    let part: Int
    let page: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let document = SlideRepository.shared.document(part: part) {
                    PDFKitView(document: document, page: page)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    ContentUnavailableView("Skript nicht gefunden", systemImage: "doc.questionmark")
                }
            }
            .navigationTitle("Skript Teil \(part)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Block-Darstellung

struct BlockView: View {
    let block: Block

    var body: some View {
        switch block.t {
        case "p":
            RichText(block.x ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
        case "b":
            VStack(alignment: .leading, spacing: 7) {
                ForEach(Array((block.i ?? []).enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Circle().fill(Theme.primary).frame(width: 6, height: 6)
                        RichText(item).frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        case "k":
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill").foregroundStyle(Theme.warn)
                RichText(block.x ?? "").frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Theme.warn.opacity(0.15), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        case "f":
            VStack(spacing: 4) {
                Text(block.x ?? "")
                    .font(.system(.title3, design: .serif).bold())
                    .multilineTextAlignment(.center)
                if let title = block.title {
                    Text(title).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Theme.violet.opacity(0.13), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        case "tb":
            ScrollView(.horizontal, showsIndicators: false) {
                MiniTable(title: block.title, head: block.head ?? [], rows: block.rows ?? [])
            }
        case "sl":
            SlideThumbnail(part: block.part ?? 1, page: block.page ?? 1, caption: block.x)
                .card()
        case "seq":
            SeqDiagramView(block: block)
        case "net":
            NetDiagramView(block: block)
        case "frame":
            FrameDiagramView(block: block)
        case "bars":
            BarChartView(block: block)
        case "x":
            InteractiveViz(name: block.viz ?? "")
        default:
            EmptyView()
        }
    }
}
