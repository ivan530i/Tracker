import UIKit

final class FilterViewController: UIViewController {
    
    private lazy var tableView = CustomTableView(viewModel: viewModel)
    
    weak var delegate: FilterViewControllerProtocol?
    
    var viewModel: CategoryViewModelProtocol
    
    init(delegate: FilterViewControllerProtocol?, viewModel: CategoryViewModelProtocol) {
        self.delegate = delegate
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableViewHandler()
    }
    
    private func tableViewHandler() {
        tableView.didSelectHandler = { [weak self] indexPath in
            guard let self else { print("111222"); return }
            delegate?.showFilteredTrackers()
            viewModel.sendSelectedFilterToStore(indexPath)
            dismiss(animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        title = "filters".localizedString
        
        view.addSubViews([tableView])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }
}
