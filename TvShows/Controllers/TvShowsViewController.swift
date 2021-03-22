//
//  ViewController.swift
//  TvShows
//
//  Created by Salo Antidze on 3/10/21.
//

import UIKit

class TvShowsViewController: UIViewController {
    
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tvShowsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var tvShowsList = [TvShowInfo]()
    var isSearchOn: Bool = false
    var page = 1
    var searchPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControls()
        
        tvShowsTableView.dataSource = self
        tvShowsTableView.delegate = self
        
        getTvShows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    func setupControls() {
        searchTextField.layer.cornerRadius = 8
        searchTextField.clipsToBounds = true
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 33, height: 25))
        let imageView = UIImageView(frame: CGRect(x: 8, y: 0, width: 25, height: 25))
        
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .gray
        imageView.contentMode = .center
        
        containerView.addSubview(imageView)
        
        searchTextField.leftView = containerView
        searchTextField.leftViewMode = .always
        
        searchTextField.overrideUserInterfaceStyle = .light
        
        tvShowsTableView.keyboardDismissMode = .onDrag
        tvShowsTableView.isHidden = true
        
    }
    
    @IBAction func searchTextFieldDidChange(_ sender: Any) {
        if let searchKeyword = searchTextField.text {
            searchPage = 1
            if searchKeyword.isEmpty {
                isSearchOn = false
                page = 1
                getTvShows()
            }
            else {
                isSearchOn = true
                searchTvShows()
            }
        }
    }
    
    func searchTvShows() {
        loadingActivityIndicator.startAnimating()
        noResultLabel.isHidden = true
        if searchPage == 1 {
            tvShowsList = []
        }
        
        guard let searchKeyword = searchTextField.text else { return }
        
        NetworkManager.shared.searchTvShows(searchPage: searchPage, tvShowKeyword: searchKeyword, completionHandler: { [weak self] ( result, error )  in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingActivityIndicator.stopAnimating()
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Something went wrong while loading tv shows")
                }
            }
            if let tvShows = result {
                self.reloadTableViewData(&self.searchPage, tvShows)
            }
        })
    }
    
    func getTvShows() {
        loadingActivityIndicator.startAnimating()
        noResultLabel.isHidden = true
        if page == 1 {
            tvShowsList = []
        }
        NetworkManager.shared.getTvShowsInfo(page: page, completionHandler: { [weak self] ( result, error )  in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadingActivityIndicator.stopAnimating()
            }
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Something went wrong while loading tv shows")
                }
            }
            
            if let tvShows = result {
                self.reloadTableViewData(&self.page, tvShows)
            }
        })
    }
    
    func reloadTableViewData(_ page: inout Int, _ tvShows: [TvShowInfo]) {
        var shouldHide = false
        if !tvShows.isEmpty {
            self.tvShowsList.append(contentsOf: tvShows)
            shouldHide = false
            page += 1
        }
        else {
            if page == 1 {
                shouldHide = true
            }
        }
        DispatchQueue.main.async {
            self.noResultLabel.isHidden = !shouldHide
            self.tvShowsTableView.isHidden = shouldHide
            self.tvShowsTableView.reloadData()
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}


extension TvShowsViewController : UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
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
        
        guard let vc = storyboard?.instantiateViewController(identifier: "TvShowDetails") as? TvShowDetailsViewController
        else { return }
        
        let tvShow = tvShowsList[indexPath.row]
        vc.tvShow = tvShow
        splitViewController?.showDetailViewController(vc, sender: self)
    }
    
    func setupFooterView() -> UIView {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPosition = scrollView.contentOffset.y
        //if currentPosition > tvShowsTableView.contentSize.height - scrollView.frame.size.height - 100 {
        if (currentPosition >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            
            if !NetworkManager.shared.isPaginationInProgress {
                self.tvShowsTableView.tableFooterView = setupFooterView()
                if isSearchOn {
                    searchTvShows()
                }
                else {
                    self.getTvShows()
                }
                self.tvShowsTableView.tableFooterView = nil
            }
        }
    }    
    
}

extension TvShowsViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchTvShows()
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.isHidden = true
        return true
    }
}




