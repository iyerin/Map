//
//  ViewController.swift
//  Map_Downloader_2
//
//  Created by Ihor YERIN on 11/8/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var regions: [Region] = []
    var index = Int()
    private var myTableView: UITableView!
    var newRegions: [Region] = []
    var cell: RegionsTableViewCell?
    let downloadManager = DownloadManager()
    var headerText: String?
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (headerText)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < newRegions.count {
            if hasSubregions(regions: regions, name: newRegions[indexPath.row].name) {
                guard let index = regions.index(of: newRegions[indexPath.row]) else { return }
                showSubregions(regions: regions, index: index)
            } else {
                self.cell = self.myTableView.cellForRow(at: indexPath) as? RegionsTableViewCell
                guard let url = URL(string: newRegions[indexPath.row].link) else { return }
                let operation = downloadManager.queueDownload(url)
                cell?.downloadOperation = operation
            }
        } else {
            for i in 0..<newRegions.count {
                if newRegions[i].map {
                    let index = IndexPath(row: i, section: 0)
                    if !MapsFileManager.isDownloaded(link: newRegions[i].link) {
                        guard let url = URL(string: newRegions[i].link) else { return }
                        let operation = downloadManager.queueDownload(url)
                        self.cell = self.myTableView.cellForRow(at: index) as? RegionsTableViewCell
                        cell?.downloadOperation = operation
                    }
                    
                }
            }
            
        }
        self.myTableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newRegions.first?.parent != "Europe" {
           return (newRegions.count + 1)
        }
        return newRegions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionsTableViewCell") as! RegionsTableViewCell
        if indexPath.row < newRegions.count {
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
                cell.download.image = UIImage()
            }
            if !newRegions[indexPath.row].map && !hasSubregions(regions: regions, name: newRegions[indexPath.row].name){
                cell.isUserInteractionEnabled = false
                cell.download.image = UIImage()
            }
        } else {
            cell.regionName.text = "Download all regions"
            cell.mapImage.image = UIImage(named: "ic_custom_show_on_map")
            cell.progress.isHidden = true
            cell.selectionStyle = .none
            cell.download.image = UIImage(named: "ic_custom_import")
            if allRegionsDownloaded(regions: newRegions) {
                cell.isUserInteractionEnabled = false
                cell.download.image = UIImage()
            }
        }
        return cell
    }
    
    // MARK: - My functions
    
    func allRegionsDownloaded(regions: [Region]) -> Bool {
        for region in regions {
            if !MapsFileManager.isDownloaded(link: region.link) {
                return false
            }
        }
        return true
    }
    
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
    
    // MARK: - LifeCycle & UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newRegions = regions.filter { $0.parent == regions[index].name }
        newRegions = newRegions.sorted { $0.name < $1.name }
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 136/255, blue: 0, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem
        
        let freeSpace = Double(UIDevice.current.systemFreeSize!)
        let totalSpace = Double(UIDevice.current.systemSize!)
        
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight: CGFloat = self.navigationController?.navigationBar.frame.height ?? 0
        let barsHeight = statusBarHeight + navBarHeight
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        let storageHeight:CGFloat = (newRegions.first?.parent == "Europe") ? 50 : 0
        
        headerText = newRegions.first?.parent == "Europe" ? "Europe" : "Regions"
        myTableView = UITableView(frame: CGRect(x: 0, y: barsHeight + storageHeight, width: displayWidth, height: displayHeight - (barsHeight + storageHeight)))
        myTableView.register(UINib(nibName: "RegionsTableViewCell", bundle: nil), forCellReuseIdentifier: "RegionsTableViewCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.tableFooterView = UIView()
        self.view.addSubview(myTableView)
        
        if newRegions.first?.parent != "Europe" {
            navigationItem.title = newRegions.first?.parent
        } else {
            let storageView = UIView(frame: CGRect(x: 0, y: barsHeight, width: displayWidth, height: storageHeight))
            storageView.backgroundColor = .white
            let leftLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 150, height: 20))
            leftLabel.text = "Device memory"
            leftLabel.font = leftLabel.font.withSize(14)
            
            let rightLabel = UILabel(frame: CGRect(x: displayWidth - 105, y: 5, width: 100, height: 20))
            rightLabel.text = "Free " + storageFreeSize(totalSpace: totalSpace, freeSpace: freeSpace)
            rightLabel.font = rightLabel.font.withSize(14)
            rightLabel.textAlignment = .right
            
            let storage = UIProgressView(frame: CGRect(x: 5, y: 40, width: displayWidth - 10, height: 10))
            storageView.addSubview(leftLabel)
            storageView.addSubview(rightLabel)
            storageView.addSubview(storage)
            storage.progress = Float((totalSpace - freeSpace)/totalSpace)
            storage.tintColor = UIColor(red: 255/255, green: 136/255, blue: 0, alpha: 1)
            storage.trackTintColor = UIColor(red: 242/255, green: 242/255, blue: 243/255, alpha: 1.0)
            self.view.addSubview(storageView)
            
            navigationItem.title = "Download Maps"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        myTableView.reloadData()
    }
}

//MARK: - StorageSize

extension UIDevice {
    
    var systemSize: Int64? {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let totalSize = (systemAttributes[.systemSize] as? NSNumber)?.int64Value else { return nil }
        return totalSize
    }
    
    var systemFreeSize: Int64? {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSize = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value else { return nil }
        return freeSize
    }
}

private func storageFreeSize(totalSpace: Double, freeSpace: Double) -> String {
    let doubleStr: String?
    let prog = (totalSpace - freeSpace)
    if  prog/1024/1024/1024 >= 1 {
        let p = (prog/1024/1024/1024*100).rounded()/100
        doubleStr = String(p) + " GB"
    } else if prog/1024/1024 >= 1 {
        let p = (prog/1024/1024*100).rounded()/100
        doubleStr = String(p) + " MB"
    } else if prog/1024 >= 1 {
        let p = (prog/1024*100).rounded()/100
        doubleStr = String(p) + " KB"
    } else {
        let p = (prog*100).rounded()/100
        doubleStr = String(p) + " B"
    }
    return(doubleStr!)
}
