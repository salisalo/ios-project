//
//  ProfileViewController.swift
//  TvShows
//
//  Created by Salo Antidze on 3/23/21.
//

import UIKit
import Firebase
import JGProgressHUD

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    @IBOutlet weak var noFavoritesLabel: UILabel!
    
    @IBOutlet weak var tvShowsTableView: UITableView!
    private let spinner = JGProgressHUD(style: .dark)
    
    var tvShowsList: [TvShowInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageview.contentMode = UIView.ContentMode.scaleAspectFit
        imageview.layer.cornerRadius = imageview.frame.width / 2
        imageview.layer.masksToBounds = true
        containView.addSubview(imageview)
        let rightBarButton = UIBarButtonItem(customView: containView)
        self.navigationItem.leftBarButtonItem = rightBarButton
        
        getProfilePicture(imageView: imageview)
        
        self.navigationItem.title =  UserDefaults.standard.value(forKey: "email") as? String
        
        
        tvShowsTableView.dataSource = self
        tvShowsTableView.delegate = self
        
        getFavoriteTvShows()
    }
    
    
    @IBAction func signOutButtonClicked(_ sender: Any) {
        let actionSheet = UIAlertController(title: "",
                                            message: "",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Sign Out",
                                            style: .destructive,
                                            handler: { [weak self] _ in
                                                guard let self = self else { return }
                                
                                                do {
                                                    try Firebase.Auth.auth().signOut()
                                                    UserDefaults.standard.setValue(nil, forKey: "email")
                                                    UserDefaults.standard.setValue(nil, forKey: "name")
                                                    UserDefaults.standard.setValue(nil, forKey: "profile_picture_url")
                                                    
                                                    //                                                    guard let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController")
                                                    //                                                    else {
                                                    //                                                        return
                                                    //                                                    }
                                                    //                                                    vc.modalPresentationStyle = .fullScreen
                                                    //                                                    self.present(vc, animated: true, completion: nil)
                                                    guard let vc = self.storyboard?.instantiateViewController(identifier: "NavigationViewController")
                                                    else { return }
                                                    
                                                    guard let firstTabVc = self.tabBarController?.viewControllers?[0]
                                                    else { return }
                                                    
                                                    self.tabBarController?.setViewControllers([firstTabVc, vc], animated: false)
                                                    vc.tabBarItem.image = UIImage(systemName: "person.circle")
                                                    vc.tabBarItem.title = "Sign In"
                                                }
                                                catch {
                                                    
                                                }
                                                
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    
    func getFavoriteTvShows() {
        spinner.show(in: view)
        noFavoritesLabel.isHidden = false
        tvShowsTableView.isHidden = true
        tvShowsList = []
        
        DbManager.shared.getAllFavorites { (result, error) in

            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            if let tvShows = result {
                var shouldHide = false
                if !tvShows.isEmpty {
                    self.tvShowsList = tvShows
                    shouldHide = false
                }
                else {
                        shouldHide = true
                }
                DispatchQueue.main.async {
                    self.noFavoritesLabel.isHidden = !shouldHide
                    self.tvShowsTableView.isHidden = shouldHide
                    self.tvShowsTableView.reloadData()
                }            }

        }
    }
    
    func getProfilePicture(imageView: UIImageView) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let downloadUrl = UserDefaults.standard.value(forKey: "profile_picture_url") as? String {
            imageView.setImageFrom(downloadUrl)
        }
        
        else {
            let editedEmail = DbManager.getEditedEmail(email: email)
            let filename = editedEmail + "_profile_picture.png"
            let path = "images/"+filename
            
            StorageManager.shared.downloadURL(for: path) { (url, error) in
                if let url = url {
                    imageView.setImageFrom(url)
                }
                else {
                    imageView.image = UIImage(systemName: "person.circle")
                }
            }
        }
        
    }
    
}

extension ProfileViewController : UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvShowsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TvShowsTableViewCell
        else { return UITableViewCell() }
        
        let tvShow = tvShowsList[indexPath.row]
        cell.configureCell(tvShow: tvShow)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Remove", handler: { (action, view, completionHandler) in
            
            DbManager.shared.deleteFromFavorites(self.tvShowsList[indexPath.row].id) { (result) in
            }
            
            self.tvShowsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            
            completionHandler(true)
        })
        
        action.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [action])
   
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
}
