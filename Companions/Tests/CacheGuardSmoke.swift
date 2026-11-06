import Foundation

// Non-destructive smoke test: checks only path containment, never removes a file.
@main
struct CacheGuardSmoke {
    static func main() {
        let root = URL(fileURLWithPath: "/tmp/dl7-test-sandbox-cache", isDirectory: true)
        let accepted = root.appendingPathComponent("nested/cache.tmp")
        let sibling = URL(fileURLWithPath: "/tmp/dl7-test-sandbox-cache-copy/cache.tmp")
        let parentTraversal = root.appendingPathComponent("../important.txt")

        precondition(CacheEngine.isSafelyInside(accepted, root: root))
        precondition(!CacheEngine.isSafelyInside(root, root: root))
        precondition(!CacheEngine.isSafelyInside(sibling, root: root))
        precondition(!CacheEngine.isSafelyInside(parentTraversal, root: root))
        print("PASS: four non-destructive cache path guard checks")
    }
}
