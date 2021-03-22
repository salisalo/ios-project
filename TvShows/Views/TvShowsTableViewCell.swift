//
//  TvShowsTableViewCell.swift
//  TvShows
//
//  Created by Salo Antidze on 3/10/21.
//

import UIKit

class TvShowsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tvShowAvatar: UIImageView!
    @IBOutlet weak var tvShowTitle: UILabel!
    @IBOutlet weak var tvShowRating: UILabel!
    @IBOutlet weak var tvShowProdYear: UILabel!
    @IBOutlet weak var tvShowCountry: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(tvShow: TvShowInfo) {
        tvShowAvatar.image = nil
        tvShowTitle.text = tvShow.name
        tvShowRating.text = String(tvShow.vote_average)
        
        if let firstAirDate = tvShow.first_air_date {
        tvShowProdYear.text = String(firstAirDate.prefix(4))
        }
        else {
            tvShowProdYear.text = ""
        }
        if tvShow.origin_country.count != 0 {
            tvShowCountry.text = tvShow.origin_country[0]
        }
        else {
            tvShowCountry.text = ""
        }
        
        if let posterPath = tvShow.poster_path {
            tvShowAvatar.setImageFrom(NetworkManager.shared.posterBaseUrl + posterPath)
        }
        else {
            tvShowAvatar.image = UIImage(systemName: "nosign")
        }
    }

}
