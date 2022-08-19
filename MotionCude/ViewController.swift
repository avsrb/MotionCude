//
//  ViewController.swift
//  MotionCude
//
//  Created by Artem Serebriakov on 19.08.2022.
//

import UIKit
import CoreMotion

final class ViewController: UIViewController, UIGestureRecognizerDelegate {

    private lazy var initialSize = CGSize(width: 100, height: 100)
        
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(handleTap))
        return tapGesture
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(handlePan))
        return panGesture
    }()
    
    private lazy var pinchGesture: UIPinchGestureRecognizer = {
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.addTarget(self, action: #selector(handlePitch))
        return pinchGesture
    }()
    
    private lazy var rotateGesture: UIRotationGestureRecognizer = {
        let rotationGesture = UIRotationGestureRecognizer()
        rotationGesture.addTarget(self, action: #selector(handleRotate))
        return rotationGesture
    }()
    
    var newShape = ShapeView()

    private lazy var animator = UIDynamicAnimator(referenceView: view)
    
    private lazy var gravity = UIGravityBehavior(items: [])
    private lazy var collision = UICollisionBehavior(items: [])
    private lazy var elasticity = UIDynamicItemBehavior(items: [])
    private lazy var motion = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(rotateGesture)

        //TODO: исправть баг
        tapGesture.delegate = self
        panGesture.delegate = self
        pinchGesture.delegate = self
        rotateGesture.delegate = self
        
//        tapGesture.require(toFail: tapGesture)
        collision.translatesReferenceBoundsIntoBoundary = true
        
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(elasticity)

    }

    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        
        guard let gestureView = gesture.view else {
            return
        }
        
        //это не нужно включать
//        gestureView.center = CGPoint(
//            x: location.x + initialSize.width / 2,
//            y: location.y + initialSize.height / 2
//        )
        
        newShape = ShapeView(frame: .init(origin: location, size: initialSize))
//        newShape.addGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
        
        view.addSubview(newShape)
        
        gravity.addItem(newShape)
        collision.addItem(newShape)
        elasticity.addItem(newShape)
        
    }
    
    var panGestureAnchorPoint: CGPoint?
    
    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        guard let gestureView = gesture.view as? ShapeView else {
            return
        }
        
        switch gesture.state {
        case .began:
//            assert(panGestureAnchorPoint == nil)
//            panGestureAnchorPoint = gesture.location(in: view)
            print()
            
        case .changed:
            gestureView.center = CGPoint(
                x: gestureView.center.x + translation.x,
                y: gestureView.center.y + translation.y
            )
        gesture.setTranslation(.zero, in: view)
                        
        case .ended, .cancelled, .failed:
            print(".ended, .cancelled, .failed:")
        default:
            break
        }
        
        //анимация
        /*
        guard gesture.state == .began else {
            return
        }
        
        let velocity = gesture.velocity(in: view)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 200
        
        let slideFactor = 0.1 * slideMultiplier
        
        var finalPoint = CGPoint(
            x: gestureView.center.x + (velocity.x * slideFactor),
            y: gestureView.center.y + (velocity.y * slideFactor)
        )
        
        finalPoint.x = min(max(finalPoint.x, 0), view.bounds.width)
        finalPoint.y = min(max(finalPoint.y, 0), view.bounds.height)
        
        UIView.animate(
            withDuration: Double(slideFactor * 2),
            delay: 0,
            options: .curveEaseIn,
            animations: {
                gestureView.center = finalPoint
            })
         */
    }
    
    @objc
    private func handlePitch(_ gesture: UIPinchGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }
        
        gestureView.transform = gestureView.transform.scaledBy(
            x: gesture.scale,
            y: gesture.scale
        )
        gesture.scale = 1
    }
    
    @objc
    func handleRotate(_ gesture:UIRotationGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }
        
        gestureView.transform = gestureView.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
//        var original = CGFloat()
//        var last: CGFloat = 0
//
//        if gesture.state == .began {
//            gesture.rotation = last
//            original = gesture.rotation
//        } else if gesture.state == .changed {
//            let new = gesture.rotation + original
//            gesture.view?.transform = CGAffineTransform(rotationAngle: new)
//        } else if gesture.state == .ended {
//            last = gesture.rotation
//        }
    }
 
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
