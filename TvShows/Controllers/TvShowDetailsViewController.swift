//
//  TvShowDetailsViewController.swift
//  TvShows
//
//  Created by Salo Antidze on 3/12/21.
//

import UIKit

class TvShowDetailsViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tvShowPosterImageView: UIImageView!
    @IBOutlet weak var tvShowNameLabel: UILabel!
    @IBOutlet weak var tvShowDateLabel: UILabel!
    @IBOutlet weak var tvShowGenresLabel: UILabel!
    @IBOutlet weak var tvShowRatingLabel: UILabel!
    @IBOutlet weak var tvShowRatingCountLabel: UILabel!
    @IBOutlet weak var tvShowDescriptionLabel: UILabel!
    @IBOutlet weak var similarTvShowsCollectionView: UICollectionView!
    @IBOutlet weak var similarTVShowsStackView: UIStackView!
    
    var tvShow: TvShowInfo? = nil
    var similarTvShows = [TvShowInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        fillData(tvShow: tvShow)
        
    }
    
    func configure() {
        similarTvShowsCollectionView.register(UINib(nibName: "SimilarTvShowsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TvShowCell")
        
        similarTvShowsCollectionView.dataSource = self
        similarTvShowsCollectionView.delegate = self
        
        let layout = similarTvShowsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.minimumInteritemSpacing = 0
        
        similarTvShowsCollectionView.showsHorizontalScrollIndicator = false
        
        navigationController?.isNavigationBarHidden = false
    }
    
    func fillData(tvShow: TvShowInfo?) {
        guard let tvShow = tvShow else { return }
        tvShowNameLabel.text = tvShow.name
        tvShowDateLabel.text = tvShow.first_air_date ?? ""
        tvShowRatingLabel.text = String(tvShow.vote_average)
        tvShowDescriptionLabel.text = tvShow.overview
        tvShowRatingCountLabel.text = "(\(String(tvShow.vote_count)))"
        
        getGenres(tvShowGenreIds: tvShow.genre_ids)
        
        if let posterPath = tvShow.poster_path {
            tvShowPosterImageView.setImageFrom(NetworkManager.shared.largePosterBaseUrl + posterPath)
        }
        else {
            tvShowPosterImageView.image = UIImage(systemName: "nosign")
        }
        
        getData(id: tvShow.id)
    }
    
    func getGenres(tvShowGenreIds: [Int]) {
        NetworkManager.shared.getGenres { (result, error) in
            if let error = error {
                print(error)
            }
            if let genres = result {
                DispatchQueue.main.async {
                    var genresList = [String]()
                    tvShowGenreIds.forEach { id in
                        let genre = genres.filter { $0.id == id }.first
                        if let name = genre?.name {
                            genresList.append(name)
                        }
                    }
                    self.tvShowGenresLabel.text = genresList.joined(separator: ",")
                }
            }
        }
    }
    
    func getData(id: Int) {
        self.similarTVShowsStackView.isHidden = true
        similarTvShows = []
        NetworkManager.shared.getSimilarTvShows(tvShowsId: id, completionHandler: { [weak self] ( result, error )   in
            guard let self = self else { return }
            
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Something went wrong while loading tv shows")
                }
            }
            
            if let similarTVShows = result {
                if !similarTVShows.isEmpty {
                    self.similarTvShows = similarTVShows
                    DispatchQueue.main.async {
                        self.similarTVShowsStackView.isHidden = false
                        self.similarTvShowsCollectionView.reloadData()
                    }
                }
            }
        })
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension TvShowDetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        similarTvShows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TvShowCell", for: indexPath) as? SimilarTvShowsCollectionViewCell
        else { return UICollectionViewCell() }
        
        let tvShow = similarTvShows[indexPath.row]
        
        cell.configureCell(tvShow: tvShow)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tvShow = similarTvShows[indexPath.row]
        
        fillData(tvShow: tvShow)
    }
}
