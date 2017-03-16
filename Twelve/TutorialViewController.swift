//
//  FirstTutorialViewController.swift
//  Twelve
//
//  Created by Clement Yerochewski on 13/03/2017.
//  Copyright © 2017 Clement Yerochewski. All rights reserved.
//

import UIKit


class TutorialContainerViewController: UIViewController, TutorialPageViewControllerDelegate {

    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var rigthArrow: UIImageView!
    @IBOutlet weak var closeButton: UIButton!


    let indexMax = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftArrow.isHidden = true
        closeButton.isHidden = true
    }
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageCount count: Int) {
        print("page count : \(count)")
        
    }
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageIndex index: Int) {
        leftArrow.isHidden = index == 0
        rigthArrow.isHidden = index == indexMax
        closeButton.isHidden = index != indexMax
    }


    @IBAction func dismissViewAction(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? TutorialPageViewController {
            tutorialPageViewController.tutorialDelegate = self as TutorialPageViewControllerDelegate
        }
    }
    
}



class TutorialPageViewController: UIPageViewController {
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(identifier: "FirstTutorial"),
                self.newViewController(identifier: "SecondTutorial"),
                self.newViewController(identifier: "ThirdTutorial"),
                self.newViewController(identifier: "FourthTutorial")]
    }()
    
    private func newViewController(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:identifier)
    }
    
    weak var tutorialDelegate: TutorialPageViewControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataSource = self
        delegate = self

        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
}

protocol TutorialPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageIndex index: Int)
    
}


// MARK: UIPageViewControllerDataSource

extension TutorialPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}

extension TutorialPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageIndex: index)
        }
    }
    
}



class TutorialViewController: UIViewController {
    
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var bottomText: UILabel!
    
    let font = UIFont(name: "Exo2-Medium", size: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class FirstTutorialViewController: TutorialViewController {

    let topString:String = "YOU START A GAME BY CONNECTING NUMBER 1"
    let bottomString:String = "WITH THE FOLLOWING NUMBERS"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateText() {
        
        let topAttributedString = NSMutableAttributedString(string: topString, attributes: [NSFontAttributeName:font])
        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "START"))
        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "NUMBER 1"))
        topText.attributedText = topAttributedString
        
        let bottomAttributedString = NSMutableAttributedString(string: bottomString, attributes: [NSFontAttributeName:font])

        bottomAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (bottomString as NSString).range(of: "FOLLOWING NUMBERS"))
        bottomText.attributedText = bottomAttributedString
        
    }
    

}


class SecondTutorialViewController: TutorialViewController {
    
    let topString:String = "CONNECTING A NUMBER CHANGE THE PREVIOUS ONE WITH A RANDOM NUMBER,"
    let bottomString:String = "AND UPDATES THE STARTING NUMBER WITH THE CONNECTED ONE"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateText() {
        
        let topAttributedString = NSMutableAttributedString(string: topString, attributes: [NSFontAttributeName:font])
        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "CONNECTING"))
        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "CHANGE"))
        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "RANDOM NUMBER"))
        topText.attributedText = topAttributedString
        
        let bottomAttributedString = NSMutableAttributedString(string: bottomString, attributes: [NSFontAttributeName:font])
        bottomAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (bottomString as NSString).range(of: "UPDATES THE STARTING NUMBER"))
        bottomText.attributedText = bottomAttributedString
        
    }
    
    
}

class ThirdTutorialViewController: TutorialViewController {
    
    let topString:String = "ALWAYS CONNECT NUMBER FOLLOWING THE STARTING NUMBER"
    let bottomString:String = "THE LONGER, THE  BETTER !"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateText() {
        
        let topAttributedString = NSMutableAttributedString(string: topString, attributes: [NSFontAttributeName:font])

        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "ALWAYS"))
        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "FOLLOWING"))
        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "STARTING NUMBER"))
        topText.attributedText = topAttributedString
        
        let bottomAttributedString = NSMutableAttributedString(string: bottomString, attributes: [NSFontAttributeName:font])

        bottomAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (bottomString as NSString).range(of: "FOLLOWING NUMBERS"))
        bottomAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (bottomString as NSString).range(of: "FOLLOWING NUMBERS"))

        bottomText.attributedText = bottomAttributedString
        
    }
    
    
}


class FourthTutorialViewController: TutorialViewController {
    
    let topString:String = "AFTER 12, COMES 1 "
    let bottomString:String = "AND KEEP IT ON!"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateText() {
        
        let topAttributedString = NSMutableAttributedString(string: topString, attributes: [NSFontAttributeName:font])

        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "12"))
        topAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (topString as NSString).range(of: "1"))
        topText.attributedText = topAttributedString
        
        let bottomAttributedString = NSMutableAttributedString(string: bottomString, attributes: [NSFontAttributeName:font])

        bottomAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.myRed, range: (bottomString as NSString).range(of: "KEEP IT ON"))
        bottomText.attributedText = bottomAttributedString
        
    }
    
    @IBAction func dismissViewAction(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    
    
}


