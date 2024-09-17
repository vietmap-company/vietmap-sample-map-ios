import UIKit
import VietMap

class ViewController: UIViewController {
    @IBOutlet weak var showMiniMap: UIButton!
    @IBOutlet weak var zoomIn: UIButton!
    @IBOutlet weak var zoomOut: UIButton!
    @IBOutlet weak var showPolygon: UIButton!
    @IBOutlet weak var useCustomCallOut: UIButton!
    @IBOutlet weak var longPressHintView: UILabel!

    var mapView: MLNMapView!
    var coordinates: [CLLocationCoordinate2D] = []
    var polygon: MLNPolygon?
    
    var isShowPolygon: Bool = false
    var isShowMiniMap: Bool = false
    var isUseCustomCallOut: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _,_ in
                DispatchQueue.main.async {
                    CLLocationManager().requestWhenInUseAuthorization()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startMapView()
    }
    
    
    func startMapView() {
        mapView = MLNMapView(frame: view.bounds, styleURL: URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE"))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.compassView.compassVisibility = .visible

        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(tap:)))
        mapView.gestureRecognizers?.filter({ $0 is UILongPressGestureRecognizer }).forEach(longTap.require(toFail:))
        mapView.addGestureRecognizer(longTap)
        view.insertSubview(mapView, belowSubview: longPressHintView)
    }
    
    func drawPolyline() {
        let polyline = MLNPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        mapView.addAnnotation(polyline)
    }
    
    func drawPolygon() {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 10.745863, longitude: 106.655122),
            CLLocationCoordinate2D(latitude: 10.753557, longitude: 106.649735),
            CLLocationCoordinate2D(latitude: 10.765662, longitude: 106.681285),
            CLLocationCoordinate2D(latitude: 10.750961, longitude: 106.683948)
        ]
        polygon = MLNPolygon(coordinates: coordinates, count: UInt(coordinates.count))
        mapView.addAnnotation(polygon!)
    }
    
    // MARK: Gesture Recognizer Handlers
    @objc func didLongPress(tap: UILongPressGestureRecognizer) {
        guard let mapView = mapView else { return }
        if (coordinates.isEmpty) {
            coordinates.append((mapView.userLocation?.location?.coordinate)!)
        }
        let point = mapView.convert(tap.location(in: mapView), toCoordinateFrom: mapView)
        let annotation = MLNPointAnnotation()
        annotation.coordinate = point
        annotation.title = "Point"
        annotation.subtitle = "Subtitle point"
        coordinates.append(point)
        mapView.addAnnotation(annotation)
        drawPolyline()
    }
    
    // MARK: Action button
    @IBAction func zoomInPress(_ sender: Any) {
        let currentZoomLevel = mapView.zoomLevel
        let newZoomLevel = currentZoomLevel + 1
        mapView.setZoomLevel(newZoomLevel, animated: true)
    }

    @IBAction func zoomOutPress(_ sender: Any) {
        let currentZoomLevel = mapView.zoomLevel
        let newZoomLevel = currentZoomLevel - 1
        mapView.setZoomLevel(newZoomLevel, animated: true)
    }

    @IBAction func showMiniMapPress(_ sender: Any) {
        if isShowMiniMap {
            mapView.frame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height)
            mapView.center = view.center
            showMiniMap.setTitle("Show mini map", for: .normal)
            isShowMiniMap = false
        } else {
            mapView.frame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height * 0.5)
            mapView.center = view.center
            showMiniMap.setTitle("Show full-screen map", for: .normal)
            isShowMiniMap = true
        }
    }
    
    @IBAction func showPolygonPress(_ sender: Any) {
        if isShowPolygon {
            guard let polygon = self.polygon else {return}
            mapView.removeAnnotation(polygon)
            showPolygon.setTitle("Show polygon", for: .normal)
            isShowPolygon = false
        } else {
            drawPolygon()
            isShowPolygon = true
            showPolygon.setTitle("Hide polygon", for: .normal)
        }
    }

    @IBAction func useCustomCallOutPress(_ sender: Any) {
        if isUseCustomCallOut {
            useCustomCallOut.setTitle("Use custom information view", for: .normal)
            isUseCustomCallOut = false
        } else {
            useCustomCallOut.setTitle("Use default information view", for: .normal)
            isUseCustomCallOut = true
        }
    }
}

extension ViewController: MLNMapViewDelegate {
    // MARK: Custom marker
    func mapView(_ mapView: MLNMapView, imageFor annotation: MLNAnnotation) -> MLNAnnotationImage? {
        let image = UIImage(systemName: "car")!
        image.withTintColor(UIColor.red)
        let annotationImage = MLNAnnotationImage(image: image, reuseIdentifier: "customAnnotation")

        return annotationImage
    }
    
    // MARK: Enable show tooltip with marker
    func mapView(_ mapView: MLNMapView, annotationCanShowCallout annotation: MLNAnnotation) -> Bool {
        return true
    }
    
    // MARK: Layout left on tooltip with marker
    func mapView(_ mapView: MLNMapView, leftCalloutAccessoryViewFor annotation: MLNAnnotation) -> UIView? {
        let button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(leftButtonTapped(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }
    
    @objc func leftButtonTapped(_ sender: UIButton) {
        print("Left button tapped")
    }

    // MARK: Layout right on tooltip with marker
    func mapView(_ mapView: MLNMapView, rightCalloutAccessoryViewFor annotation: MLNAnnotation) -> UIView? {
        let button = UIButton(type: .close)
        button.addTarget(self, action: #selector(rightButtonTapped(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }
    
    @objc func rightButtonTapped(_ sender: UIButton) {
        print("right layout")
    }
    
    // MARK: Fill Color in polygon
    func mapView(_ mapView: MLNMapView, fillColorForPolygonAnnotation annotation: MLNPolygon) -> UIColor {
        return UIColor.red.withAlphaComponent(0.5)
    }
    
    // MARK: Tap on tooltip
    func mapView(_ mapView: MLNMapView, tapOnCalloutFor annotation: MLNAnnotation) {
        print("tap on call out")
    }
    
    // MARK: Custom UIView of tooltip
    func mapView(_ mapView: MLNMapView, calloutViewFor annotation: MLNAnnotation) -> MLNCalloutView? {
        if !isUseCustomCallOut {
            return nil
        }
        let calloutView = CustomCalloutView()
        calloutView.representedObject = annotation
        return calloutView
    }
    
}

