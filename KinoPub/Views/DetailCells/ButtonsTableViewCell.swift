import UIKit
import CustomLoader
import LKAlertController

class ButtonsTableViewCell: UITableViewCell {
    private let logViewsManager = Container.Manager.logViews
    var model: VideoItemModel!
    var bookmarksModel: BookmarksModel!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var watchlistAndDownloadButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    func configView() {
        backgroundColor = UIColor.clear
        bookmarkButton.setTitleColor(.kpGreyishTwo, for: .normal)
        watchlistAndDownloadButton.setTitleColor(.kpGreyishTwo, for: .normal)
        bookmarkButton.borderColor = .kpGreyishBrown
        watchlistAndDownloadButton.borderColor = .kpGreyishBrown
    }
    
    func config(withModel model: VideoItemModel, bookmarksModel: BookmarksModel) {
        self.model = model
        self.bookmarksModel = bookmarksModel
        configBookmarksButton()
        configWatchlistAndDownloadButton()
    }
    
    func configBookmarksButton() {
        if let itemFolders = model.item.bookmarks {
            bookmarkButton.setImage(itemFolders.count > 0 ? UIImage(named: "Ok") : nil, for: .normal)
            bookmarkButton.setTitle(itemFolders.count > 0 ? itemFolders[0].title! : "В закладки", for: .normal)
            bookmarkButton.borderColor = itemFolders.count > 0 ? .kpMarigold : .kpGreyishBrown
        }
        bookmarkButton.addTarget(self, action: #selector(showBookmarkFolders), for: .touchUpInside)
    }
    
    func configWatchlistAndDownloadButton() {
        switch model.item.type {
        case ItemType.shows.rawValue, ItemType.docuserial.rawValue, ItemType.tvshows.rawValue:
            watchlistAndDownloadButton.addTarget(self, action: #selector(changeWatchlist), for: .touchUpInside)
            watchlistAndDownloadButton.setImage(model.item.inWatchlist! ? UIImage(named: "Ok") : nil, for: .normal)
        default:
            watchlistAndDownloadButton.addTarget(self, action: #selector(showWatchAction), for: .touchUpInside)
        }
        if model.item.videos?.first?.watched == 0 || model.item.inWatchlist! {
            watchlistAndDownloadButton.setTitle("Смотрю", for: .normal)
            watchlistAndDownloadButton.borderColor = .kpMarigold
        } else {
            watchlistAndDownloadButton.setTitle("Буду смотреть", for: .normal)
            watchlistAndDownloadButton.borderColor = .kpGreyishBrown
        }
    }
    
    @objc func changeWatchlist() {
        logViewsManager.changeWatchlist(id: model.item.id?.string ?? "")
    }
    
    @objc func showBookmarkFolders() {
        _ = LoadingView.system(withStyle: .white).show(inView: bookmarkButton)
        bookmarksModel.loadBookmarks { [weak self] (bookmarks) in
            guard let strongSelf = self else { return }
            defer {
                Helper.hapticGenerate(style: .medium)
                strongSelf.bookmarkButton.removeLoadingViews(animated: true)
            }
            guard let bookmarks = bookmarks else { return }
            guard !bookmarks.isEmpty else {
                strongSelf.showNewFolderAlert()
                return
            }
            guard let itemId = strongSelf.model.item.id else { return }
            
            let action = ActionSheet(message: "Выберите папку").tint(.kpBlack)
            action.addAction("+ Новая папка", style: .default, handler: { (_) in
                strongSelf.showNewFolderAlert()
            })
            for folder in bookmarks {
                guard var folderTitle = folder.title else { continue }
                guard let itemFolders = strongSelf.model.item.bookmarks else { continue }
                var style = UIAlertActionStyle.default
                if itemFolders.contains(folder) {
                    folderTitle = "✓ " + folderTitle
                    style = .destructive
                }
                action.addAction(folderTitle, style: style, handler: { (_) in
                    strongSelf.bookmarksModel.toggleItemToFolder(item: itemId.string, folder: folder.id.string)
                })
            }
            action.addAction("Отмена", style: .cancel)
            action.setPresentingSource(strongSelf.bookmarkButton)
            action.show()
        }
    }
    
    func showNewFolderAlert() {
        var textField = UITextField()
        textField.placeholder = "Название"
        Alert(title: "Новая папка", message: "Придумайте короткое и ёмкое название для новой папки").tint(.kpBlack)
            .addTextField(&textField)
            .addAction("Отмена", style: .cancel)
            .addAction("Создать", style: .default, preferredAction: true) { [weak self] (action) in
                guard let strongSelf = self else { return }
                guard let text = textField.text else { return }
                strongSelf.bookmarksModel.createBookmarkFolder(title: text, completed: { (bookmark) in
                    guard let itemId = strongSelf.model.item.id else { return }
                    guard let bookmarkId = bookmark?.id else { return }
                    strongSelf.bookmarksModel.toggleItemToFolder(item: itemId.string, folder: bookmarkId.string)
                })
            }
            .show(animated: true)
    }
    
    @objc func showWatchAction() {
        guard let watch = model.item?.videos?.first?.watching?.status else { return }
        let actionVC = ActionSheet().tint(.kpBlack)
        
        actionVC.addAction(watch == Status.watching ? "Удалить из «Я смотрю»" : "Добавить в «Я смотрю»", style: .default) { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.logViewsManager.changeWatchlistForMovie(id: strongSelf.model.item?.id ?? 0, time: watch == Status.watching ? 0 : 30)
        }
        actionVC.addAction(watch == Status.watched ? "Еще не смотрел" : "Уже видел", style: .default) { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.logViewsManager.changeWatchingStatus(id: strongSelf.model.item?.id ?? 0, video: nil, season: 0, status: nil)
        }
        actionVC.addAction("Отмена", style: .cancel)
        actionVC.setPresentingSource(watchlistAndDownloadButton)
        actionVC.show()
        Helper.hapticGenerate(style: .medium)
    }
    
    @objc func showQualitySelectAction() {
        let actionVC = ActionSheet(message: "Выберите качество").tint(.kpBlack)
        
        guard let files = model.files else { return }
        for file in files {
            guard let url = file.url?.http else { return }
            actionVC.addAction(file.quality, style: .default, handler: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.showDownloadAction(with: url, quality: file.quality, inView: strongSelf.watchlistAndDownloadButton)
            })
        }
        actionVC.addAction("Отменить", style: .cancel)
        actionVC.setPresentingSource(watchlistAndDownloadButton)
        actionVC.show()
        Helper.hapticGenerate(style: .medium)
    }
    
    func showDownloadAction(with url: String, quality: String, inView view: UIView) {
        let name = (self.model.item?.title?.replacingOccurrences(of: " /", with: ";"))! + "; \(quality).mp4"
        let poster = self.model.item?.posters?.small
        Share().showActions(url: url, title: name, quality: quality, poster: poster!, inView: view)
    }

}
