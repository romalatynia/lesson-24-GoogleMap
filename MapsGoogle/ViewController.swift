//
//  ViewController.swift
//  MapsGoogle
//
//  Created by Roma Latynia on 3/18/21.
//

import GoogleMaps
import UIKit

private enum Constants {
    static let tagSize = 30
    static let infoListSize = 300
    static let latitude = 52.0975500
    static let longitude = 23.6877500
    static let numberOfPiopleFrameLabelX = 185
    static let helpValue = 10
    static let frameLabelY8km = 60
    static let frameLabelY15km = 110
    static let numberOfPiopleFrameLabelWidth = 25
    static let frameLabelX = 5
    static let frameLabelWidth = 180
    static let frameLabelHeight = 17
    static let textLabel = "0"
    static let smallRadius: CLLocationDistance = 3000
    static let middleRadius: CLLocationDistance = 8000
    static let bigRadius: CLLocationDistance = 15000
    static let unitsInside3000m = "Units inside 3000 m:"
    static let unitsInside8000m = "Units inside 8000 m:"
    static let unitsInside15000m = "Units inside 15000 m:"
    static let frameViewY = 100
    static let frameViewWidth = 215
    static let frameViewHeight = 150
    static let line: CGFloat = 5.0
}

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak private var mapView: GMSMapView!
    private let arrayStudents = Model.createStudents()
    private var venue: Venue?
    private var sourceView = UIView()
    private var circle1 = GMSCircle()
    private var circle2 = GMSCircle()
    private var circle3 = GMSCircle()
    private let numberOfPeopleWithin3kmLabel: UILabel = {
        let label = UILabel(
            frame: CGRect(
                x: Constants.numberOfPiopleFrameLabelX,
                y: Constants.helpValue,
                width: Constants.numberOfPiopleFrameLabelWidth,
                height: Constants.frameLabelHeight
            )
        )
        label.text = Constants.textLabel
        return label
    }()
    
    private let numberOfPeopleWithin8kmLabel: UILabel = {
        let label = UILabel(
            frame: CGRect(
                x: Constants.numberOfPiopleFrameLabelX,
                y: Constants.frameLabelY8km,
                width: Constants.numberOfPiopleFrameLabelWidth,
                height: Constants.frameLabelHeight
            )
        )
        label.text = Constants.textLabel
        return label
    }()
    
    private let numberOfPeopleWithin15kmLabel: UILabel = {
        let label = UILabel(
            frame: CGRect(
                x: Constants.numberOfPiopleFrameLabelX,
                y: Constants.frameLabelY15km,
                width: Constants.numberOfPiopleFrameLabelWidth,
                height: Constants.frameLabelHeight
            )
        )
        label.text = Constants.textLabel
        return label
    }()
    
    lazy var informationBoard: UIView = {
        let view = UIView(
            frame: CGRect(
                x: Constants.helpValue,
                y: Constants.frameViewY,
                width: Constants.frameViewWidth,
                height: Constants.frameViewHeight
            )
        )
        view.backgroundColor = UIColor(displayP3Red: 0.5543, green: 0.75467, blue: 0.3446, alpha: 0.7)
        let label1 = UILabel(
            frame: CGRect(
                x: Constants.frameLabelX,
                y: Constants.helpValue,
                width: Constants.frameLabelWidth,
                height: Constants.frameLabelHeight
            )
        )
        label1.text = Constants.unitsInside3000m
        let label2 = UILabel(
            frame: CGRect(
                x: Constants.frameLabelX,
                y: Constants.frameLabelY8km,
                width: Constants.frameLabelWidth,
                height: Constants.frameLabelHeight
            )
        )
        label2.text = Constants.unitsInside8000m
        let label3 = UILabel(
            frame: CGRect(
                x: Constants.frameLabelX,
                y: Constants.frameLabelY15km,
                width: Constants.frameLabelWidth,
                height: Constants.frameLabelHeight
            )
        )
        label3.text = Constants.unitsInside15000m
        
        [
            label1,
            label2,
            label3,
            numberOfPeopleWithin3kmLabel,
            numberOfPeopleWithin8kmLabel,
            numberOfPeopleWithin15kmLabel
        ].forEach({view.addSubview($0)})
        
        return view
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBarButton()
        createMap()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
    
    private func createBarButton() {
        let addStudents = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        let addVenue = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVenueAction))
        let pathButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(pathButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = addStudents
        navigationItem.leftBarButtonItems = [addVenue, pathButton]
    }
    
    private func createMap() {
        mapView.delegate = self
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.camera = GMSCameraPosition(
            latitude: Constants.latitude,
            longitude: Constants.longitude,
            zoom: Float(Constants.helpValue)
        )
    }
    
    private func refreshTitlesInInformationBar() {
        guard let meetup = venue else { return }
        meetup.devideStudentsACcordingToDistanse(students: arrayStudents)
        numberOfPeopleWithin3kmLabel.text = "\(meetup.nearestStudents.count)"
        numberOfPeopleWithin8kmLabel.text = "\(meetup.middleStudents.count)"
        numberOfPeopleWithin15kmLabel.text = "\(meetup.largeStudents.count)"
    }
    
    private func randomCoordinate() -> CLLocationCoordinate2D {
        let randomLatitude = Double.random(in: -0.1...0.1)
        let randomLongitude = Double.random(in: -0.1...0.1)
        let coordinate = CLLocationCoordinate2D(
            latitude: Constants.latitude + randomLatitude,
            longitude: Constants.longitude + randomLongitude
        )
        
        return coordinate
    }
    
    private func showCircles(position: CLLocationCoordinate2D) {
        circle1 = GMSCircle(position: position, radius: Constants.smallRadius)
        circle1.map = mapView
        circle2 = GMSCircle(position: position, radius: Constants.middleRadius)
        circle2.map = mapView
        circle3 = GMSCircle(position: position, radius: Constants.bigRadius)
        circle3.map = mapView
    }
    
    private func drawPolyline(mark: Student) {
        let coordinate1 = circle1.position
        let coordinate2 = mark.coordinate
        let path = GMSMutablePath()
        path.add(coordinate2)
        path.add(coordinate1)
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .random
        polyline.strokeWidth = Constants.line
        polyline.map = mapView
    }
    
    @objc private func addAction() {
        for user in arrayStudents {
            let marker = GMSMarker(position: user.coordinate)
            marker.title = "\(user.name) \(user.lastName)"
            marker.snippet = user.dateOfBirth
            let imageView = UIImageView()
            if user.gender == "мужской" {
                imageView.image = UIImage(named: "man")
            } else {
                imageView.image = UIImage(named: "woman")
            }
            imageView.frame.size = CGSize(width: Constants.tagSize, height: Constants.tagSize)
            marker.iconView = imageView
            marker.userData = user
            marker.map = mapView
        }
    }
    
    @objc private func addVenueAction() {
        venue = Venue(coordinate: randomCoordinate())
        guard let meetup = venue else { return }
        view.addSubview(informationBoard)
        showCircles(position: meetup.coordinate)
        let marker = GMSMarker(position: meetup.coordinate)
        marker.title = "место встречи студентов"
        marker.snippet = ""
        marker.isDraggable = true
        marker.map = mapView
        refreshTitlesInInformationBar()
    }
    
    @objc private func pathButtonPressed(sender: UIBarButtonItem) {
        let random = Int.random(in: 0..<100)
        guard let meetup = venue else { return }
        meetup.devideStudentsACcordingToDistanse(students: arrayStudents)
        meetup.nearestStudents.forEach { $0.meetingState = random < 90 ? true : false
            if $0.meetingState {
                drawPolyline(mark: $0)
            }
        }
        meetup.middleStudents.forEach { $0.meetingState = random < 50 ? true : false
            if $0.meetingState {
                drawPolyline(mark: $0)
            }
        }
        meetup.largeStudents.forEach { $0.meetingState = random < 10 ? true : false
            if $0.meetingState {
                drawPolyline(mark: $0)
            }
        }
    }
}

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let location = marker.accessibilityActivationPoint
        self.sourceView = UIView(frame: CGRect(x: location.x, y: location.y, width: 1, height: 1))
        self.view.addSubview(self.sourceView)
        guard let student = marker.userData as? Student else { return false }
        let studentPopover = StudentInformationViewController(student: student)
        let popController = studentPopover
        popController.modalPresentationStyle = .popover
        popController.preferredContentSize = CGSize(width: Constants.infoListSize, height: Constants.infoListSize)
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = self.sourceView
        self.present(popController, animated: true)
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        mapView.clear()
        addAction()
        marker.map = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        venue = Venue(coordinate: marker.position)
        refreshTitlesInInformationBar()
        showCircles(position: marker.position)
    }
}

extension UIColor {
    static var random: UIColor {
        UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
