//
//  StarCell.swift
//  Diary
//
//  Created by Nortiz M1 on 2022/08/24.
//

import UIKit

class StarCell: UICollectionViewCell {
    
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.contentView.layer.cornerRadius = 10.0
		self.contentView.layer.backgroundColor = UIColor.systemGray6.cgColor
	}
}
