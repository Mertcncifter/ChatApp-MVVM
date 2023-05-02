//
//  MainTabViewController.swift
//  ChatApp
//
//  Created by mert can çifter on 18.04.2023.
//

import UIKit

class MainTabViewController: UITabBarController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureUI()
    }
    
    
    // MARK: - Helpers


    func configureUI(){
        configureTabBarAppereance()
        configureViewControllers()
    }
    
    
    func configureTabBarAppereance(){
        let appearance = UITabBarAppearance()
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemGroupedBackground
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
            tabBar.tintColor = .label
        }
        else{
            tabBar.standardAppearance = appearance
            tabBar.tintColor = .label
        }
    }
    
    func configureViewControllers(){
        let vc1 = templateNavigationController(rootViewController: ChatHomeViewController(), image: UIImage(systemName: "bubble.left"), title: "Chat")
        let vc2 = templateNavigationController(rootViewController: ProfileViewController(), image: UIImage(systemName: "person"), title: "Profil")
  
        setViewControllers([vc1,vc2], animated: true)
        
    }
    
    func templateNavigationController(rootViewController : UIViewController,image : UIImage?,title: String?) -> UIViewController {
        rootViewController.tabBarItem.image = image
        rootViewController.tabBarItem.title = title
        return rootViewController
    }
    

  
}
