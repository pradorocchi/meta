import meta
import AppKit

class Text: NSTextView {
    weak var ruler: Ruler?
    weak var line: Line!
    private weak var document: Editable?
    private weak var height: NSLayoutConstraint!
    
    init(_ document: Editable) {
        let storage = Storage()
        super.init(frame: .zero, textContainer: {
            storage.addLayoutManager($1)
            $1.addTextContainer($0)
            $0.lineBreakMode = .byCharWrapping
            return $0
        } (NSTextContainer(), Layout()) )
        translatesAutoresizingMaskIntoConstraints = false
        allowsUndo = true
        drawsBackground = false
        isRichText = false
        insertionPointColor = .halo
        font = .light(Skin.font)
        string = document.content
        textContainerInset = NSSize(width: 12, height: 30)
        height = heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        height.isActive = true
        self.document = document
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func resize(withOldSuperviewSize: NSSize) {
        super.resize(withOldSuperviewSize: withOldSuperviewSize)
        adjust()
    }
    
    override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn: Bool) {
        var rect = rect
        rect.size.width += 2
        line.top.constant = rect.origin.y
        line.height.constant = rect.height
        super.drawInsertionPoint(in: rect, color: color, turnedOn: turnedOn)
    }
    
    override func didChangeText() {
        super.didChangeText()
        document?.content = string
        adjust()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let document = self?.document else { return }
            List.shared.folder.save(document)
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        line.isHidden = false
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        line.isHidden = true
        return super.resignFirstResponder()
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        DispatchQueue.main.async { [weak self] in self?.adjust() }
    }
    
    override func updateRuler() { ruler?.setNeedsDisplay(visibleRect) }
    
    private func adjust() {
        textContainer!.size.width = Display.shared.frame.width - (textContainerInset.width * 2) - Ruler.thickness
        layoutManager!.ensureLayout(for: textContainer!)
        height.constant = layoutManager!.usedRect(for: textContainer!).size.height + (textContainerInset.height * 2)
        DispatchQueue.main.async { [weak self] in self?.updateRuler() }
    }
}
