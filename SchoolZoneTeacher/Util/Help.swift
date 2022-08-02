//
//  Help.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 13/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//
import UIKit
import Foundation

func setNavBarTitleShadow() -> NSShadow {
    let navBarTitleShadow = NSShadow()
    navBarTitleShadow.shadowBlurRadius = 2
    navBarTitleShadow.shadowOffset = CGSize(width: 0, height: 2)
    navBarTitleShadow.shadowColor = UIColor.gray
    
    return navBarTitleShadow
}

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
}

func colorWithHexString (hex:String) -> UIColor {
    
    var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString = (cString as NSString).substring(from: 1)
    }
    
    if (cString.count != 6) {
        return UIColor.gray
    }
    
    let rString = (cString as NSString).substring(to: 2)
    let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
    let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    Scanner(string: rString).scanHexInt32(&r)
    Scanner(string: gString).scanHexInt32(&g)
    Scanner(string: bString).scanHexInt32(&b)
    
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
}

func getFontSize()-> CGFloat{
    switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            switch UIScreen.main.nativeBounds.height {
                case 960: //iPhone4_4S
                    return CGFloat(9);
                case 1136: //iPhones_5_5s_5c_SE
                    return CGFloat(11);
                case 1334: //iPhones_6_6s_7_8
                    return CGFloat(12);
                case 1920, 2208, 2436: //iPhones_6Plus_6sPlus_7Plus_8Plus_iPhoneX
                    return CGFloat(13);
                default: //iPad
                    return CGFloat(13);
            }
        case .pad:
            return CGFloat(18);
        case .unspecified:
            return CGFloat(13);
        default:
            return CGFloat(13);
    }
}

func getTitleFontSize()-> CGFloat{
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
        switch UIScreen.main.nativeBounds.height {
        case 960: //iPhone4_4S
            return CGFloat(18);
        case 1136: //iPhones_5_5s_5c_SE
            return CGFloat(20);
        case 1334: //iPhones_6_6s_7_8
            return CGFloat(22);
        case 1920, 2208, 2436: //iPhones_6Plus_6sPlus_7Plus_8Plus_iPhoneX
            return CGFloat(24);
        default: //iPad
            return CGFloat(28);
        }
    case .pad:
        return CGFloat(28);
    case .unspecified:
        return CGFloat(28);
    default:
        return CGFloat(28);
    }
}

func getSchoolTitleFontSize()-> CGFloat{
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
        switch UIScreen.main.nativeBounds.height {
        case 960: //iPhone4_4S
            return CGFloat(12);
        case 1136: //iPhones_5_5s_5c_SE
            return CGFloat(14);
        case 1334: //iPhones_6_6s_7_8
            return CGFloat(14);
        case 1920, 2208, 2436: //iPhones_6Plus_6sPlus_7Plus_8Plus_iPhoneX
            return CGFloat(14);
        default: //iPad
            return CGFloat(20);
        }
    case .pad:
        return CGFloat(26);
    case .unspecified:
        return CGFloat(26);
    default:
        return CGFloat(26);
    }
}

final class Shared {
    static let shared = Shared() //lazy init, and it only runs once
    
    var id : Int!
}

final class SharedSelectedTabIndex {
    static let sharedSelectedTabIndex = SharedSelectedTabIndex() //lazy init, and it only runs once
    
    var index : Int!
}

final class URLShared {
    static let urlshared = URLShared() //lazy init, and it only runs once
    
    var url : String?
}

final class AppLoadingStatus {
    static let appLoadingStatus = AppLoadingStatus() //lazy init, and it only runs once
    
    var status : String?
}

final class AppLoginStatus {
    static let appLoginStatus = AppLoginStatus() //lazy init, and it only runs once
    
    var status : Int?
}

func validate(value: String) -> Bool {
    let PHONE_REGEX = "^[0-9]{6,14}$"
    let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
    let result =  phoneTest.evaluate(with: value)
    return result
}

final class MobileNumberShared {
    static let mobileNumberShared = MobileNumberShared() //lazy init, and it only runs once
    
    var MobileNumber : String?
}

final class TabsShared {
    static let tabsshared = TabsShared() //lazy init, and it only runs once
    
    var tag : Int!
}

final class SwitchShared {
    static let switchshared = SwitchShared() //lazy init, and it only runs once
    
    var isON : Bool!
}

final class dropDownClassShared {
    static let dropdownClassShared = dropDownClassShared() //lazy init, and it only runs once
    
    var isShown : Int!
}

final class dropDownTypeShared {
    static let dropdownTypeShared = dropDownTypeShared() //lazy init, and it only runs once
    
    var isShown : Int!
}

final class dropDownSubjectShared {
    static let dropdownSubjectShared = dropDownSubjectShared() //lazy init, and it only runs once
    
    var isShown : Int!
}

final class dropDownExamhared {
    static let dropdownExamShared = dropDownExamhared() //lazy init, and it only runs once
    
    var isShown : Int!
}

final class dropDownBookShared {
    static let dropdownBookShared = dropDownBookShared() //lazy init, and it only runs once
    
    var isShown : Int!
}

final class dropDownBookChapterShared {
    static let dropdownBookChapterShared = dropDownBookChapterShared() //lazy init, and it only runs once
    
    var isShown : Int!
}

final class dropDownBookChapterIndexShared {
    static let dropdownBookChapterIndexShared = dropDownBookChapterIndexShared() //lazy init, and it only runs once
    
    var isShown : Int!
}

final class vcShared {
    static let vcshared = vcShared() //lazy init, and it only runs once
    
    var vcName : String!
}

final class PickedImageCountShared {
    static let pickedImageCountShared = PickedImageCountShared() //lazy init, and it only runs once
    
    var count : Int!
}

final class PickedFileURLShared {
    static let pickedFileURLShared = PickedFileURLShared() //lazy init, and it only runs once
    
    var url : URL!
}

final class SlideImagesShared {
    static let slideImagesShared = SlideImagesShared() //lazy init, and it only runs once
    
    var adImages = NSArray()
}

func formateDateFromString(dateString: String, withFormat format: String) -> String? {
    
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "dd-MM-yyyy"
    
    if let date = inputFormatter.date(from: dateString) {
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = format
        
        return outputFormatter.string(from: date)
    }
    
    return nil
}

func getDeviceToken()-> String{
    
    let preferences = UserDefaults.standard
    let deviceTokenKey = "deviceToken"
    
    let deviceToken = preferences.string(forKey: deviceTokenKey)
    return deviceToken ?? "";
}

func setDeviceToken(deviceToken: String){
    
    let preferences = UserDefaults.standard
    
    let deviceTokenKey = "deviceToken"
    preferences.set(deviceToken, forKey: deviceTokenKey)
    
    preferences.synchronize()
}
func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func getNewsBadgeDetails()-> [NewsBadge]{
    
    let preferences = UserDefaults.standard
    let NewsBadgeDetailsKey = "NewsBadgeDetails"
    var NewsBadgeDetails: [NewsBadge]
    let NewsBadgeData = preferences.object(forKey: NewsBadgeDetailsKey) as? NSData
    NewsBadgeDetails = (NSKeyedUnarchiver.unarchiveObject(with: NewsBadgeData! as Data) as? [NewsBadge])!
    
    return NewsBadgeDetails
}

func setNewsBadgeDetails(NewsBadgeDetails: [NewsBadge]){
    
    let preferences = UserDefaults.standard
    
    let NewsBadgeDetailsKey = "NewsBadgeDetails"
    let NewsBadgeData = NSKeyedArchiver.archivedData(withRootObject: NewsBadgeDetails)
    preferences.set(NewsBadgeData, forKey: NewsBadgeDetailsKey)
    
    preferences.synchronize()
}

func getSchoolLogoImage()-> [SchoolLogo]{
    
    let preferences = UserDefaults.standard
    let SchoolLogoImageKey = "SchoolLogoImage"
    var SchoolLogoImage: [SchoolLogo]
    let SchoolLogoImageData = preferences.object(forKey: SchoolLogoImageKey) as? NSData
    SchoolLogoImage = (NSKeyedUnarchiver.unarchiveObject(with: SchoolLogoImageData! as Data) as? [SchoolLogo])!
    
    return SchoolLogoImage
}

func setSchoolLogoImage(SchoolLogoImage: [SchoolLogo]){
    
    let preferences = UserDefaults.standard
    
    let SchoolLogoImageKey = "SchoolLogoImage"
    let SchoolLogoImageData = NSKeyedArchiver.archivedData(withRootObject: SchoolLogoImage)
    preferences.set(SchoolLogoImageData, forKey: SchoolLogoImageKey)
    
    preferences.synchronize()
}

func getUUID()-> String{
    
    let preferences = UserDefaults.standard
    let UUIDKey = "UUID"
    
    let UUID = preferences.string(forKey: UUIDKey)
    return UUID ?? "";
}

func setUUID(UUID: String){
    
    let preferences = UserDefaults.standard
    
    let UUIDKey = "UUID"
    preferences.set(UUID, forKey: UUIDKey)
    
    preferences.synchronize()
}

func getRemarks()-> [Remark]{
    
    let preferences = UserDefaults.standard
    let RemarksKey = "Remarks"
    
    let Remarks = preferences.array(forKey: RemarksKey)
    return Remarks as! [Remark];
}

func setRemarks(Remarks: [Remark]){
    
    let preferences = UserDefaults.standard
    
    let RemarksKey = "Remarks"
    preferences.set(Remarks, forKey: RemarksKey)
    
    preferences.synchronize()
}

func getSchoolId()-> String{
    
    let preferences = UserDefaults.standard
    let schoolidKey = "schoolid"
    
    let schoolid = preferences.string(forKey: schoolidKey)
    return schoolid ?? "";
}

func setSchoolId(schoolId: String){
    
    let preferences = UserDefaults.standard
    
    let schoolidKey = "schoolid"
    preferences.set(schoolId, forKey: schoolidKey)
    
    preferences.synchronize()
}

func getTeacherIds()-> [String]{
    
    let preferences = UserDefaults.standard
    let teacheridKey = "teacherids"
    
    let teacherids = preferences.array(forKey: teacheridKey)
    return teacherids as! [String]
}

func setTeacherIds(teacherIds: [String]){
    
    let preferences = UserDefaults.standard
    
    let teacheridKey = "teacherids"
    preferences.set(teacherIds, forKey: teacheridKey)
    
    preferences.synchronize()
}

func getSchoolIds()-> [String]{
    
    let preferences = UserDefaults.standard
    let schoolidKey = "schoolids"
    
    let schoolids = preferences.array(forKey: schoolidKey)
    return schoolids as! [String];
}

func setSchoolIds(schoolIds: [String]){
    
    let preferences = UserDefaults.standard
    
    let schoolidKey = "schoolids"
    preferences.set(schoolIds, forKey: schoolidKey)
    
    preferences.synchronize()
}

func getSchoolNames()-> [String]{
    
    let preferences = UserDefaults.standard
    let schoolnameKey = "schoolnames"
    
    let schoolnames = preferences.array(forKey: schoolnameKey)
    return schoolnames as! [String];
}

func setSchoolNames(schoolNames: [String]){
    
    let preferences = UserDefaults.standard
    
    let schoolnameKey = "schoolnames"
    preferences.set(schoolNames, forKey: schoolnameKey)
    
    preferences.synchronize()
}

func getSchoolLogos()-> [String]{
    
    let preferences = UserDefaults.standard
    let schoollogoKey = "schoollogos"
    
    let schoollogos = preferences.array(forKey: schoollogoKey)
    return schoollogos as! [String];
}

func setSchoolLogos(schoolLogos: [String]){
    
    let preferences = UserDefaults.standard
    
    let schoollogoKey = "schoollogos"
    preferences.set(schoolLogos, forKey: schoollogoKey)
    
    preferences.synchronize()
}

func getTeacherId()-> String{
    
    let preferences = UserDefaults.standard
    let teacheridKey = "teacherid"
    
    let teacherid = preferences.string(forKey: teacheridKey)
    return teacherid ?? "";
}

func getNoticeCount()-> Int{
    
    let preferences = UserDefaults.standard
    let noticeCountKey = "noticeCount"
    
    let noticeCount = preferences.integer(forKey: noticeCountKey)
    return noticeCount
}

func setNoticeCount(noticeCount: Int){
    
    let preferences = UserDefaults.standard
    
    let noticeCountKey = "noticeCount"
    preferences.set(noticeCount, forKey: noticeCountKey)
    
    preferences.synchronize()
}

func getEventCount()-> Int{
    
    let preferences = UserDefaults.standard
    let eventCountKey = "eventCount"
    
    let eventCount = preferences.integer(forKey: eventCountKey)
    return eventCount
}

func setEventCount(eventCount: Int){
    
    let preferences = UserDefaults.standard
    
    let eventCountKey = "eventCount"
    preferences.set(eventCount, forKey: eventCountKey)
    
    preferences.synchronize()
}

func setLanguage(languageCode: String){
    
    let preferences = UserDefaults.standard
    
    let languageCodeKey = "languagecode"
    preferences.set(languageCode, forKey: languageCodeKey)
    
    preferences.synchronize()
}

func getLanguage()-> String{
    
    let preferences = UserDefaults.standard
    let languageCodeKey = "languagecode"
    
    let languageCode = preferences.string(forKey: languageCodeKey)
    return languageCode ?? "";
}

func setCountryCode(countryCode: String){
    
    let preferences = UserDefaults.standard
    
    let countryCodeKey = "countrycode"
    preferences.set(countryCode, forKey: countryCodeKey)
    
    preferences.synchronize()
}

func getCountryCode()-> String{
    
    let preferences = UserDefaults.standard
    let countryCodeKey = "countrycode"
    
    let countryCode = preferences.string(forKey: countryCodeKey)
    return countryCode ?? "";
}

func setTeacherId(teacherId: String){
    
    let preferences = UserDefaults.standard
    
    let teacheridKey = "teacherid"
    preferences.set(teacherId, forKey: teacheridKey)
    
    preferences.synchronize()
}

func getSchoolName()-> String{
    
    let preferences = UserDefaults.standard
    
    let schoolName = preferences.string(forKey: "SchoolName")
    return schoolName ?? "";
}

func setSchoolName(schoolName: String){
    
    let preferences = UserDefaults.standard
    preferences.set(schoolName, forKey: "SchoolName")
    
    preferences.synchronize()
}

func getFirstName()-> String{
    
    let preferences = UserDefaults.standard
    
    let firstName = preferences.string(forKey: "FirstName")
    return firstName ?? "";
}

func setFirstName(firstName: String){
    
    let preferences = UserDefaults.standard
    preferences.set(firstName, forKey: "FirstName")
    
    preferences.synchronize()
}

func getMiddleName()-> String{
    
    let preferences = UserDefaults.standard
    
    let middleName = preferences.string(forKey: "MiddleName")
    return middleName ?? "";
}

func setMiddleName(middleName: String){
    
    let preferences = UserDefaults.standard
    preferences.set(middleName, forKey: "MiddleName")
    
    preferences.synchronize()
}

func getLastName()-> String{
    
    let preferences = UserDefaults.standard
    
    let lastName = preferences.string(forKey: "LastName")
    return lastName ?? "";
}

func setLastName(lastName: String){
    
    let preferences = UserDefaults.standard
    preferences.set(lastName, forKey: "LastName")
    
    preferences.synchronize()
}

func getMobile()-> String{
    
    let preferences = UserDefaults.standard
    
    let mobile = preferences.string(forKey: "Mobile")
    return mobile ?? "";
}

func setMobile(mobile: String){
    
    let preferences = UserDefaults.standard
    preferences.set(mobile, forKey: "Mobile")
    
    preferences.synchronize()
}

func getEmail()-> String{
    
    let preferences = UserDefaults.standard
    
    let email = preferences.string(forKey: "Email")
    return email ?? "";
}

func setEmail(email: String){
    
    let preferences = UserDefaults.standard
    preferences.set(email, forKey: "Email")
    
    preferences.synchronize()
}

func getDOB()-> String{
    
    let preferences = UserDefaults.standard
    
    let dob = preferences.string(forKey: "DOB")
    return dob ?? "";
}

func setDOB(dob: String){
    
    let preferences = UserDefaults.standard
    preferences.set(dob, forKey: "DOB")
    
    preferences.synchronize()
}

func getGender()-> String{
    
    let preferences = UserDefaults.standard
    
    let gender = preferences.string(forKey: "Gender")
    return gender ?? "";
}

func setGender(gender: String){
    
    let preferences = UserDefaults.standard
    preferences.set(gender, forKey: "Gender")
    
    preferences.synchronize()
}

func getLang()-> String{
    
    let preferences = UserDefaults.standard
    
    let lang = preferences.string(forKey: "Lang")
    return lang ?? "";
}

func setLang(lang: String){
    
    let preferences = UserDefaults.standard
    preferences.set(lang, forKey: "Lang")
    
    preferences.synchronize()
}

func getProfileImage()-> String{
    
    let preferences = UserDefaults.standard
    
    let profileImage = preferences.string(forKey: "ProfileImage")
    return profileImage ?? "";
}

func setProfileImage(profileImage: String){
    
    let preferences = UserDefaults.standard
    preferences.set(profileImage, forKey: "ProfileImage")
    
    preferences.synchronize()
}

func getSchoolLogo()-> String{
    
    let preferences = UserDefaults.standard
    
    let logoImage = preferences.string(forKey: "SchoolLogo")
    return logoImage ?? "";
}

func setSchoolLogo(logoImage: String){
    
    let preferences = UserDefaults.standard
    preferences.set(logoImage, forKey: "SchoolLogo")
    
    preferences.synchronize()
}

func getSchoolAddress()-> String{
    
    let preferences = UserDefaults.standard
    
    let schoolAddress = preferences.string(forKey: "SchoolAddress")
    return schoolAddress ?? "";
}

func setSchoolAddress(address: String){
    
    let preferences = UserDefaults.standard
    preferences.set(address, forKey: "SchoolAddress")
    
    preferences.synchronize()
}

func getAcademicYear()-> String{
    
    let preferences = UserDefaults.standard
    
    let academicYear = preferences.string(forKey: "AcademicYear")
    return academicYear ?? "";
}

func setAcademicYear(academicYear: String){
    
    let preferences = UserDefaults.standard
    preferences.set(academicYear, forKey: "AcademicYear")
    
    preferences.synchronize()
}

func getTabbarHeight() -> CGFloat{
    
    var tabBarHeight:CGFloat = 55.00
    let modelName = UIDevice.modelName
    //print("modelName: \(modelName)")
    
    switch modelName {
        case "iPhone X", "iPhone XR", "iPhone XS", "iPhone XS Max", "Simulator iPhone X", "Simulator iPhone XR", "Simulator iPhone XS", "Simulator iPhone XS Max":
            tabBarHeight = 83.00
            break
        case "iPhone12,1", "iPhone12,3", "iPhone12,5", "Simulator iPhone12,1", "Simulator iPhone12,3", "Simulator iPhone12,5":
            tabBarHeight = 83.00
            break
        default:
            tabBarHeight = 55.00
            break
    }
    
    return tabBarHeight
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}
