//
//  RegionsTableViewCell.swift
//  Map_Downloader_2
//
//  Created by Ihor YERIN on 11/9/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit

class RegionsTableViewCell: UITableViewCell {

    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var regionName: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var download: UIImageView!
    
    var downloadOperation: DownloadOperation?  {
        didSet {
            if let _ = downloadOperation {
                setOperationCallbacks()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mapImage.image = UIImage(named: "ic_custom_show_on_map")
        isUserInteractionEnabled = true
        contentView.alpha = 1
        //download.image = UIImage(named: "ic_custom_import")
    }
    
    private func setOperationCallbacks() {
        downloadOperation?.progressCallback = { [weak self] progress in
            DispatchQueue.main.async {
                self?.progress.isHidden = false
                self?.progress.progress = progress
            }
        }
        downloadOperation?.didFinishDownloadCallback = { [weak self] in
            DispatchQueue.main.async {
                self?.mapImage.image = UIImage(named: "green_map")
                self?.progress.isHidden = true
                self?.isUserInteractionEnabled = false
                self?.download.image = UIImage()
            }
        }
    }
}
