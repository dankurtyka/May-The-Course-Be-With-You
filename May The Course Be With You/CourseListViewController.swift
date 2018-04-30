//
//  ViewController.swift
//  May The Course Be With You
//
//  Created by Daniel Kurtyka on 4/29/18.
//  Copyright © 2018 Daniel Kurtyka. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

var courses = [Course]()

class CourseListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        
//        courses.append(Course(name: "Augusta", address: "Washington St", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, notes: "Great Course"))
//        courses.append(Course(name: "Pebble Beach", address: "Mile Dr", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, notes: "Nice course but terrible weather."))
//        courses.append(Course(name: "Bethpage", address: "Quaker Meeting House Rd", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, notes: "played amazing here, come back ASAP!"))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
        signIn()
    }
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            print("*** ERROR: No identifier for segue in prepare for esgue in CourseListViewController.swift")
            return
        }
        switch identifier {
        case "ShowCourse":
            let destination = segue.destination as! CourseDetailViewController
            let selectedRow = tableView.indexPathForSelectedRow!.row
            destination.courseInt = selectedRow
        case "AddCourse":
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        default:
            print("*** ERROR: prepare for segue in CourseListViewController.swift did not have an identifier")
        }
    }
    
    @IBAction func unwindFromCourseDetail(segue: UIStoryboardSegue) {
        if segue.identifier! == "AddNewCourse" {
            let source = segue.source as! CourseDetailViewController
            let newIndexPath = IndexPath(row: courses.count, section: 0)
            courses.append(source.course)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
            
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            signIn()
        } catch {
            tableView.isHidden = true
            print("ERROR: Couldn't sign out")
        }
        
    }
    

}

extension CourseListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = courses[indexPath.row].name
        cell.detailTextLabel?.text = courses[indexPath.row].address
        return cell
    }
}

extension CourseListViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            tableView.isHidden = false
            print("*** We signed in with the user \(user.email ?? "unknown email")")
        }
    }
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor.white
        
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        
        return loginViewController
    }
}

