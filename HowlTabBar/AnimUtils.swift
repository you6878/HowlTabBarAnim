//
//  AnimUtils.swift
//  HowlTabBar
//
//  Created by 유명식 on 2017. 4. 14..
//  Copyright © 2017년 swift. All rights reserved.
//

import UIKit

class AnimUtils: NSObject,UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FlipAnim(tabBarController : tabBarController)
    }

}


class ScrollingAnim: NSObject, UIViewControllerAnimatedTransitioning{
    weak var transitionContext: UIViewControllerContextTransitioning?
    var tabBarController : UITabBarController!
    var fromIndex = 0
    
    init(tabBarController : UITabBarController) {
        self.tabBarController = tabBarController
        self.fromIndex = tabBarController.selectedIndex
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //뷰 만들어주기
        self.transitionContext = transitionContext
        let containerView = transitionContext.containerView
        
        //원래뷰
        
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        //추가될 뷰
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        containerView.addSubview(toView!.view)
        
        
        var width = toView?.view.bounds.width
        
        //현재 포지션과 새로들어온 포지션 비교
        
        //fromindex 기존값
        //tabBarController.selectedIndex 새로 들어온값
        
        if tabBarController.selectedIndex < fromIndex {
            width = -width!
        }
        
        
        toView!.view.transform = CGAffineTransform(translationX: width!, y: 0)
        
        UIView.animate(withDuration: self.transitionDuration(using: (self.transitionContext)), animations: { 
            //입력되는 뷰
            toView?.view.transform = CGAffineTransform.identity
            fromView?.view.transform = CGAffineTransform(translationX: -width!, y: 0)
            
        }, completion: { _ in
            
            fromView?.view.transform = CGAffineTransform.identity
            self.transitionContext?.completeTransition(!(self.transitionContext?.transitionWasCancelled)!)
        })
        
        
    }
    
    
}



class FlipAnim: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    var reverse: Bool = false
    var tabBarController: UITabBarController!
    var fromIndex = 0
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
        self.fromIndex = tabBarController.selectedIndex
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        //새로 들어온 뷰
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        //기존 뷰
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        let toView = toViewController.view
        let fromView = fromViewController.view
        
        
        
        if tabBarController.selectedIndex < fromIndex {
            
            //뷰가 왼쪽에 있으면 마이너스 뷰가 오른쪽에 있으면 플러스
            reverse = !reverse
        }
        
        
        
        
        //방향
        let direction: CGFloat = reverse ? -1 : 1
        //접히는 각도
        let const: CGFloat = -0.005
        
        toView?.layer.anchorPoint = CGPoint(x:direction == 1 ? 0 : 1, y:0.5)
        fromView?.layer.anchorPoint = CGPoint(x:direction == 1 ? 1 : 0, y:0.5)
        
        
        //효과 주기
        var viewFromTransform: CATransform3D = CATransform3DMakeRotation(direction * CGFloat(M_PI_2), 0.0, 1.0, 0.0)
        var viewToTransform: CATransform3D = CATransform3DMakeRotation(-direction * CGFloat(M_PI_2), 0.0, 1.0, 0.0)
        
        
        viewFromTransform.m34 = const
        viewToTransform.m34 = const
        
        containerView.transform = CGAffineTransform(translationX: direction * containerView.frame.size.width / 2.0, y: 0)
        toView?.layer.transform = viewToTransform
        containerView.addSubview(toView!)
        
        
        
        //뷰 실행
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            containerView.transform = CGAffineTransform(translationX: -direction * containerView.frame.size.width / 2.0, y: 0)
            fromView?.layer.transform = viewFromTransform
            toView?.layer.transform = CATransform3DIdentity
        }, completion: {
            finished in
            containerView.transform = CGAffineTransform.identity
            fromView?.layer.transform = CATransform3DIdentity
            toView?.layer.transform = CATransform3DIdentity
            fromView?.layer.anchorPoint = CGPoint(x: 0.5, y:0.5)
            toView?.layer.anchorPoint = CGPoint(x:0.5,y: 0.5)
            
            if (transitionContext.transitionWasCancelled) {
                toView?.removeFromSuperview()
            } else {
                fromView?.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

