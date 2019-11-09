//
//  SubregionsVC.swift
//  Map_Downloader_2
//
//  Created by Ihor YERIN on 11/9/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit

class SubregionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var regions: [Region] = []
    var index = Int()
    private var myTableView: UITableView!
    var newRegions: [Region] = []

    // MARK: - TableView
    
    func indexOf(regions: [Region], name: String) -> Int {
        for i in 0..<regions.count {
            if regions[i].name == name {
                return i
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let index = regions.index(of: newRegions[indexPath.row]) else { return }
        showSubregions(regions: regions, index: index)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newRegions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = newRegions[indexPath.row].name
        return cell
    }
    
    // MARK: - My functions
    
    func showSubregions(regions: [Region], index: Int) {
        let subregionsVC = SubregionsVC()
        subregionsVC.regions = regions
        subregionsVC.index = index
        self.navigationController?.pushViewController(subregionsVC, animated:true)
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        newRegions = regions.filter { $0.parent == regions[index].name }
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
    }
}
