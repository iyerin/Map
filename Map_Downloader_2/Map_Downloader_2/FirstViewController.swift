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
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let index = regions.index(of: newRegions[indexPath.row]) else { return }
        showSubregions(regions: regions, index: index)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newRegions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionsTableViewCell") as! RegionsTableViewCell
        //let cell = tableView.dequeueReusableCell(withIdentifier: "RegionsTableViewCell", for: indexPath as IndexPath)
        cell.regionName.text = newRegions[indexPath.row].name
        cell.mapImage.image = UIImage(named: "ic_custom_show_on_map")
        if hasSubregions(regions: regions, parent: newRegions[indexPath.row].parent) {
            cell.download.image = UIImage(named: "right_arrow")
        } else {
            cell.download.image = UIImage(named: "ic_custom_import")
        }
        //cell.textLabel!.text = newRegions[indexPath.row].name
        return cell
    }
    
    // MARK: - My functions
    
    func showSubregions(regions: [Region], index: Int) {
        let subregionsVC = FirstViewController()
        subregionsVC.regions = regions
        subregionsVC.index = index
        self.navigationController?.pushViewController(subregionsVC, animated:true)
    }
    
    func hasSubregions(regions: [Region], parent: String) -> Bool {
        let filteredRegions = regions.filter {$0.name == parent}
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
    }

}

