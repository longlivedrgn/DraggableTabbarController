//
//  SegmentedPageVC.swift
//  DraggableViewController
//
//  Created by 김용재 on 8/14/24.
//

//
//  SegmentedPageViewController.swift
//
//  A simple container view controller that manages one or more child view controllers,
//  where only one is visible at the time.
//  Each managed view controller is represented as a segment in a UISegmentedControl.
//  Changing the segment changes the visible view controller.
//  View controllers are constrained with Auto Layout Constraints,
//  and the appearance/disappearance of their views is optionally animated.
//

import UIKit

class SegmentedPageController: UIViewController {

    private let segmentedControl = UISegmentedControl()
    private let buttonStackView = UIStackView()
    private let button1 = UIButton(type: .system)
    private let button2 = UIButton(type: .system)
    private let button3 = UIButton(type: .system)

    private var titleObservations = [NSKeyValueObservation]()

    private var segmentedViewControllers = [UIViewController]()

    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        // Override this to have full control of the appearance events of child view controllers.
        // Call .beginAppearanceTransition(_:animated:) and .endAppearanceTransition() on child view controllers
        // at appropriate times during transition to make sure all appearance methods gets called correctly
        // (like .viewWillAppear(_:animated:) and .viewWillDisappear(_:animated:)).
        false
    }

    override func loadView() {
        view = UIView()

        setupButtons()
        view.addSubview(buttonStackView)
        view.addSubview(segmentedControl)

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.setContentHuggingPriority(.required, for: .vertical)
        segmentedControl.setContentCompressionResistancePriority(.required, for: .vertical)

        let trailingConstraint = segmentedControl.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8
        )
        trailingConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations

        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            segmentedControl.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8
            ),
            trailingConstraint
        ])
    }

    private func setupButtons() {
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8

        [button1, button2, button3].forEach { button in
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .lightGray
            button.layer.cornerRadius = 5
            buttonStackView.addArrangedSubview(button)
        }

        button1.setTitle("Button 1", for: .normal)
        button2.setTitle("Button 2", for: .normal)
        button3.setTitle("Button 3", for: .normal)

        button1.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button2.addTarget(self, action: #selector(buttonTapped2(_:)), for: .touchUpInside)
        button3.addTarget(self, action: #selector(buttonTapped3(_:)), for: .touchUpInside)
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        print("Button tapped: \(sender.titleLabel?.text ?? "")")
        self.setSelectedSegmentIndex(0, using: .slide)
    }
    
    @objc private func buttonTapped2(_ sender: UIButton) {
        print("Button tapped: \(sender.titleLabel?.text ?? "")")
        self.setSelectedSegmentIndex(1, using: .slide)
    }
    
    @objc private func buttonTapped3(_ sender: UIButton) {
        print("Button tapped: \(sender.titleLabel?.text ?? "")")
        self.setSelectedSegmentIndex(2, using: .slide)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged),
            for: .valueChanged
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedViewController?.beginAppearanceTransition(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedViewController?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedViewController?.beginAppearanceTransition(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectedViewController?.endAppearanceTransition()
    }

    private var isCurrentlyVisible: Bool {
        viewIfLoaded?.window != nil
    }

    private func addAndConstrain(viewControllerView: UIView) {
        view.addSubview(viewControllerView)
        
        viewControllerView.translatesAutoresizingMaskIntoConstraints = false

        viewControllerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        viewControllerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        let bottomConstraint = viewControllerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor
        )
        bottomConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations

        let centerXConstraint = viewControllerView.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        )
        centerXConstraint.priority = .required - 1 // To avoid conflicts during transition animations

        let widthConstraint = viewControllerView.widthAnchor.constraint(
            equalTo: view.widthAnchor, constant: -30
        )
        widthConstraint.priority = .required - 1 // To avoid conflicts during initial layout calculations

        NSLayoutConstraint.activate([
            viewControllerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            bottomConstraint,
            centerXConstraint,
            widthConstraint,
        ])

        view.layoutIfNeeded()
    }

    private func removeChildViewControllers() {
        children.forEach { viewController in
            viewController.willMove(toParent: nil)

            if isCurrentlyVisible {
                viewController.beginAppearanceTransition(false, animated: false)
                viewController.endAppearanceTransition()
            }

            viewController.view.removeFromSuperview()

            viewController.removeFromParent()
        }
    }

    private func removeTitleObservations() {
        titleObservations.forEach { observation in
            observation.invalidate()
        }

        titleObservations.removeAll()
    }

    private func setViewController(_ viewController: UIViewController) {
        removeChildViewControllers()

        addChild(viewController)

        addAndConstrain(viewControllerView: viewController.view)

        if isCurrentlyVisible {
            viewController.beginAppearanceTransition(true, animated: false)
            viewController.endAppearanceTransition()
        }

        viewController.didMove(toParent: self)
    }

    private func slideLeftTransition(to viewController: UIViewController) {
        let previousViewController = children.first

        addChild(viewController)

        previousViewController?.willMove(toParent: nil)

        addAndConstrain(viewControllerView: viewController.view)

        if let previousViewControllerView = previousViewController?.view {
            view.bringSubviewToFront(previousViewControllerView)
        }

        let offset = view.bounds.width

        let previousViewCenterXConstraint = previousViewController?.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        )
        previousViewCenterXConstraint?.isActive = true

        viewController.view.transform = .init(scaleX: 0.75, y: 0.75)

        view.layoutIfNeeded()

        previousViewController?.beginAppearanceTransition(false, animated: true)
        viewController.beginAppearanceTransition(true, animated: true)

        UIView.transition(
            with: view,
            duration: 0.25,
            options: [
                .curveEaseOut,
                .beginFromCurrentState,
                .allowAnimatedContent
            ],
            animations: {
                previousViewCenterXConstraint?.constant = -offset
                viewController.view.transform = .identity
                self.view.layoutIfNeeded()
            }, completion: { completed in
                previousViewController?.view.transform = .identity
                previousViewController?.endAppearanceTransition()
                previousViewController?.view.removeFromSuperview()
                previousViewController?.removeFromParent()
                viewController.endAppearanceTransition()
                viewController.didMove(toParent: self)
            }
        )
    }

    private func slideRightTransition(to viewController: UIViewController) {
        let previousViewController = children.first

        addChild(viewController)

        previousViewController?.willMove(toParent: nil)

        addAndConstrain(viewControllerView: viewController.view)

        let offset = view.bounds.width

        let viewCenterXConstraint = viewController.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor, constant: -offset
        )
        viewCenterXConstraint.isActive = true

        viewController.view.transform = .identity

        view.layoutIfNeeded()

        previousViewController?.beginAppearanceTransition(false, animated: true)
        viewController.beginAppearanceTransition(true, animated: true)

        UIView.transition(
            with: view,
            duration: 0.25,
            options: [
                .curveEaseOut,
                .beginFromCurrentState,
                .allowAnimatedContent
            ],
            animations: {
                previousViewController?.view.transform = .init(scaleX: 0.75, y: 0.75)
                viewCenterXConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { completed in
                previousViewController?.view.transform = .identity
                previousViewController?.endAppearanceTransition()
                previousViewController?.view.removeFromSuperview()
                previousViewController?.removeFromParent()
                viewCenterXConstraint.isActive = false
                viewController.endAppearanceTransition()
                viewController.didMove(toParent: self)
            }
        )
    }

    private func setSegmentedViewControllers(_ viewControllers: [UIViewController]) {
        removeChildViewControllers()
        removeTitleObservations()

        segmentedControl.removeAllSegments()
        segmentedViewControllers.removeAll()

        viewControllers.enumerated().forEach { index, viewController in
            segmentedControl.insertSegment(withTitle: viewController.title, at: index, animated: false)

            let titleObservation = viewController.observe(\.title) { viewController, _ in
                guard let index = self.segmentedViewControllers.firstIndex(of: viewController) else { return }
                self.segmentedControl.setTitle(viewController.title, forSegmentAt: index)
            }

            titleObservations.append(titleObservation)
            segmentedViewControllers.append(viewController)
        }
    }

    @objc private func segmentChanged(_ target: UISegmentedControl) {
        setViewController(segmentedViewControllers[segmentedControl.selectedSegmentIndex])
    }
}

extension SegmentedPageController {

    enum Transition {
        case none
        case slide
    }

    var viewControllers: [UIViewController] {
        get {
            segmentedViewControllers
        }
        set {
            setSegmentedViewControllers(newValue)

            guard let firstViewController = newValue.first else {
                return
            }

            segmentedControl.selectedSegmentIndex = 0

            setViewController(firstViewController)
        }
    }

    var selectedViewController: UIViewController? {
        children.first
    }

    var selectedSegmentIndex: Int {
        get {
            return segmentedControl.selectedSegmentIndex
        }
        set {
            guard newValue >= 0, newValue < segmentedControl.numberOfSegments else { return }

            segmentedControl.selectedSegmentIndex = newValue

            setViewController(segmentedViewControllers[newValue])
        }
    }

    func setSelectedSegmentIndex(_ index: Int, using transition: Transition) {
        guard index >= 0, index < segmentedControl.numberOfSegments else { return }

        let slideRight = index < segmentedControl.selectedSegmentIndex

        segmentedControl.selectedSegmentIndex = index

        guard isCurrentlyVisible else {
            return setViewController(segmentedViewControllers[index])
        }

        switch transition {
        case .none:
            setViewController(segmentedViewControllers[index])
        case .slide:
            if slideRight {
                slideRightTransition(to: segmentedViewControllers[index])
            } else {
                slideLeftTransition(to: segmentedViewControllers[index])
            }
        }
    }

    func setViewControllers(_ viewControllers: [UIViewController], using transition: Transition) {
        setSegmentedViewControllers(viewControllers)

        guard let firstViewController = viewControllers.first else {
            return
        }

        segmentedControl.selectedSegmentIndex = 0

        guard isCurrentlyVisible else {
            return setViewController(firstViewController)
        }

        switch transition {
        case .none:
            setViewController(firstViewController)
        case .slide:
            slideLeftTransition(to: firstViewController)
        }
    }
}
