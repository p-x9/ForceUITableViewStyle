import Orion
import ForceUITableViewStyleC
import UIKit

struct Settings: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case isTweakEnabled
        
        case from1
        case to1
        
        case from2
        case to2
        
        case from3
        case to3
    }
    
    var isTweakEnabled = true
    
    var from1: Int = 0
    var to1: Int = 0
    
    var from2: Int = 1
    var to2: Int = 1
    
    var from3: Int = 2
    var to3: Int = 2
    
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        isTweakEnabled = try container.decodeIfPresent(Bool.self, forKey: .isTweakEnabled) ?? true
        
        from1 = try container.decodeIfPresent(Int.self, forKey: .from1) ?? 0
        to1 = try container.decodeIfPresent(Int.self, forKey: .to1) ?? 0
        
        from2 = try container.decodeIfPresent(Int.self, forKey: .from2) ?? 1
        to2 = try container.decodeIfPresent(Int.self, forKey: .to2) ?? 1
        
        from3 = try container.decodeIfPresent(Int.self, forKey: .from3) ?? 2
        to3 = try container.decodeIfPresent(Int.self, forKey: .to3) ?? 2
    }
}

extension Settings {
    var replaceDictionary: [Int: Int] {
        [
            from1: to1,
            from2: to2,
            from3: to3
        ]
    }
}

var localSettings = Settings()

struct tweak: HookGroup {}

class NSCoder_Hook: ClassHook<UINibDecoder> {
    typealias Group = tweak
    
    @Property(.assign) var isUITableViewTarget = false
    
    func decodeIntegerForKey(_ key: String) -> Int {
        let value = orig.decodeIntegerForKey(key)
        if key == "UITableViewStyle" || (isUITableViewTarget && key == "UIStyle"),
           let toValue = localSettings.replaceDictionary[value] {
            return toValue
        }
        return value
    }
    
    // orion:new
    func useUITableView() {
        isUITableViewTarget = true
    }
}


class UITableView_Hook: ClassHook<UITableView> {
    typealias Group = tweak
    
    func initWithFrame(_ frame: CGRect, style: UITableView.Style) -> UITableView {
        var newStyle = style
        
        if let toValue = localSettings.replaceDictionary[style.rawValue] {
            newStyle = UITableView.Style(rawValue: toValue) ?? style
        }
        
        let target = orig.initWithFrame(frame, style: newStyle)
        
        return target
    }
    
    func initWithCoder(_ coder: NSCoder) -> UITableView? {
        coder.perform(#selector(NSCoder_Hook.useUITableView))
        
        let target = orig.initWithCoder(coder)
        return target
    }
}



func readPrefs() {
    let path = "/var/mobile/Library/Preferences/com.p-x9.forceuitableviewstyle.pref.plist"
    let url = URL(fileURLWithPath: path)
    
    //Reading values
    guard let data = try? Data(contentsOf: url) else {
        return
    }
    let decoder = PropertyListDecoder()
    localSettings =  (try? decoder.decode(Settings.self, from: data)) ?? Settings()
}

func settingChanged() {
    readPrefs()
}

func observePrefsChange() {
    let NOTIFY = "com.p-x9.forceuitableviewstyle.prefschanged" as CFString
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    nil, { _, _, _, _, _ in
        settingChanged()
    }, NOTIFY, nil, CFNotificationSuspensionBehavior.deliverImmediately)
}


struct ForceInsetGrouped: Tweak {
    init() {
        readPrefs()
        observePrefsChange()
        
        if localSettings.isTweakEnabled {
            tweak().activate()
        }
        
    }
}
