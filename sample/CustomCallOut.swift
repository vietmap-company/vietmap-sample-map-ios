import Foundation
import VietMap

class CustomCalloutView: UIView, MLNCalloutView {

    weak var delegate: MLNCalloutViewDelegate?
    
    var representedObject: MLNAnnotation = MLNPointAnnotation()
    var leftAccessoryView: UIView = UIView()
    var rightAccessoryView: UIView = UIView()
    
    // Move annotation when user move the map
    var isAnchoredToAnnotation = true
    
    // Dismiss the annotation when user move the map
    var dismissesAutomatically = false

    //MARK: Subviews -
    let titleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        return label
    }()

    let subtitleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 11.0)
        return label
    }()

    let imageView:UIImageView = {
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
//        titleLabel.backgroundColor = .clear
//        addSubview(titleLabel)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
           // setup this view's properties
       self.backgroundColor = UIColor.white

       // And their Subviews
       self.addSubview(titleLabel)
       self.addSubview(subtitleLabel)
       self.addSubview(imageView)

       // Add Constraints to subviews
       let spacing:CGFloat = 8.0

       imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: spacing).isActive = true
       imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: spacing).isActive = true
       imageView.heightAnchor.constraint(equalToConstant: 52.0).isActive = true
       imageView.widthAnchor.constraint(equalToConstant: 52.0).isActive = true

       titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: spacing).isActive = true
       titleLabel.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: spacing * 2).isActive = true
       titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -spacing).isActive = true
       titleLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

       subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: spacing).isActive = true
       subtitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: spacing).isActive = true
       subtitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -spacing).isActive = true
       subtitleLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
   }

    func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedRect: CGRect, animated: Bool) {
        if let delegate = delegate, delegate.responds(to: #selector(delegate.calloutViewWillAppear(_:))) {
            delegate.perform(#selector(delegate.calloutViewWillAppear(_:)), with: self)
        }
        self.center = view.center.applying(CGAffineTransform(translationX: 0, y: -self.frame.height))
        view.addSubview(self)
        imageView.image = UIImage(systemName: "car")!
        if let title = representedObject.title, let subTitle = representedObject.subtitle {
            titleLabel.text = title
            subtitleLabel.text = subTitle
        }
        
        let frameWidth = titleLabel.bounds.size.width
        let frameHeight = titleLabel.bounds.size.height * 2.0
        let frameOriginX = rect.origin.x + (rect.size.width/2.0) - (frameWidth/2.0)
        let frameOriginY = rect.origin.y - frameHeight
        frame = CGRect(x: frameOriginX, y: frameOriginY, width: 120, height: 80)

        if let delegate = delegate, delegate.responds(to: #selector(delegate.calloutViewDidAppear(_:))) {
            delegate.perform(#selector(delegate.calloutViewDidAppear(_:)), with: self)
        }
    }

    override var center: CGPoint {
        didSet {
            var newCenter = center
            newCenter.y -= bounds.midY
            super.center = newCenter
        }
    }
    
    func dismissCallout(animated: Bool) {
        if superview != nil {
                   removeFromSuperview()
               }
    }

    // MARK: - Internals

    override func draw(_ rect: CGRect) {
        let fillColor = UIColor.white
        let tipHeight: CGFloat = 10.0
        let tipWidth: CGFloat = 10.0

        let tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0)
        let tipBottom = CGPoint(x: rect.origin.x + (rect.size.width / 2.0), y: rect.origin.y + rect.size.height)
        let heightWithoutTip = rect.size.height - tipHeight

        let tipPath = UIBezierPath()
        tipPath.move(to: CGPoint(x: 0, y: 0))
        tipPath.addLine(to: CGPoint(x: 0, y: heightWithoutTip))
        tipPath.addLine(to: CGPoint(x: tipLeft, y: heightWithoutTip))
        tipPath.addLine(to: tipBottom)
        tipPath.addLine(to: CGPoint(x: tipLeft + tipWidth, y: heightWithoutTip))
        tipPath.addLine(to: CGPoint(x: rect.width, y: heightWithoutTip))
        tipPath.addLine(to: CGPoint(x: rect.width, y: 0))
        tipPath.close()
        
        fillColor.setFill()
        tipPath.fill()
    }
}
