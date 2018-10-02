// 1. Declare outside class definition (or in its own file).
// 2. UIKit must be included in file where this code is added.
// 3. Extends UIDevice class, thus is available anywhere in app.
//
// Usage example:
//
//    if UIDevice().type == .simulator {
//       print("You're running on the simulator... boring!")
//    } else {
//       print("Wow! Running on a \(UIDevice().type.rawValue)")
//    }
import UIKit

public enum Model : String {
    case simulator     = "simulator/sandbox",
    iPod1              = "iPod 1",
    iPod2              = "iPod 2",
    iPod3              = "iPod 3",
    iPod4              = "iPod 4",
    iPod5              = "iPod 5",
    iPod6              = "iPod 6",
    
    iPad2              = "iPad 2",
    iPad3              = "iPad 3",
    iPad4              = "iPad 4",
    iPadMini1          = "iPad Mini 1",
    iPadMini2          = "iPad Mini 2",
    iPadMini3          = "iPad Mini 3",
    iPadMini4          = "iPad Mini 4",
    iPadAir1           = "iPad Air 1",
    iPadAir2           = "iPad Air 2",
    iPadPro9_7         = "iPad Pro 9.7\"",
    iPadPro9_7_cell    = "iPad Pro 9.7\" cellular",
    iPadPro10_5        = "iPad Pro 10.5\"",
    iPadPro10_5_cell   = "iPad Pro 10.5\" cellular",
    iPadPro12_9        = "iPad Pro 12.9\"",
    iPadPro12_9_cell   = "iPad Pro 12.9\" cellular",
    iPad5              = "iPad 5",
    iPad5_cell         = "iPad 5 cellular",
    iPadPro12_9_2      = "iPad Pro 12.9\" 2",
    iPadPro12_9_cell_2 = "iPad Pro 12.9\" 2 cellular",
    iPad6              = "iPad 6",
    iPad6_cell         = "iPad 6 cellular",
    
    iPhone4            = "iPhone 4",
    iPhone4S           = "iPhone 4S",
    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6Splus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXR           = "iPhone XR",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    
    appleTV4           = "Apple TV 4",
    appleTV4k          = "Apple TV 4K",
    
    unrecognized       = "?unrecognized?"
}

public extension UIDevice {
    public var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
                
            }
        }
        var modelMap : [ String : Model ] = [
            "i386"       : .simulator,
            "x86_64"     : .simulator,
            
            "iPod1,1"    : .iPod1,
            "iPod2,1"    : .iPod2,
            "iPod3,1"    : .iPod3,
            "iPod4,1"    : .iPod4,
            "iPod5,1"    : .iPod5,
            "iPod7,1"    : .iPod6,
            
            "iPad2,1"    : .iPad2,
            "iPad2,2"    : .iPad2,
            "iPad2,3"    : .iPad2,
            "iPad2,4"    : .iPad2,
            "iPad2,5"    : .iPadMini1,
            "iPad2,6"    : .iPadMini1,
            "iPad2,7"    : .iPadMini1,
            "iPad3,1"    : .iPad3,
            "iPad3,2"    : .iPad3,
            "iPad3,3"    : .iPad3,
            "iPad3,4"    : .iPad4,
            "iPad3,5"    : .iPad4,
            "iPad3,6"    : .iPad4,
            "iPad4,1"    : .iPadAir1,
            "iPad4,2"    : .iPadAir1,
            "iPad4,3"    : .iPadAir1,
            "iPad4,4"    : .iPadMini2,
            "iPad4,5"    : .iPadMini2,
            "iPad4,6"    : .iPadMini2,
            "iPad4,7"    : .iPadMini3,
            "iPad4,8"    : .iPadMini3,
            "iPad4,9"    : .iPadMini3,
            "iPad5,1"    : .iPadMini4,
            "iPad5,2"    : .iPadMini4,
            "iPad5,3"    : .iPadAir2,
            "iPad5,4"    : .iPadAir2,
            "iPad6,3"    : .iPadPro9_7,
            "iPad6,4"    : .iPadPro9_7_cell,
            "iPad6,7"    : .iPadPro12_9,
            "iPad6,8"    : .iPadPro12_9_cell,
            "iPad6,11"   : .iPad5,
            "iPad6,12"   : .iPad5_cell,
            "iPad7,1"    : .iPadPro12_9_2,
            "iPad7,2"    : .iPadPro12_9_cell_2,
            "iPad7,3"    : .iPadPro10_5,
            "iPad7,4"    : .iPadPro10_5_cell,
            "iPad7,5"    : .iPad6,
            "iPad7,6"    : .iPad6_cell,
            
            "iPhone3,1"  : .iPhone4,
            "iPhone3,2"  : .iPhone4,
            "iPhone3,3"  : .iPhone4,
            "iPhone4,1"  : .iPhone4S,
            "iPhone5,1"  : .iPhone5,
            "iPhone5,2"  : .iPhone5,
            "iPhone5,3"  : .iPhone5C,
            "iPhone5,4"  : .iPhone5C,
            "iPhone6,1"  : .iPhone5S,
            "iPhone6,2"  : .iPhone5S,
            "iPhone7,1"  : .iPhone6plus,
            "iPhone7,2"  : .iPhone6,
            "iPhone8,1"  : .iPhone6S,
            "iPhone8,2"  : .iPhone6Splus,
            "iPhone8,4"  : .iPhoneSE,
            "iPhone9,1"  : .iPhone7,
            "iPhone9,2"  : .iPhone7plus,
            "iPhone9,3"  : .iPhone7,
            "iPhone9,4"  : .iPhone7plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8plus,
            "iPhone10,5" : .iPhone8plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            
            "AppleTV5,3" : .appleTV4,
            "AppleTV6,2" : .appleTV4k,
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            return model
        }
        return Model.unrecognized
    }
}
