//
//  CriteoRecoViewController.swift
//  beam
//
//  Created by Romain Lofaso on 10/14/20.
//  Copyright © 2020 Awkward. All rights reserved.
//

import UIKit

class CriteoRootViewController: UIViewController {
    
    var appWindow: UIWindow?
    
    private var criteoButton: UIButton?
    private var panReconizer: UIPanGestureRecognizer?
    
    override func loadView() {
        self.view = CriteoRootView(frame: CGRect.zero)
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.panReconizer = UIPanGestureRecognizer(target: self, action: #selector(panButton(gestureRecognizer:)))
        let button = UIButton()
        button.setImage(UIImage(named: "criteo_button"), for: UIControl.State.normal)
        let size: CGFloat = 75
        let frame = CGRect(
            x: self.view.frame.size.width - size,
            y: self.view.frame.size.height - size,
            width: size,
            height: size)
        button.frame = frame
        button.addGestureRecognizer(self.panReconizer!)
        button.addTarget(self, action: #selector(pressButton), for: .touchUpInside)
        self.view.addSubview(button)
        self.criteoButton = button
    }
    
    @objc func pressButton() {
        let recoViewController = CriteoRecoViewController()
        recoViewController.topController = self.topMostController()
        let nav = UINavigationController(rootViewController: recoViewController)
        show(nav, sender: self)
    }
    
    var initialCenter = CGPoint()  // The initial center point of the view.
    @objc func panButton(gestureRecognizer: UIPanGestureRecognizer) {
       guard gestureRecognizer.view != nil else {return}
       let piece = gestureRecognizer.view!
       // Get the changes in the X and Y directions relative to
       // the superview's coordinate space.
       let translation = gestureRecognizer.translation(in: piece.superview)
       if gestureRecognizer.state == .began {
          // Save the view's original position.
          self.initialCenter = piece.center
       }
          // Update the position for the .began, .changed, and .ended states
       if gestureRecognizer.state != .cancelled {
          // Add the X and Y translation to the view's original position.
          let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
          piece.center = newCenter
       }
       else {
          // On cancellation, return the piece to its original location.
          piece.center = initialCenter
       }
    }

    func topMostController() -> UIViewController? {
        guard let window = appWindow,
              let rootViewController = window.rootViewController else {
            return nil
        }

        var topController = rootViewController

        while let newTopController = topController.presentedViewController,
              newTopController != self {
            topController = newTopController
        }

        return topController
    }
}
