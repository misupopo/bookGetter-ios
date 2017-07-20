//
//  CustomUICollectionViewCell.swift
//  layout3
//
//  Created by 土居豊明 on 2017/01/24.
//  Copyright © 2017年 土居豊明. All rights reserved.
//

import UIKit

class CustomUICollectionViewCell: UICollectionViewCell {
    var textLabel : UILabel?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // UILabelを生成.
        textLabel = UILabel(frame: CGRect(x:0, y:0, width:frame.width, height:frame.height))
        textLabel?.text = "nil"
        textLabel?.backgroundColor = UIColor.white
        textLabel?.textAlignment = NSTextAlignment.center
        
        // Cellに追加.
        self.contentView.addSubview(textLabel!)
    }
}
