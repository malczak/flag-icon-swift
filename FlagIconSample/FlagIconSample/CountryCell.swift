//
//  CountryCell.swift
//  FlagIconSample
//
//  Created by Mateusz Malczak on 08/10/2019.
//  Copyright © 2019 Mateusz Malczak. All rights reserved.
//

import Foundation
import flag_icon_swift

class CountryCell: UITableViewCell {
    
    lazy var flagView: UIImageView! = {
        return UIImageView()
    }()
    
    lazy var nameLabel: UILabel! = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let oldSelection = isSelected
        super.setSelected(selected, animated: animated)
        if oldSelection != isSelected {
            self.nameLabel.textColor = isSelected ? UIColor.white : UIColor.lightGray
        }
    }
    
    func setup() {
        flagView.contentMode = .scaleAspectFit
        flagView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView?.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(flagView)
        contentView.addSubview(nameLabel)

        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.lightGray
        selectedBackgroundView = bgColorView
        
        let views:[String : Any] = [
            "img": flagView!,
            "lbl": nameLabel!
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[img(==21)]-10-[lbl]|",
                                                                  options: .alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[img(==16@250)]|",
                                                                  options: .alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: views))
    }
}
