//
//  CategoriesViewController.swift
//  SaveMoney
//
//  Created by Alim on 09.05.2021.
//

import UIKit

class CategoriesViewController: UIViewController, UpdatePage {
    
    // ViewController elements (just design)
    @IBOutlet weak var categoriesHeaderView: UIView!
    @IBOutlet weak var categoriesListView: UIView!
    
    //ViewController elemts (design and content)
    @IBOutlet weak var operationsPeriodTitle: UILabel!
    @IBOutlet weak var categoriesHeaderTitle: UILabel!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var timePeriodButton: UIButton!
    @IBOutlet weak var previousPeriodButton: UIButton!
    @IBOutlet weak var nextPeriodButton: UIButton!
    @IBOutlet weak var timePeriodSegmentedControl: UISegmentedControl!
    
    // Necessary variables
    var categoriesViewModel = CategoriesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }
    
    func setupViewElements() {
        categoriesHeaderView.layer.cornerRadius = 30
        categoriesListView.layer.cornerRadius = 30
        categoriesTableView.rowHeight = 55
        
        timePeriodButton.layer.cornerRadius = 20
        timePeriodTypeChanged(self)
        timePeriodSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.selected)
        timePeriodSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
    }
    
    func reloadData() {
        timePeriodButton.setTitle(categoriesViewModel.datesRange.toString(), for: .normal)
        categoriesViewModel.getCategories()
        categoriesTableView.reloadData()
    }
    
    func setupTimePeriodButtons(period: Bool = false, previous: Bool = true, next: Bool = true) {
        previousPeriodButton.isHidden = !previous
        nextPeriodButton.isHidden = !next
        timePeriodButton.isEnabled = period
    }
    
    @IBAction func timePeriodTypeChanged(_ sender: Any) {
        let datesRange = categoriesViewModel.datesRange
        let index = timePeriodSegmentedControl.selectedSegmentIndex
        switch index {
        case 0:
            setupTimePeriodButtons(previous: false, next: false)
            datesRange.setupDatesRange(type: .all)
        case 1, 2, 3, 4:
            setupTimePeriodButtons()
            datesRange.setupDatesRange(type: DateRangeType.init(rawValue: index)!)
        case 5:
            setupTimePeriodButtons(period: true, previous: false, next: false)
            datesRange.setupDatesRange(type: .custom)
        default:
            setupTimePeriodButtons(previous: false, next: false)
        }
        reloadData()
    }
    
    @IBAction func previousTimePeriodPressed(_ sender: Any) {
        categoriesViewModel.datesRange.getAnotherPeriodByStep(step: -1)
        reloadData()
    }
    
    @IBAction func nextTimePeriodPressed(_ sender: Any) {
        categoriesViewModel.datesRange.getAnotherPeriodByStep(step: 1)
        reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addCategory":
            if let destination = segue.destination as? AddCategoryViewController {
                destination.delegate = self
            }
        case "categoryOperations":
            if let destination = segue.destination as? CategoryOperationsViewController {
                destination.category = categoriesViewModel.requestedCategories[categoriesTableView.indexPathForSelectedRow!.row]
                destination.datesRange = categoriesViewModel.datesRange
                destination.delegate = self
            }
        case "editCategory":
            if let destination = segue.destination as? EditCategoryViewController {
                destination.currentCategory = categoriesViewModel.requestedCategories[(sender as! UIButton).tag]
                destination.delegate = self
            }
        case "chooseDatesRange":
            if let destination = segue.destination as? DatesRangePickerViewController {
                destination.delegate = self
                destination.datesRange = categoriesViewModel.datesRange
            }
        case .none:
            return
        case .some(_):
            return
        }
    }
}


extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesViewModel.requestedCategories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoriesTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as? CategoryTableViewCell
        let currentCategory = categoriesViewModel.requestedCategories[indexPath.row]
        
        cell?.title.text = currentCategory.name
        cell?.amount.text = categoriesViewModel.expenciesRates[indexPath.row].formattedWithSeparator
        if currentCategory.iconPath != nil {
            cell?.imageType.image = UIImage.init(named: currentCategory.iconPath!)
        }
        cell?.editButton.tag = indexPath.row
        cell?.tag = indexPath.row
        
        return cell!
    }
}


extension CategoriesViewController: DateRangeSave {
    func saveDateRange(datesRange: DatesRange) {
        categoriesViewModel.datesRange = datesRange
        reloadData()
    }
}
