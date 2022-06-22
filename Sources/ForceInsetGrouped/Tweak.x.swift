import Orion
import ForceInsetGroupedC
import UIKit

struct tweak: HookGroup {}

class NSCoder_Hook: ClassHook<UINibDecoder> {
    typealias Group = tweak
    
    func decodeIntegerForKey(_ key: String) -> Int {
        if key == "UITableViewStyle" || key == "UIStyle" {
            return UITableView.Style.insetGrouped.rawValue
        }
        return orig.decodeIntegerForKey(key)
    }
}


class UITableView_Hook: ClassHook<UITableView> {
    typealias Group = tweak
    
    func initWithFrame(_ frame: CGRect, style: UITableView.Style) -> UITableView {
        let target = orig.initWithFrame(frame, style: .insetGrouped)
        
        return target
    }
    
    func initWithCoder(_ coder: NSCoder) -> UITableView? {
        let target = orig.initWithCoder(coder)
        return target
    }
    
}

struct ForceInsetGrouped: Tweak {
    init() {
        tweak().activate()
    }
}
