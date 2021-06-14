//
//  WelcomeViewController.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 04/04/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6
        button.setTitle("SignIn with Spotify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
        
    }()
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "artwork")
        return imageView
    }()
    private let logoImageView: UIImageView = {
       let logoImage = UIImageView(image: UIImage(named: "Logo"))
        logoImage.contentMode = .scaleAspectFit
        return logoImage
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.text = "Spotify Clone\nDeveloped by Raghava Codes"
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spotify"
        view.addSubview(imageView)
        view.addSubview(overlayView)
        view.backgroundColor = .systemGreen
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        view.addSubview(label)
        view.addSubview(logoImageView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
        overlayView.frame = view.bounds
        signInButton.frame = CGRect(x: 20,
                                    y: view.height-50-view.safeAreaInsets.bottom,
                                    width: view.width-40,
                                    height: 50)
        logoImageView.frame = CGRect(x: (view.width-120)/2, y: (view.height-200)/2, width: 120, height: 120)
        label.frame = CGRect(x: 30, y: logoImageView.bottom+30, width: view.width-60, height: 150)
    }
    
    @objc func didTapSignIn(){
        let vc = AuthViewController()
        vc.completionHandler = {[weak self]success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    private func handleSignIn(success: Bool){
    //Log user in or log error if didn't log in
        guard success else {
            let alert = UIAlertController(title: "Oops",
                                          message: "Something went wrong when signingIn",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC,animated: true)
    }
}
