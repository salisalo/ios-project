//
//  TabBarViewController.swift
//  TvShows
//
//  Created by Salo Antidze on 3/23/21.
//

import UIKit
import Firebase

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUserAuth()
        
    }
    
    
    func checkUserAuth() {
        
        
        let isLogginIn = Firebase.Auth.auth().currentUser == nil ? false : true
        let identifier = isLogginIn ? "ProfileNavigationViewController" : "NavigationViewController"
        
        guard let vc = storyboard?.instantiateViewController(identifier: identifier)
        else { return }
        
        guard let firstTabVc = self.viewControllers?[0]
        else { return }
        
        self.setViewControllers([firstTabVc, vc], animated: false)
        vc.tabBarItem.image = UIImage(systemName: "person.circle")
        
        let title = isLogginIn ? "Profile" : "Sign In"
        vc.tabBarItem.title = title

    }
    
}
