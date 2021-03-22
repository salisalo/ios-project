//
//  ExtensionsHelper.swift
//  TvShows
//
//  Created by Salo Antidze on 3/14/21.
//

import UIKit

extension UIImageView {
    
    private var activityIndicator: UIActivityIndicatorView {
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        activityIndicator.center = self.center
        self.addSubview(activityIndicator)
        
        return activityIndicator
    }
   
    func setImageFrom(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let activityIndicator = self.activityIndicator
        
        DispatchQueue.main.async {
            activityIndicator.startAnimating()
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let imageData = data {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    let image = UIImage(data: imageData)
                    self.image = image
                }
            }
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
            
        }
        task.resume()
    }
    
}
