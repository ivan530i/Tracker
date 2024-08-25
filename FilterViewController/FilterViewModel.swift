import UIKit

final class FilterViewModel: CategoryViewModelProtocol {
    func setSelectedFilter(_ filter: IndexPath) { }
    
    func getSelectedFilter() -> String {
        dataManager.getSelectedFilter()
    }
    
    func createButtonTapped() { }
    
    weak var view: UIViewController?
    
    private let filtered = [
        "allTrackers".localizedString,
        "todayTrackers".localizedString,
        "completed".localizedString,
        "inComplete".localizedString
    ]
    
    var dataUpdated: (() -> Void)?
    
    var updateCategory: ((String) -> Void)?
    
    var dataManager = CoreDataManager.shared
    
    func sendSelectedFilterToStore(_ indexPath: IndexPath) {
        let selectedFilter = filtered[indexPath.row]
        dataManager.setChosenFilter(filterName: selectedFilter)
    }
    
    func getCategoryCount() -> Int {
        filtered.count
    }
    
    func getCategoryName(_ indexPath: IndexPath) -> String {
        filtered[indexPath.row]
    }
    
    func categoryCellSelected(cell: CustomCategoryCell) { }
    
    func viewDidLoad() { }
    
}
