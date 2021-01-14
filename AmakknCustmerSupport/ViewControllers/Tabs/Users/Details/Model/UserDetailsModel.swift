//
//  UserDetailsModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/10/20.
//

import Foundation

struct UserDetailsDataSource {
    let profileDetails: UserProfileDetails?
    let accountDetails: UserAccountDetails?
    let profilePropertyDetails: UserProfilePropertiesDetails?
    let appUsagesDetails: UserAppUsagesDetails?
    let companyDetails: UserCompanyDetails?

    init(_ userDetails: UserStatsModel?) {
        profileDetails = UserProfileDetails(userDetails)
        accountDetails = UserAccountDetails(userDetails)
        profilePropertyDetails = UserProfilePropertiesDetails(userDetails)
        appUsagesDetails = UserAppUsagesDetails(userDetails)
        companyDetails = UserCompanyDetails(userDetails)
    }
}

struct UserProfileDetails {
    let userID: String?
    let userName: String?
    let userEmail: String?
    let userAvatar: String?
    let userPhone: String?
    let countryCode: String?

    init(_ userDetails: UserStatsModel?) {
        userID =  userDetails?.userID
        userName = userDetails?.userName
        userEmail = userDetails?.userEmail
        userAvatar = userDetails?.userAvatar
        userPhone = userDetails?.userPhone
        countryCode = userDetails?.countryCode
    }
}

struct UserAccountDetails {
    var userAccountData = [UserDataTypeModel]()

    init(_ userDetails: UserStatsModel?) {
        userAccountData.append(UserDataTypeModel(key: "Language".localized(), value: update(language: userDetails?.language) ?? "--"))
        userAccountData.append(UserDataTypeModel(key: "User_Type".localized(), value: update(userType: userDetails?.userType) ?? "--"))
        userAccountData.append(UserDataTypeModel(key: "Account_Type".localized(), value: update(accountType: userDetails?.accountType) ?? "--"))
        userAccountData.append(UserDataTypeModel(key: "Status".localized(), value: userDetails?.status ?? "--"))
        userAccountData.append(UserDataTypeModel(key: "Verified".localized(), value: userDetails?.isUserVerified ?? "--"))
        userAccountData.append(UserDataTypeModel(key: "Created_At".localized(), value: convert(userDetails?.createdAt) ?? "--"))
        userAccountData.append(UserDataTypeModel(key: "Updated_At".localized(), value: convert(userDetails?.updatedAt) ?? "--"))
    }

    private func convert(_ dateStr: String?) -> String? {
        guard let dateStr = dateStr else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let date = dateFormatter.date(from: dateStr) else { return nil }
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm aaa"

        return dateFormatter.string(from: date)
    }

    private func update(userType: String?) -> String? {
        guard let userTypeStr = userType, let userType = UserType(rawValue: userTypeStr) else { return "--" }

        switch userType {
            case .normal:
                return UserTypeStr.normal.rawValue
            case .owner:
                return UserTypeStr.owner.rawValue
            case .broker:
                return UserTypeStr.broker.rawValue
            case .company:
                return UserTypeStr.company.rawValue
            case .agent:
                return UserTypeStr.agent.rawValue
            case .admin:
                return UserTypeStr.admin.rawValue
        }
    }

    private func update(accountType: String?) -> String? {
        guard let accountTypeStr = accountType, let accountType = AccountType(rawValue: accountTypeStr) else { return "--" }

        switch accountType {
            case .individual:
                return AccountTypeStr.individual.rawValue
            case .corporate:
                return AccountTypeStr.corporate.rawValue
        }
    }

    private func update(language: String?) -> String? {
        guard let langStr = language, let langType = LanguageType(rawValue: langStr) else { return "--" }

        switch langType {
            case .arabic:
                return LanguageTypeStr.arabic.rawValue
            case .english:
                return LanguageTypeStr.english.rawValue
        }
    }
}

struct UserProfilePropertiesDetails {
    var userPropertiesData = [UserDataTypeModel]()

    init(_ userDetails: UserStatsModel?) {

        userPropertiesData.append(UserDataTypeModel(key: "PublishedProperty_Count".localized(), value: String(userDetails?.publishedPropertyCount ?? 0), propertyIDs: userDetails?.publishedPropertyIds ?? "0"))
        userPropertiesData.append(UserDataTypeModel(key: "IncompOrUnpubProperty_Count".localized(), value: String(userDetails?.incompOrUnpubPropertyCount ?? 0), propertyIDs: userDetails?.incompOrUnpubPropertyIds ?? "0"))
        userPropertiesData.append(UserDataTypeModel(key: "SoldOutProperty_Count".localized(), value: String(userDetails?.soldOutPropertyCount ?? 0), propertyIDs: userDetails?.soldOutPropertyIds ?? "0"))
        userPropertiesData.append(UserDataTypeModel(key: "LastAdded_Property".localized(), value: convert(userDetails?.lastAddedProperty) ?? "--"))
    }

    private func convert(_ dateStr: String?) -> String? {
        guard let dateStr = dateStr else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let date = dateFormatter.date(from: dateStr) else { return nil }
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm aaa"

        return dateFormatter.string(from: date)
    }
}

struct UserAppUsagesDetails {
    var userAppUsagesData = [UserDataTypeModel]()

    init(_ userDetails: UserStatsModel?) {
        userAppUsagesData.append(UserDataTypeModel(key: "Decices".localized(), value: userDetails?.devices ?? "--"))
        userAppUsagesData.append(UserDataTypeModel(key: "App_Versions".localized(), value: userDetails?.appVersions ?? "--"))
        userAppUsagesData.append(UserDataTypeModel(key: "OS_Versions".localized(), value: userDetails?.osVersions ?? "--"))
        userAppUsagesData.append(UserDataTypeModel(key: "Platforms".localized(), value: userDetails?.platforms ?? "--"))
        userAppUsagesData.append(UserDataTypeModel(key: "Last_Opened".localized(), value: convert(userDetails?.lastOpened) ?? "--"))
    }

    private func convert(_ dateStr: String?) -> String? {
        guard let dateStr = dateStr else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let date = dateFormatter.date(from: dateStr) else { return nil }
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm aaa"

        return dateFormatter.string(from: date)
    }
}

struct UserCompanyDetails {
    var userCompanysData = [UserDataTypeModel]()

    init(_ userDetails: UserStatsModel?) {
        userCompanysData.append(UserDataTypeModel(key: "Company_Name".localized(), value: userDetails?.companyName ?? "--"))
        userCompanysData.append(UserDataTypeModel(key: "Company_Type".localized(), value: userDetails?.companyType ?? "--"))
        userCompanysData.append(UserDataTypeModel(key: "Company_ID".localized(), value: String(userDetails?.companyID ?? 0)))
        userCompanysData.append(UserDataTypeModel(key: "CR_No".localized(), value: userDetails?.commercialRecordNumber ?? "--"))
        userCompanysData.append(UserDataTypeModel(key: "CompWebsite_URL".localized(), value: userDetails?.companyWebsiteURL ?? "--"))
        userCompanysData.append(UserDataTypeModel(key: "Comp_Desc".localized(), value: userDetails?.companyDesc ?? "--"))
        userCompanysData.append(UserDataTypeModel(key: "Comp_Address".localized(), value: userDetails?.companyAddress ?? "--"))
        userCompanysData.append(UserDataTypeModel(key: "Comp_Latitude".localized(), value: userDetails?.companyLatitude ?? "--"))
        userCompanysData.append(UserDataTypeModel(key: "Comp_Longitude".localized(), value: userDetails?.companyLongitude ?? "--"))
        userCompanysData.append(UserDataTypeModel(key: "IsComp_Verified".localized(), value: String(userDetails?.isCompanyVerified ?? 0)))
        userCompanysData.append(UserDataTypeModel(key: "Is_Featured".localized(), value: String(userDetails?.isFeatured ?? 0)))
        userCompanysData.append(UserDataTypeModel(key: "Agent_Count".localized(), value: String(userDetails?.agentCount ?? 0)))
    }
}

struct UserDataTypeModel {
    let key: String?
    let value: String
    var propertyIDs = ""
}

struct UserDetailsModel {
    var isExpanded = true
    var detailsTitle: String?
    let detailsData: [UserDataTypeModel]?

    init(with detailsTitle: String?, for detailsData: [UserDataTypeModel]?) {
        self.detailsTitle = detailsTitle
        self.detailsData = detailsData
    }
}
