import meta
import UIKit

class Commit: Sheet, UITextViewDelegate {
    private weak var text: UITextView!
    private weak var placeholder: UILabel!
    private let status: Status
    
    @discardableResult init(_ status: Status) {
        self.status = status
        super.init(true)
        
        let commit = Link(.local("Commit.commit"), target: self, selector: #selector(self.commit))
        addSubview(commit)
        
        let cancel = UIButton()
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.setImage(#imageLiteral(resourceName: "cancel.pdf"), for: [])
        cancel.imageView!.clipsToBounds = true
        cancel.contentMode = .center
        addSubview(cancel)
        
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = UIColor(white: 1, alpha: 0.1)
        text.alwaysBounceVertical = true
        text.contentSize = .zero
        text.textContainerInset = UIEdgeInsets(top: 30 + App.shared.margin.top, left: 20, bottom: 20, right: 20)
        text.font = .light(16)
        text.textColor = .white
        text.tintColor = .halo
        text.autocorrectionType = .yes
        text.autocapitalizationType = .sentences
        text.spellCheckingType = .yes
        text.keyboardType = .alphabet
        text.keyboardAppearance = .dark
        text.keyboardDismissMode = .interactive
        text.delegate = self
        text.indicatorStyle = .black
        text.inputAccessoryView = {
            $0.backgroundColor = UIColor(white: 1, alpha: 0.1)
            $0.setTitle(.local("Commit.done"), for: [])
            $0.setTitleColor(.halo, for: .normal)
            $0.setTitleColor(UIColor.halo.withAlphaComponent(0.2), for: .highlighted)
            $0.titleLabel!.font = .systemFont(ofSize: 14, weight: .medium)
            $0.addTarget(self, action: #selector(done), for: .touchUpInside)
            return $0
        } (UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 34)))
        addSubview(text)
        self.text = text
        
        let placeholder = UILabel()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.text = .local("Commit.placeholder")
        placeholder.textColor = UIColor(white: 1, alpha: 0.4)
        placeholder.font = text.font
        addSubview(placeholder)
        self.placeholder = placeholder
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.indicatorStyle = .black
        addSubview(scroll)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = UIColor(white: 1, alpha: 0.1)
        addSubview(border)
        
        var top = scroll.topAnchor
        if !status.untracked.isEmpty { top = add(.local("Commit.untracked"), items: status.untracked, scroll: scroll, top: top) }
        if !status.added.isEmpty { top = add(.local("Commit.added"), items: status.added, scroll: scroll, top: top) }
        if !status.modified.isEmpty { top = add(.local("Commit.modified"), items: status.modified, scroll: scroll, top: top) }
        if !status.deleted.isEmpty { top = add(.local("Commit.deleted"), items: status.deleted, scroll: scroll, top: top) }
        scroll.bottomAnchor.constraint(greaterThanOrEqualTo: top, constant: 20).isActive = true
        
        commit.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        commit.bottomAnchor.constraint(equalTo: cancel.topAnchor).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        text.heightAnchor.constraint(equalToConstant: 120 + App.shared.margin.top).isActive = true
        
        placeholder.topAnchor.constraint(equalTo: text.topAnchor, constant: 30 + App.shared.margin.top).isActive = true
        placeholder.leftAnchor.constraint(equalTo: text.leftAnchor, constant: 24).isActive = true
        
        scroll.topAnchor.constraint(equalTo: text.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(greaterThanOrEqualTo: commit.topAnchor, constant: -20).isActive = true
        
        border.topAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        if #available(iOS 11.0, *) {
            cancel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            cancel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    func textViewDidChange(_: UITextView) { placeholder.isHidden = !text.text.isEmpty }
    
    private func add(_ title: String, items: [String], scroll: UIScrollView, top: NSLayoutYAxisAnchor) -> NSLayoutYAxisAnchor {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = title
        header.textColor = .halo
        header.font = .bold(14)
        scroll.addSubview(header)
        
        header.topAnchor.constraint(equalTo: top).isActive = true
        header.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        header.heightAnchor.constraint(equalToConstant: 50).isActive = true
        var top = header.bottomAnchor
        
        items.forEach {
            let item = Commiting($0)
            scroll.addSubview(item)
            
            item.topAnchor.constraint(equalTo: top).isActive = true
            item.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            top = item.bottomAnchor
        }
        
        return top
    }
    
    @objc private func commit() {
        App.shared.endEditing(true)
        close()
    }
    
    @objc private func done() { App.shared.endEditing(true) }
}