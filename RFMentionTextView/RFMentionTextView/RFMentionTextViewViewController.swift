//
//  RFMentionTextViewViewController.swift
//  RFMentionTextView
//
//  Created by Rifat Firdaus on 3/26/18.
//  Copyright © 2018 Ripatto. All rights reserved.
//

import UIKit

open class RFMentionItem {
    public var id: Int64 = 0
    public var text = ""
    public init(id:Int64 = 0, text: String = "") {
        self.id = id
        self.text = text
    }
}

struct MentionedItem {
    var text = ""
    var textAt = ""
    var range = NSRange()
}

open class RFMentionTextViewViewController: UIViewController {

    var textViewMention: UITextView = UITextView()
    var tableViewMention: UITableView!
    
    var rfMentionItems = [RFMentionItem]()
    var rfMentionItemsFilter = [RFMentionItem]()
    var tableViewMentionVConstraint = [NSLayoutConstraint]()
    
    var isTableHidden = true
    var isTextViewSearch = false
    var cellHeight = 44
    
    var mentionedItems = [MentionedItem]()
    var mentionAttributed = [NSAttributedStringKey.foregroundColor : UIColor.blue]
    var searchString = ""
    
    private let tableWidth = Int(UIScreen.main.bounds.width)
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableViewMention = UITableView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: cellHeight * rfMentionItems.count), style: UITableViewStyle.plain)
        view.addSubview(tableViewMention)
        tableViewMention.register(UITableViewCell.self, forCellReuseIdentifier: "defCell")
        tableViewMention.delegate = self
        tableViewMention.dataSource = self
        tableViewMention.isHidden = isTableHidden
        tableViewMention.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: METHODS
    
    public func setUpMentionTextView(textView: UITextView, itemList: [RFMentionItem]) {
        textViewMention = textView
        rfMentionItems = itemList
        rfMentionItemsFilter = rfMentionItems
        textViewMention.delegate = self
        reloadViewTable()
        
        let views: [String: Any] = [
            "textViewMention": textViewMention,
            "tableViewMention": tableViewMention
        ]
        
        var allConstraints: [NSLayoutConstraint] = []
        
        let tableViewMentionHConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[tableViewMention]-0-|",
            metrics: nil,
            views: views)
        allConstraints += tableViewMentionHConstraint
        
        var tableHeight = rfMentionItemsFilter.count * cellHeight
        if rfMentionItems.count > 5 {
            tableHeight = cellHeight * 5
        }
        
        tableViewMentionVConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[tableViewMention(\(tableHeight))]-(-\(tableHeight))-[textViewMention]",
            metrics: nil,
            views: views)
        allConstraints += tableViewMentionVConstraint
        NSLayoutConstraint.activate(allConstraints)
    }
    
    private func reloadViewTable() {
        tableViewMention.contentInset = UIEdgeInsetsMake(4, 0, 4, 0)
        tableViewMention.reloadData()
    }
    
    private func showList() {
        if self.isTableHidden == true {
            self.tableViewMentionVConstraint[1].constant = 0
            UIView.transition(with: tableViewMention, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.tableViewMention.isHidden = false
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.isTableHidden = false
            })
        }
    }
    
    private func hideList() {
        if self.isTableHidden == false {
            let tableHeight = rfMentionItemsFilter.count * cellHeight
            self.tableViewMentionVConstraint[1].constant = -CGFloat(tableHeight)
            UIView.transition(with: tableViewMention, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.tableViewMention.isHidden = true
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.isTableHidden = true
            })
        }
    }
    
    private func searchText(searchString: String?) {
        let searchString = searchString ?? ""
        print(searchString)
        if searchString != "" {
            rfMentionItemsFilter = rfMentionItems.filter({ item -> Bool in
                return item.text.lowercased().contains(searchString.lowercased())
            })
        } else {
            rfMentionItemsFilter = rfMentionItems
        }
        let tableHeight = rfMentionItemsFilter.count * cellHeight
        self.tableViewMentionVConstraint[0].constant = CGFloat(tableHeight)
        self.tableViewMention.reloadData()
    }
    
}

extension RFMentionTextViewViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rfMentionItemsFilter.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defCell", for: indexPath)
        cell.textLabel?.text = rfMentionItemsFilter[indexPath.row].text
        return cell
    }
    
    // Delegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        isTextViewSearch = false
        let mutableAttributed = NSMutableAttributedString()
        mutableAttributed.append(textViewMention.attributedText)
        mutableAttributed.append(NSAttributedString(string: rfMentionItemsFilter[indexPath.row].text))
        textViewMention.attributedText = mutableAttributed
        self.hideList()
    }
    
}

extension RFMentionTextViewViewController: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(range)
        if text == "" {
//            let otherRange = textViewMention.text.startIndex..<textViewMention.text.endIndex
//            textViewMention.text.removeSubrange(otherRange)
//            return false
            
            let arrayOfWords = textViewMention.text.components(separatedBy: " ")
            let lastWord = arrayOfWords.last
            if let lastWord = lastWord {
                if lastWord.hasPrefix("@") {
                    textViewMention.text = textViewMention.text.replacingOccurrences(of: lastWord, with: " ")
                }
            }
            return true
        }
        if text == "@" {
            isTextViewSearch = true
            rfMentionItemsFilter = rfMentionItems
            tableViewMention.reloadData()
            self.showList()
        } else if isTextViewSearch {
            if text == "" {
                if searchString.count > 0 {
                    searchString.removeLast()
                    searchText(searchString: searchString)
                } else {
                    isTextViewSearch = false
                    self.hideList()
                }
            } else {
                searchString += text
                searchText(searchString: searchString)
            }
        }
        return true
    }
    
}