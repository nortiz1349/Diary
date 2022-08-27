//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by Nortiz M1 on 2022/08/24.
//

import UIKit

enum DiaryEditorMode {
	case new
	case edit(Diary)
}

protocol WriteDiaryViewDelegate: AnyObject {
	func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {
	
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var contentsTextView: UITextView!
	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var confirmButton: UIBarButtonItem!
	
	private let datePicker = UIDatePicker()
	private var diaryDate: Date? // DatePicker 에서 선택한 날짜를 저장
	weak var delegate: WriteDiaryViewDelegate?
	var diaryEditorMode: DiaryEditorMode = .new
	
	// MARK: - 뷰 로드
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureContentsTextView()
		self.configureDatePicker()
		self.configureInputField()
		self.configureEditMode()
	
		self.confirmButton.isEnabled = false
	}
	
	// MARK: - 뷰 설정
	// 텍스트 뷰 테두리 설정
	private func configureContentsTextView() {
		let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0) // rgb 값에 0 ~ 1.0 사이의 값이 들어가야 되므로 나눗셈으로 표현
		self.contentsTextView.layer.borderColor = borderColor.cgColor // borderColor 는 UIColor 가 아닌 cgColor 로 설정해야 한다.
		self.contentsTextView.layer.borderWidth = 0.5
		self.contentsTextView.layer.cornerRadius = 5.0
	}
	
	// 등록버튼 활성화 상태를 설정
	private func configureInputField() {
		self.contentsTextView.delegate = self // extension 으로 delegate 채택
		self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
		self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
	}
	
	@objc private func titleTextFieldDidChange(_ textField: UITextField) {
		self.validateInputField()
	}
	
	@objc private func dateTextFieldDidChange(_ textField: UITextField) {
		self.validateInputField()
	}
	
	// 등록 버튼의 활성화 여부를 판단하는 메서드
	private func validateInputField() {
		self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
	}
	
	private func configureEditMode() {
		switch self.diaryEditorMode {
		case let .edit(diary):
			self.titleTextField.text = diary.title
			self.contentsTextView.text = diary.contents
			self.dateTextField.text = self.dateToString(date: diary.date)
			self.diaryDate = diary.date
			self.confirmButton.title = "수정"
		default:
			self.setDateToday()
		}
	}
	
	private func setDateToday() {
		let todayDate: Date = Date()
		let formater = DateFormatter()
		formater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
		formater.locale = Locale(identifier: "ko_KR")
		self.diaryDate = todayDate
		self.dateTextField.text = formater.string(from: todayDate)
	}
	
	// MARK: - DatePicker 메서드
	private func configureDatePicker() { // DatePicker 설정
		self.datePicker.datePickerMode = .date // 날짜만 나오게 설정
		self.datePicker.preferredDatePickerStyle = .wheels
		self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
		self.dateTextField.inputView = self.datePicker // 텍스트필드 선택 시 키보드가 아닌 데이트픽커가 표시됨
	}
	
	@objc private func datePickerValueDidChange(_ datePicker: UIDatePicker ) {
		let formater = DateFormatter() // Date 타입을 사람이 읽을 수 있는 문자열 형태로 반환
		formater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
		formater.locale = Locale(identifier: "ko_KR")
		self.diaryDate = datePicker.date
		self.dateTextField.text = formater.string(from: datePicker.date)
		self.dateTextField.sendActions(for: .editingChanged)
	}
	
	// MARK: - 기타 메서드
	// Date 타입 문자열로 변환
	private func dateToString(date: Date) -> String {
		let formatter  = DateFormatter()
		formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
		formatter.locale = Locale(identifier: "ko-KR")
		return formatter.string(from: date)
	}
	
	// 데이트픽커, 키보드 숨기기
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	// MARK: - 버튼 액션 메서드
	@IBAction func tabConfirmButton(_ sender: UIBarButtonItem) {
		guard let title = self.titleTextField.text else { return }
		guard let contents = self.contentsTextView.text else { return }
		guard let date = self.diaryDate else { return }
		
		switch self.diaryEditorMode {
		case .new:
			let diary = Diary(
				uuidString: UUID().uuidString,
				title: title,
				contents: contents,
				date: date,
				isStar: false
			)
			self.delegate?.didSelectRegister(diary: diary)
			
		case let .edit(diary):
			let diary = Diary(
				uuidString: diary.uuidString,
				title: title,
				contents: contents,
				date: date,
				isStar: diary.isStar
			)
			NotificationCenter.default.post(
				name: NSNotification.Name("editDiary"),
				object: diary,
				userInfo: nil
			)
		}
		self.navigationController?.popViewController(animated: true)
	}
}

// MARK: - 익스텐션
extension WriteDiaryViewController: UITextViewDelegate {
	
	// 텍스트뷰에 텍스트가 입력 될 때마다 호출되는 메서드를 구현
	func textViewDidChange(_ textView: UITextView) {
		self.validateInputField()
	}
}
