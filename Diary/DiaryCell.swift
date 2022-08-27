//
//  DiaryCell.swift
//  Diary
//
//  Created by Nortiz M1 on 2022/08/24.
//

import UIKit

class DiaryCell: UICollectionViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dataLabel: UILabel!
	
	// UIView 가 스토리뷰나 XIB 에서 생성될 때 이 생성자를 통해 객체가 생성된다.
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.contentView.layer.cornerRadius = 10.0
		self.contentView.layer.backgroundColor = UIColor.systemGray6.cgColor
	}
}
