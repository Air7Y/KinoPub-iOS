//
//  ThanksViewController.swift
//  KinoPub
//
//  Created by Евгений Дац on 18.08.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import CDMarkdownKit

class ThanksViewController: UIViewController {
    let markdownParser = CDMarkdownParser(fontColor: UIColor.kpGreyishTwo)

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usersTextView: UITextView!
    var titleText: String?
    var url: String?
    var isMarkdown = false
    var names: String? {
        didSet {
            if isMarkdown {
                configMarkdownParcer()
                setupWithMarkdown()
            } else {
                setup()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .kpBackground
        titleLabel.textColor = .kpLightGreen
        usersTextView.textColor = .kpOffWhite
        usersTextView.backgroundColor = .clear
        titleLabel.text = titleText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global().async {
            do {
                self.names = try String(contentsOf: URL(string: self.url!)!)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func setup() {
        DispatchQueue.main.sync {
            usersTextView.text = names
        }
    }
    
    func setupWithMarkdown() {
        guard var markdownString = names else { return }
        markdownString = markdownString.replacingOccurrences(of: "[Unreleased]", with: "Не выпущено")
        
        let regex = try! NSRegularExpression(pattern: "\\s-\\s(\\d{4}-\\d{1,2}-\\d{1,2})", options: .caseInsensitive)
        let range = NSMakeRange(0, markdownString.count)
        markdownString = regex.stringByReplacingMatches(in: markdownString, options: [], range: range, withTemplate: "\n*$1*")
        
        let regex2 = try! NSRegularExpression(pattern: "\\[(\\d\\.\\d\\.?\\d?)\\s[a-z]{5}\\s(\\d{1,})\\]", options: .caseInsensitive)
        let range2 = NSMakeRange(0, markdownString.count)
        markdownString = regex2.stringByReplacingMatches(in: markdownString, options: [], range: range2, withTemplate: "Версия $1 билд $2")
        
        markdownString = markdownString.replacingOccurrences(of: "Added", with: "**ДОБАВЛЕНО**")
        markdownString = markdownString.replacingOccurrences(of: "Changed", with: "**ИЗМЕНЕНО**")
        markdownString = markdownString.replacingOccurrences(of: "Fixed", with: "**ИСПРАВЛЕНО**")
        markdownString = markdownString.replacingOccurrences(of: "Security", with: "**БЕЗОПАСНОСТЬ**")
        markdownString = markdownString.replacingOccurrences(of: "Removed", with: "**УДАЛЕНО**")
        
        DispatchQueue.main.sync {
            usersTextView.attributedText = markdownParser.parse(markdownString)
        }
    }
    
    func configMarkdownParcer() {
        markdownParser.bold.color = UIColor.kpGreyishBrown
        markdownParser.bold.font = UIFont.titleSmall
        
        markdownParser.header.color = UIColor.kpOffWhite
        markdownParser.header.font = UIFont.titleTitle2
        
        markdownParser.list.color = UIColor.kpGreyishTwo
        markdownParser.list.font = UIFont.textRegular
        
        markdownParser.italic.color = UIColor.kpGreyishBrown
        markdownParser.italic.font = UIFont.textSmall
    }

    // MARK: - Navigation

    static func storyboardInstance() -> ThanksViewController? {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? ThanksViewController
    }

}
