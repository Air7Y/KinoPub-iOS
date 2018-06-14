//
//  PickerInlineRowCustom.swift
//  qinoa
//
//  Created by Евгений Дац on 15.06.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//
//  PickerInlineRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Eureka

// MARK: PickerInlineRow

open class _PickerInlineRowCustom<T> : Row<PickerInlineCell<T>>, NoValueDisplayTextConformance where T: Equatable {
    
    public typealias InlineRow = PickerRowCustom<T>
    open var options = [T]()
    open var noValueDisplayText: String?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A generic inline row where the user can pick an option from a picker view which shows and hides itself automatically
public final class PickerInlineRowCustom<T> : _PickerInlineRowCustom<T>, RowType, InlineRowType where T: Equatable {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
    
    public func setupInlineRow(_ inlineRow: InlineRow) {
        inlineRow.options = self.options
        inlineRow.displayValueFor = self.displayValueFor
        inlineRow.cell.height = { UITableViewAutomaticDimension }
    }
}
