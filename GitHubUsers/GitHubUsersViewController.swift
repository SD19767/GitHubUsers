//
//  ViewController.swift
//  GitHubUsers
//
//  Created by Alvin on 2024/4/29.
//

import UIKit
import Combine

class GitHubUsersViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var paginatedSegmentedControl: UISegmentedControl!

    private var viewModel = GitHubUsersViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageViewController()
        bindViewModel()
        setupSegmentedControl()
    }
    
    private func configurePageViewController() {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChild(pageViewController)
        pageView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
    }
    
    private func bindViewModel() {
        viewModel.$tableControllers
            .sink { [weak self] tableControllers in
                guard let self = self else { return }
                if let firstViewController = tableControllers.first {
                    self.pageControl.numberOfPages = tableControllers.count
                    self.pageControl.currentPage = 0
                    (self.children.first as? UIPageViewController)?.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$users
                .sink { [weak self] users in
                    self?.totalLabel.text = "Total Users: \(users.count)"
                }
                .store(in: &cancellables)
        
        viewModel.fetchGitHubUsers()
    }
    
    private func setupSegmentedControl() {
            paginatedSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            if sender.selectedSegmentIndex == 0 {
                viewModel.enablePagination()
                pageControl.isHidden = false
            } else {
                viewModel.disablePagination()
                pageControl.isHidden = true
            }
        }
}

extension GitHubUsersViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentViewController = viewController as? GitHubUsersTableViewController,
              let currentIndex = viewModel.tableControllers.firstIndex(of: currentViewController),
              currentIndex > 0 else { return nil }
        return viewModel.tableControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentViewController = viewController as? GitHubUsersTableViewController,
              let currentIndex = viewModel.tableControllers.firstIndex(of: currentViewController),
              currentIndex < viewModel.tableControllers.count - 1 else { return nil }
        return viewModel.tableControllers[currentIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first as? GitHubUsersTableViewController,
           let currentIndex = viewModel.tableControllers.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
