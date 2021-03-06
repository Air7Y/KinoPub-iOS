import Foundation

class DelegatesStorage {
    var delegates: NSHashTable<AnyObject>

    init() {
        delegates = NSHashTable.weakObjects()
        return
    }

    func addDelegate(delegate: AnyObject) {
        delegates.add(delegate)
    }

    func removeDelegate(delegate: AnyObject) {
        delegates.remove(delegate)
    }

    func enumerateDelegatesWithBlock(delegateBlock: (_ delegate: AnyObject) -> Void) {
        for delegate in (delegates.copy() as AnyObject).objectEnumerator() {
            delegateBlock(delegate as AnyObject)
        }
    }
}
