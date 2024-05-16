//
//  YXRoundedController.swift
//  YXDemo
//
//  Created by yuan yu on 2023/12/1.
//

import UIKit

class YXRoundedController: UIViewController {
    
    var mTableView = RoundedTableView()
    var mTextView = RoundedTextView()
    var mChatView = UIView()
    var textViewHeight = 40.0
    var chatViewHeight = UIScreen.main.bounds.size.height - 140
    let chatViewHeightOld = UIScreen.main.bounds.size.height - 140
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "this is send"
    
        loadChatView()
        loadData()
    }
    
    func loadData() {
        
        mTableView.datas += [["messageType":"0", "text" :"未知消息", "url" : "", "leftOrRight" : "left", "from" : "test001", "cellWidth" : "\(UIScreen.main.bounds.size.width)", "cellHeight" : "50"]]
        
    }
    
    func loadChatView() {
        
        let chatView = UIView.init(frame: CGRectZero)
        chatView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        chatView.layer.cornerRadius = 10
        view.addSubview(chatView)
        mChatView = chatView
        
        let textField = RoundedTextView(frame: CGRectZero)
        textField.returnBlock = {[weak self] text in
            let height = self?.calculateTextHeight(text: text, font: UIFont.systemFont(ofSize: 17), width: UIScreen.main.bounds.size.width - 10)
            self?.mTableView.datas += [["text" : text, "leftOrRight" : "right", "from" : "me", "cellWidth" : "\(UIScreen.main.bounds.size.width)", "cellHeight" : "\(height! + 30)"]]
            
            self?.textViewHeight = Double(40)
            self?.viewDidLayoutSubviews()
        }
        textField.heightChangeBlock = { [weak self] height in
            self?.textViewHeight = Double(height)
            self?.viewDidLayoutSubviews()
            self?.scrollToBottom()
        }
        chatView.addSubview(textField)
        mTextView = textField
        
        let tableView = RoundedTableView(frame: CGRectZero)
        tableView.backgroundColor = .clear
        chatView.addSubview(tableView)
        mTableView = tableView
        
        let hideKeyboard = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboardAction))
        view.addGestureRecognizer(hideKeyboard)
        
        // 注册键盘通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        // 移除键盘监听
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
        mChatView.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: chatViewHeight)
        mTextView.frame = CGRect(x: 10, y: chatViewHeight - CGFloat(textViewHeight), width: UIScreen.main.bounds.size.width - 20, height: CGFloat(textViewHeight))
        mTableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: chatViewHeight - CGFloat(textViewHeight))
    }
    
    @objc func hideKeyboardAction() {
        view.endEditing(true)
    }
    
    func scrollToBottom() {
        if (self.mTableView.datas.count > 0) {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.mTableView.scrollToRow(at: NSIndexPath(row: (self?.mTableView.datas.count ?? 1) - 1, section: 0) as IndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    //计算高度
    func calculateTextHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: width, height: 10))
        label.text = text
        label.numberOfLines = 0
        label.sizeToFit()
        
        return CGFloat(label.bounds.size.height) + 2
    }

    //键盘弹出
    @objc func keyboardWillShow(notification : Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            // 执行你想要的操作，比如调整界面布局
            print("键盘弹出，高度为：\(keyboardHeight)")
            
            chatViewHeight = chatViewHeightOld - keyboardHeight + 40
            viewDidLayoutSubviews()
            
            scrollToBottom()
        }
    }
    
    @objc func keyboardWillHide(sender : Notification) {
        chatViewHeight = chatViewHeightOld
        viewDidLayoutSubviews()
        
        scrollToBottom()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


/*可变位置聊天tool=========================*/
class RoundedTableView : UITableView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, RoundedCellDelegate {
    func didTapMessageView(_ cell: UITableViewCell, _ model: [String : String]?) {
        let data = model!
        let url = data["url"]
        if (data["messageType"] != nil) {
            if (data["messageType"]! == "2") {
                //播放语音消息
                if (url != nil) {
                    print("===" + url!)
                    rcell = cell as! RoundedCell
                }
            }
        }
    }
    
    func playAudio(_ filePath: String, didBeganWithError error: Error?) {
        tempContent = rcell.yxTextLabel.text!
    }
    
    func playAudio(_ filePath: String, progress value: Float) {
        rcell.yxTextLabel.text = "\(value)"
    }
    
    func playAudio(_ filePath: String, didCompletedWithError error: Error?) {
        rcell.yxTextLabel.text = tempContent
    }
    
    var cellH = 60
    var rcell = RoundedCell()
    var tempContent = ""
    
    var datas = [[String : String]]() {
        willSet {
            
        }
        didSet {
            self.reloadData()
            self.scrollToRow(at: NSIndexPath(row: datas.count - 1, section: 0) as IndexPath, at: .bottom, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : RoundedCell = tableView.dequeueReusableCell(withIdentifier: "mCell") as! RoundedCell
        let data = datas[indexPath.row]
        cell.loadData(data: data)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = datas[indexPath.row]
        let cellHeight = data["cellHeight"]
        if let height = Float(cellHeight ?? "") {
            if (height > Float(cellH)) {
                return CGFloat(height)
            }
        }
        return CGFloat(cellH)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datas[indexPath.row]
        let url = data["url"]
        if (data["messageType"] != nil) {
            if (data["messageType"]! == "2") {
                //播放语音消息
                if (url != nil) {
                    
                }
            }
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        self.delegate = self
        self.dataSource = self
        self.register(RoundedCell.self, forCellReuseIdentifier: "mCell")
        self.separatorStyle = .none
        self.showsVerticalScrollIndicator = false
        if (datas.count > 0) {
            self.scrollToRow(at: NSIndexPath(row: datas.count - 1, section: 0) as IndexPath, at: .bottom, animated: true)
        }
    }
}

@objc
protocol RoundedCellDelegate : NSObjectProtocol {
    // 单击消息体
    func didTapMessageView(_ cell: UITableViewCell, _ model: [String : String]?)
}

/*cell*/
class RoundedCell : UITableViewCell {
    
    var yxTextLabel = UILabel()
    var yxDetailLabel = UILabel()
    var yxImageView = UIImageView()
    var backView = UIView()
    var cellWidthInt = 200
    var cellHeightInt = 60
    var messageData = ["" : ""]
    public weak var delegate: RoundedCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        self.contentView.addSubview(backView)
        
        yxTextLabel.numberOfLines = 0
        yxTextLabel.font = UIFont.systemFont(ofSize: 17)
        yxDetailLabel.font = UIFont.systemFont(ofSize: 15)
        yxDetailLabel.textColor = .gray
    
        yxImageView.isHidden = true
        yxTextLabel.isUserInteractionEnabled = true
        yxDetailLabel.isUserInteractionEnabled = true
        yxImageView.isUserInteractionEnabled = true
        backView.isUserInteractionEnabled = true
        
        backView.addSubview(yxTextLabel)
        backView.addSubview(yxDetailLabel)
        backView.addSubview(yxImageView)
        
        let cellTap = UITapGestureRecognizer.init(target: self, action: #selector(cellTapAction))
        backView.addGestureRecognizer(cellTap)
        
    }
    
    @objc func cellTapAction() {
        
        delegate?.didTapMessageView(self, messageData)
        
    }
    
    override func layoutSubviews() {
        
        backView.frame = CGRect(x: 5, y: 5, width: cellWidthInt - 10, height: cellHeightInt - 10)
        yxTextLabel.frame = CGRect(x: 0, y: 0, width: Int(backView.bounds.size.width), height: Int(backView.bounds.size.height) - 20)
        yxDetailLabel.frame = CGRect(x: 0, y: Int(CGRectGetMaxY(yxTextLabel.frame)), width: Int(backView.bounds.size.width), height: 20)
        yxImageView.frame = CGRect(x: 0, y: 0, width: Int(backView.bounds.size.height) - 20, height: Int(backView.bounds.size.height) - 20)
    }
    
    func loadData(data : [String : String]) {
        messageData = data
        if (data["text"] != nil) {
            self.yxTextLabel.text = data["text"]
        }
        if (data["from"] != nil) {
            self.yxDetailLabel.text = data["from"]
        }
        if (data["leftOrRight"] == "right") {
            self.yxTextLabel.textAlignment = .right
            self.yxDetailLabel.textAlignment = .right
        } else {
            self.yxTextLabel.textAlignment = .left
            self.yxDetailLabel.textAlignment = .left
        }

        cellWidthInt = 200
        let cellWidth = data["cellWidth"]
        if let a = Float(cellWidth ?? "") {
            cellWidthInt = Int(a)
        }
        
        cellHeightInt = 60
        let cellHeight = data["cellHeight"]
        if let b = Float(cellHeight ?? "") {
            if b > Float(cellHeightInt) {
                cellHeightInt = Int(b)
            }
        }
        
        if (data["messageType"] != nil) {
            if (data["messageType"]! == "0") {
                //文本
                self.yxTextLabel.isHidden = false
                self.yxImageView.isHidden = true
            } else if (data["messageType"]! == "1") {
                //图片
                if (data["url"] != nil) {
                    self.yxTextLabel.isHidden = true
                    self.yxImageView.isHidden = false
                    let urlStr = data["url"]
//                    self.yxImageView.sd_setImage(with: URL(string: urlStr!))
                }
            } else {
                self.yxTextLabel.isHidden = false
                self.yxImageView.isHidden = true
            }
        }

        self.backgroundColor = .clear
        layoutSubviews()
    }
}

/*textView*/
class RoundedTextView : UITextView {
    var meFrame = CGRect()
    typealias ReturnBlock = (String) -> Void
    typealias HeightChangeBlock = (Float) -> Void
    var returnBlock: ReturnBlock = { text in
        
    }
    var heightChangeBlock : HeightChangeBlock = { height in
        
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.font = UIFont.systemFont(ofSize: 17)
        self.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoundedTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        heightChangeBlock(Float(newSize.height))
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
//            textView.resignFirstResponder() // 隐藏键盘
            returnBlock(textView.text)
            textView.text = ""
            return false // 不插入换行符
        }
        return true
    }
    
}
