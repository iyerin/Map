//
//  ViewController.swift
//  Map_Downloader_2
//
//  Created by Ihor YERIN on 11/8/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit

/*
 TODO:
 -  - gb if < 0
 - okruglenie free space

 - google callback
 - map where no maps
 */

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var regions: [Region] = []
    var index = Int()
    private var myTableView: UITableView!
    var newRegions: [Region] = []
    var cell: RegionsTableViewCell?
    let downloadManager = DownloadManager()
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasSubregions(regions: regions, name: newRegions[indexPath.row].name) {
            guard let index = regions.index(of: newRegions[indexPath.row]) else { return }
            showSubregions(regions: regions, index: index)
        } else {
            self.cell = self.myTableView.cellForRow(at: indexPath) as? RegionsTableViewCell
            guard let url = URL(string: newRegions[indexPath.row].link) else { return }
            let operation = downloadManager.queueDownload(url)
            cell?.downloadOperation = operation

            //download(region: newRegions[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newRegions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionsTableViewCell") as! RegionsTableViewCell
        //let cell = tableView.dequeueReusableCell(withIdentifier: "RegionsTableViewCell", for: indexPath as IndexPath)
        cell.regionName.text = newRegions[indexPath.row].name
        cell.mapImage.image = UIImage(named: "ic_custom_show_on_map")
        cell.progress.isHidden = true
        cell.selectionStyle = .none
        
        if hasSubregions(regions: regions, name: newRegions[indexPath.row].name) {
            cell.download.image = UIImage(named: "right_arrow")
        } else {
            cell.download.image = UIImage(named: "ic_custom_import")
        }
        if MapsFileManager.isDownloaded(link: regions[regions.index(of: newRegions[indexPath.row])!].link) {
            cell.mapImage.image = UIImage(named: "green_map")
            cell.isUserInteractionEnabled = false
            cell.contentView.alpha = 0.5
            //image:grey
        }
        return cell
    }
    
    // MARK: - My functions
    
    func showSubregions(regions: [Region], index: Int) {
        let subregionsVC = FirstViewController()
        subregionsVC.regions = regions
        subregionsVC.index = index
        self.navigationController?.pushViewController(subregionsVC, animated:true)
    }
    
    func hasSubregions(regions: [Region], name: String) -> Bool {
        let filteredRegions = regions.filter {$0.parent == name}
        if filteredRegions.isEmpty == true {
            return false
        }
        return true
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        for region in regions {
//            print (region.name, region.parent)
//        }
        newRegions = regions.filter { $0.parent == regions[index].name }
        newRegions = newRegions.sorted { $0.name < $1.name }
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        //myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "RegionsTableViewCell")
        myTableView.register(UINib(nibName: "RegionsTableViewCell", bundle: nil), forCellReuseIdentifier: "RegionsTableViewCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.tableFooterView = UIView()
        self.view.addSubview(myTableView)
        
//        storageView = UIView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: 50))
//        leftLabel = UILabel(frame: <#T##CGRect#>)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        myTableView.reloadData()
    }
}

    // MARK: - Download

extension FirstViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(documentsPath)
        let str:String = url.absoluteString
        var startIndex = str.index(of: ":")!
        let upperCase = CharacterSet.uppercaseLetters
        for currentCharacter in str.unicodeScalars {
            if upperCase.contains(currentCharacter) {
                startIndex = str.index(of: Character(currentCharacter))!
                break
            }
        }
        let name = String(str[startIndex...])
        let destinationURL = documentsPath.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: destinationURL)
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
        DispatchQueue.main.async() {
//            var i = 0
//            for country in self.countries {
//                if country.name == self.countryCell?.countryName.text {
//                    break
//                }
//                i += 1
//            }
//            self.countries[i].downloaded = true
            self.cell?.progress.isHidden = true
            self.myTableView.reloadData()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async() {
            self.cell?.progress.progress = progress
        }
    }
    
    func download(region: Region) {
        guard let url = URL(string: region.link) else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let task = urlSession.downloadTask(with: url)
        task.resume()
        
        cell?.progress.progress = 0
        cell?.progress.isHidden = false
    }
}

