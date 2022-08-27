//
//  ViewController.swift
//  Diary
//
//  Created by Nortiz M1 on 2022/08/24.
//

import UIKit

class ViewController: UIViewController {
	
	// MARK: - 프로퍼티
	@IBOutlet weak var collectionView: UICollectionView!
	
	private var diaryList = [Diary]() {
		didSet {
			self.saveDiaryList()
		}
	}
	
	// MARK: - 뷰 로드 메서드
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureCollectionView()
		self.loadDiaryList()
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(editDiaryNotification(_:)),
			name: NSNotification.Name("editDiary"),
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(starDiaryNotification(_:)),
			name: NSNotification.Name("starDiary"),
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(deleteDiaryNotification(_:)),
			name: NSNotification.Name("deleteDiary"),
			object: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let wireDiaryViewController = segue.destination as? WriteDiaryViewController {
			wireDiaryViewController.delegate = self
		}
	}
	
	// MARK: - 뷰 설정 메서드
	private func configureCollectionView() {
		self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
		self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
	}
	
	// MARK: - Diary 저장, 로드 메서드
	private func saveDiaryList() {
		let data = self.diaryList.map {
			[
				"title": $0.title,
				"contents": $0.contents,
				"date": $0.date,
				"isStar": $0.isStar
			]
		}
		let userDefaults = UserDefaults.standard // Userdefaults 에 접근할 수 있도록 초기화
		userDefaults.set(data, forKey: "diaryList") // 첫번째 파라미터에 data 를 넘겨준다.
	}
	
	private func loadDiaryList() {
		let userDefaults = UserDefaults.standard
		guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
		self.diaryList = data.compactMap { // Diary 타입의 배열이 되도록 매칭
			guard let title = $0["title"] as? String else { return nil }
			guard let contents = $0["contents"] as? String else { return nil }
			guard let date = $0["date"] as? Date else { return nil }
			guard let isStar = $0["isStar"] as? Bool else { return nil }
			return Diary(title: title, contents: contents, date: date, isStar: isStar)
		}
		self.diaryList = self.diaryList.sorted(by: {
			$0.date.compare($1.date) == .orderedDescending
		})
	}
	
	// MARK: - Notification 관련 메서드
	@objc func editDiaryNotification(_ notification: Notification) {
		guard let diary = notification.object as? Diary else { return }
		guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
		self.diaryList[row] = diary
		self.diaryList = self.diaryList.sorted(by: {
			$0.date.compare($1.date) == .orderedDescending
		})
		self.collectionView.reloadData()
	}
	
	@objc func starDiaryNotification(_ notification: Notification) {
		guard let starDiary = notification.object as? [String: Any] else { return }
		guard let isStar = starDiary["isStar"] as? Bool else { return }
		guard let indexPath = starDiary["indexPath"] as? IndexPath else { return }
		self.diaryList[indexPath.row].isStar = isStar
	}
	
	@objc func deleteDiaryNotification(_ notification: Notification) {
		guard let indexPath = notification.object as? IndexPath else { return }
		self.diaryList.remove(at: indexPath.row)
		self.collectionView.deleteItems(at: [indexPath])
	}
	
	// MARK: - 기타 메서드
	private func dateToString(date: Date) -> String {
		let formatter  = DateFormatter()
		formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
		formatter.locale = Locale(identifier: "ko-KR")
		return formatter.string(from: date)
	}
}

// MARK: - 익스텐션
extension ViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.diaryList.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
		let diary = self.diaryList[indexPath.row] // 배열에 저장되어 있는 일기를 가져온다.
		cell.titleLabel.text = diary.title
		// diartList 에 있는 date 값는 Date 타입이므로 별도 메서드를 통해 String 으로 변환한다.
		cell.dataLabel.text = self.dateToString(date: diary.date)
		return cell
	}
}

extension ViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
	}
}

extension ViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// 특정 셀이 선택되었음을 알려주는 메서드. DiaryDetailViewController 가 푸쉬 되도록 구현
		guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
		let diary = self.diaryList[indexPath.row]
		viewController.diary = diary
		viewController.indexPath = indexPath
//		viewController.delegate = self
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}

extension ViewController: WriteDiaryViewDelegate {
	func didSelectRegister(diary: Diary) {
		self.diaryList.append(diary)
		self.diaryList = self.diaryList.sorted(by: {
			$0.date.compare($1.date) == .orderedDescending
		})
		self.collectionView.reloadData()
	}
}
