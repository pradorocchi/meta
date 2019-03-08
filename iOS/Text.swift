import meta
import UIKit

class Text: UITextView, UITextViewDelegate {
    private weak var document: Editable?
    private weak var ruler: Ruler!
    private weak var line: Line!
    
    init(_ document: Editable) {
        let storage = Storage()
        super.init(frame: .zero, textContainer: {
            storage.addLayoutManager($1)
            $1.addTextContainer($0)
            $0.lineBreakMode = .byCharWrapping
            return $0
        } (NSTextContainer(), Layout()) )
        
        let line = Line()
        insertSubview(line, at: 0)
        self.line = line
        line.top = line.topAnchor.constraint(equalTo: topAnchor)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isScrollEnabled = false
        bounces = false
        textColor = .white
        tintColor = .halo
        font = .light(Skin.font)
        text = document.content
        keyboardAppearance = .dark
        autocorrectionType = .no
        spellCheckingType = .no
        autocapitalizationType = .none
        contentInset = .zero
        delegate = self
        self.document = document
        
        let ruler = Ruler(self, layout: layoutManager as! Layout)
        addSubview(ruler)
        self.ruler = ruler
        
        ruler.heightAnchor.constraint(greaterThanOrEqualToConstant: App.shared.frame.height).isActive = true
        ruler.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor).isActive = true
        ruler.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        ruler.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        textContainerInset = UIEdgeInsets(top: 60, left: ruler.thickness + 5, bottom: 20, right: 12)
        if #available(iOS 11.0, *) { contentInsetAdjustmentBehavior = .never }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width += 2
        line.top.constant = rect.origin.y
        line.height.constant = rect.height
        return rect
    }
    
    func textViewDidChange(_: UITextView) {
        document?.content = text
        ruler.setNeedsDisplay()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let document = self?.document else { return }
            List.shared.folder.save(document)
        }
    }
    
    func textViewDidBeginEditing(_: UITextView) {
        line.isHidden = false
    }
    
    func textViewDidEndEditing(_: UITextView) {
        line.isHidden = true
    }
}
