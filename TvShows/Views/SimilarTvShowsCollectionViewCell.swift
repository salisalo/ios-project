//
//  SimilarTvShowsCollectionViewCell.swift
//  TvShows
//
//  Created by Salo Antidze on 3/12/21.
//

import UIKit

class SimilarTvShowsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tvShowPosterImageView: UIImageView!
    @IBOutlet weak var tvShowNameLabel: UILabel!
    @IBOutlet weak var tvShowRatingLabel: UILabel!
    @IBOutlet weak var tvShowYearLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(tvShow: TvShowInfo) {
        cellView.layer.cornerRadius = 8
        cellView.clipsToBounds = true
        
        tvShowNameLabel.text = tvShow.name
        tvShowRatingLabel.text = String(tvShow.vote_average)
        
        if let firstAirDate = tvShow.first_air_date {
            tvShowYearLabel.text = String(firstAirDate.prefix(4))
        }
        else {
            tvShowYearLabel.text = ""
        }
        
        if let posterPath = tvShow.poster_path {
            tvShowPosterImageView.setImageFrom(NetworkManager.shared.posterBaseUrl + posterPath)
        }
        else {
            tvShowPosterImageView.image = UIImage(systemName: "nosign")
        }
    }

}
