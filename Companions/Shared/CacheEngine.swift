import Foundation
import Observation

enum CleanupArea: String, Sendable {
    case cache
    case temporary

    var title: String {
        switch self {
        case .cache: "Cache"
        case .temporary: "File sementara"
        }
    }
}

struct CacheEntry: Identifiable, Sendable {
    let url: URL
    let bytes: Int64
    let area: CleanupArea

    var id: String { area.rawValue + ":" + url.path }
    var filename: String { url.lastPathComponent }
}

struct CacheSnapshot: Sendable {
    var entries: [CacheEntry] = []
    var error: String?

    var bytes: Int64 { entries.reduce(0) { $0 + $1.bytes } }
    var cacheCount: Int { entries.filter { $0.area == .cache }.count }
    var temporaryCount: Int { entries.filter { $0.area == .temporary }.count }
}

enum CacheEngine {
    static var cacheRoot: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .standardizedFileURL.resolvingSymlinksInPath()
    }

    static var temporaryRoot: URL {
        FileManager.default.temporaryDirectory.standardizedFileURL.resolvingSymlinksInPath()
    }

    static func isSafelyInside(_ child: URL, root: URL) -> Bool {
        let canonicalRoot = root.standardizedFileURL.resolvingSymlinksInPath()
        let canonicalChild = child.standardizedFileURL.resolvingSymlinksInPath()
        return canonicalChild.path.hasPrefix(canonicalRoot.path + "/")
    }

    private static func root(for area: CleanupArea) -> URL? {
        switch area {
        case .cache: cacheRoot
        case .temporary: temporaryRoot
        }
    }

    private static func isEligible(_ candidate: URL, in root: URL, area: CleanupArea) -> Bool {
        guard isSafelyInside(candidate, root: root),
              let values = try? candidate.resourceValues(forKeys: [
                  .isRegularFileKey, .isSymbolicLinkKey, .contentModificationDateKey
              ]),
              values.isRegularFile == true,
              values.isSymbolicLink != true
        else { return false }

        // Do not remove temporary files that the running app may still use.
        if area == .temporary {
            guard let modified = values.contentModificationDate,
                  modified < Date().addingTimeInterval(-3600)
            else { return false }
        }
        return true
    }

    static func scan() -> CacheSnapshot {
        let manager = FileManager.default
        var snapshot = CacheSnapshot()

        for area in [CleanupArea.cache, .temporary] {
            guard let root = root(for: area) else {
                if area == .cache { snapshot.error = "Folder cache DL7 tidak tersedia." }
                continue
            }
            // A fresh install often has no Caches folder yet; that is clean.
            guard manager.fileExists(atPath: root.path) else { continue }
            let keys: [URLResourceKey] = [
                .isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey, .contentModificationDateKey
            ]
            guard let enumerator = manager.enumerator(
                at: root, includingPropertiesForKeys: keys, options: [], errorHandler: nil
            ) else { continue }

            for case let candidate as URL in enumerator {
                guard isEligible(candidate, in: root, area: area),
                      let values = try? candidate.resourceValues(forKeys: [.fileSizeKey])
                else { continue }
                snapshot.entries.append(CacheEntry(
                    url: candidate, bytes: Int64(values.fileSize ?? 0), area: area
                ))
            }
        }
        snapshot.entries.sort { $0.bytes > $1.bytes }
        return snapshot
    }

    // Invoked only after confirmation; never cleans outside DL7's sandbox.
    static func clean(_ entries: [CacheEntry]) -> (removed: Int, bytes: Int64, errors: Int) {
        var removed = 0
        var bytes: Int64 = 0
        var errors = 0

        for entry in entries {
            guard let root = root(for: entry.area),
                  isEligible(entry.url, in: root, area: entry.area)
            else { errors += 1; continue }
            do {
                try FileManager.default.removeItem(at: entry.url)
                removed += 1
                bytes += entry.bytes
            } catch { errors += 1 }
        }
        return (removed, bytes, errors)
    }
}

@MainActor @Observable
final class CacheModel {
    var snapshot = CacheSnapshot()
    var busy = false
    var notice: String?

    func scan() async {
        guard !busy else { return }
        busy = true
        snapshot = await Task.detached(priority: .utility) { CacheEngine.scan() }.value
        busy = false
    }

    func cleanConfirmed() async {
        guard !busy else { return }
        busy = true
        let selected = snapshot.entries
        let result = await Task.detached(priority: .utility) { CacheEngine.clean(selected) }.value
        snapshot = await Task.detached(priority: .utility) { CacheEngine.scan() }.value
        let amount = ByteCountFormatter.string(fromByteCount: result.bytes, countStyle: .file)
        notice = "\(result.removed) file (\(amount)) dibersihkan dari DL7. \(result.errors) file dilewati."
        busy = false
    }
}
