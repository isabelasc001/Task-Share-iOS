//
//  LandingPageViewViewController.swift
//  Task Share
//
//  Created by Isabela S Cardoso on 05/03/26.
//

import UIKit

class LandingPageViewController: UIViewController {
    
    let landingView = LandingPageView()

    override func loadView() {
        view = landingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        landingView.continueButton.addTarget(self, action: #selector(navigateToHome), for: .touchUpInside)
    }
    
    init() {
            super.init(nibName: nil, bundle: nil)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func navigateToHome() {
        let nav = HomeViewController()
        navigationController?.pushViewController(nav, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
