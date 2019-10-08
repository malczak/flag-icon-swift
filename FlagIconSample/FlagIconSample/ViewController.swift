//
//  ViewController.swift
//  FlagIconSample
//
//  Created by Mateusz Malczak on 08/10/2019.
//  Copyright © 2019 Mateusz Malczak. All rights reserved.
//

import UIKit
import flag_icon_swift

fileprivate struct Consts {
    static let countryCellId = "countryCell";
}

class ViewController: UITableViewController {
    
    lazy var flagSheet: SpriteSheet? = {
        return FlagIcons.loadDefault()
    }()
    
    lazy var countries: [FlagIcons.Country] = {
        return FlagIcons.loadCountries() ?? [FlagIcons.Country]()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CountryCell.self,
                           forCellReuseIdentifier: Consts.countryCellId)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        flagSheet?.flushCache()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Consts.countryCellId,
                                                 for: indexPath)
        
        if let countryCell = cell as? CountryCell {
            let row = indexPath.row
            let country = countries[row]
            let countryName = country.name
            let countryFlag = flag(forCountry: country, deepCopy: false)
            countryCell.nameLabel.text = countryName
            countryCell.flagView.image = countryFlag
        }
        
        return cell
    }
    
    func flag(forCountry country: FlagIcons.Country, deepCopy: Bool = false) -> UIImage? {
        return flagSheet?.getImageFor(country.code, deepCopy: deepCopy, scale: 4.0)
    }

}

