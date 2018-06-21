import Foundation
import LKAlertController
import NotificationBannerSwift

protocol BookmarksModelDelegate: class {
    func didUpdateBookmarks(model: BookmarksModel)
    func didUpdateItems(model: BookmarksModel)
    func didAddedBookmarks()
}

extension BookmarksModelDelegate {
    func didUpdateBookmarks(model: BookmarksModel) {
        
    }
    func didUpdateItems(model: BookmarksModel) {
        
    }
    func didAddedBookmarks() {
        
    }
}

class BookmarksModel {
    weak var delegate: BookmarksModelDelegate?
    var bookmarks = [Bookmarks]()
    var items = [Item]()
    var folder: Bookmarks?
    var page: Int = 1
    
    let accountManager: AccountManager
    let networkingService: BookmarksNetworkService
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        networkingService = BookmarksNetworkService(requestFactory: accountManager.requestFactory)
        //        accountManager.addDelegate(delegate: self)
    }
    
    func loadBookmarks(completed: @escaping (([Bookmarks]?) -> Void)) {
        networkingService.receiveBookmarks { [weak self] (bookmarks, error) in
            guard let strongSelf = self else { return }
            if let itemsData = bookmarks {
                strongSelf.bookmarks = itemsData
                completed(itemsData)
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? "")
                completed(nil)
            }
        }
    }
    
    func loadBookmarkItems(completed: @escaping (_ count: Int?) -> ()) {
        networkingService.receiveBookmarkItems(id: (folder?.id?.string)!, page: page.string) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let itemsData = response {
                guard let items = itemsData.items else { return }
                strongSelf.page += 1
                strongSelf.items.append(contentsOf: items)
                strongSelf.delegate?.didUpdateItems(model: strongSelf)
                completed(itemsData.items?.count)
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? "")
                completed(nil)
            }
        }
    }
    
    func createBookmarkFolder(title: String, completed: ((Bookmarks?) -> ())? = nil) {
        networkingService.createBookmarkFolder(title: title) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response, responseData.status == 200 {
                Helper.showSuccessStatusBarBanner("Папка \"\(title)\" успешно создана")
                strongSelf.delegate?.didUpdateBookmarks(model: strongSelf)
                completed?(responseData.folder)
            } else {
                Helper.showErrorBanner("Невозможно создать папку. \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func removeBookmarkFolder(folder: String) {
        networkingService.removeBookmarkFolder(folder: folder) { (response, error) in
            if let responseData = response, responseData.status == 200 {
                Helper.showSuccessStatusBarBanner("Папка успешно удалена.")
            } else {
                Helper.showErrorBanner("Невозможно удалить папку. \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func removeItemFromFolder(item: String, folder: String) {
        networkingService.removeItemFromFolder(item: item, folder: folder) { (response, error) in
            if let responseData = response, responseData.status == 200 {
                Helper.showSuccessStatusBarBanner("Успешно удален.")
            } else {
                Helper.showErrorBanner("Невозможно удалить. \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func addItemToFolder(item: String, folder: String) {
        networkingService.addItemToFolder(item: item, folder: folder) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response, responseData.status == 200 {
                Helper.showSuccessStatusBarBanner("Успешно добавлен.")
                strongSelf.delegate?.didAddedBookmarks()
            } else {
                Helper.showErrorBanner("Невозможно добавить. \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func toggleItemToFolder(item: String, folder: String) {
        networkingService.toggleItemToFolder(item: item, folder: folder) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response, responseData.status == 200 {
                Helper.showSuccessStatusBarBanner(responseData.exists! ? "Закладка добавлена." : "Закладка удалена.")
                strongSelf.delegate?.didAddedBookmarks()
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? "")
            }
        }
    }
    
    func getItemFolders(item: String, completed: @escaping (([Bookmarks]?) -> Void)) {
        networkingService.receiveItemFolders(item: item) { (response, error) in
            if let responseData = response {
                completed(responseData)
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? "")
            }
        }
    }
    
    func refresh() {
        page = 1
        items.removeAll()
    }
    
}
