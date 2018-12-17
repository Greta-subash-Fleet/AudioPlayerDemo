//
//  AudioItemsListViewController.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/17/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import UIKit

class AudioItemsListViewController: UIViewController {
    
    //MARK: Interface Builder
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    


}


//MARK:- Extension tableviewdatasource
extension AudioItemsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AudioItemsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AudioItemsCell", for: indexPath) as! AudioItemsTableViewCell
        cell.labelAudioTitle.text = "Audio title"
        return cell
    }
    
    
}
