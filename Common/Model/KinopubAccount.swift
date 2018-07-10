import Foundation

struct KinopubAccount {
    let accessToken: String
    let refreshToken: String?
}

enum AccountKeys: String {
    case accessToken, refreshToken
}
