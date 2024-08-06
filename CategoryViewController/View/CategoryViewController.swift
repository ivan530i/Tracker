import UIKit

final class CategoryViewController: UIViewController {
    
    private lazy var categoryTableView = CustomTableView()
    private lazy var placeholderStack = CustomPlaceholder()
    private lazy var createCategoryButton = CustomButton(target: self, action: #selector(createCategoryButtonTapped))
    
    private var viewModel: CategoryViewModelProtocol
    
    init(viewModel: CategoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupViewModelDataBinding()
    }
    
    @objc private func createCategoryButtonTapped() {
        viewModel.createButtonTapped()
    }
    
    private func setupTableView() {
        categoryTableView.tableViewDelegate = self
        categoryTableView.viewModel = viewModel
        
    }
    
    private func setupViewModelDataBinding() {
        viewModel.viewDidLoad()
        viewModel.dataUpdated = { [weak self] in
            guard let self else { print("Oooops"); return }
            self.categoryTableView.reloadData()
        }
    }
    
    private func setupUI() {
        setupNavigationController()
        view.backgroundColor = .ypWhite
        view.addSubViews([categoryTableView, placeholderStack, createCategoryButton])
        applyConstraints()
    }
    
    private func setupNavigationController() {
        title = "Категория"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    private func applyConstraints() {
        createCategoryButton.setupLayout(view)
        placeholderStack.setupLayout(view)
        categoryTableView.setupLayout(view)
        
        NSLayoutConstraint.activate([
            categoryTableView.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor, constant: -20),
        ])
    }
}

extension CategoryViewController: CategoryViewControllerProtocol {
    
    func showScreen(_ screen: UINavigationController) {
        present(screen, animated: true)
    }
    
    func isPlaceholderShown(_ status: Bool) {
        placeholderStack.isHidden = !status
    }
}

extension CategoryViewController: CustomTableViewDelegate {
    func didSelectCategory() {
        dismiss(animated: true)
    }
}
