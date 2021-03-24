//
//  MainSplitViewController.swift
//  TvShows
//
//  Created by Salo Antidze on 3/15/21.
//

import UIKit

class MainSplitViewController: UISplitViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate = self
        self.preferredDisplayMode = .allVisible
        
    }
    
    
}

extension MainSplitViewController : UISplitViewControllerDelegate {
    
    @available(iOS 14.0, *)
    public func splitViewController(_ svc: UISplitViewController,
                                    topColumnForCollapsingToProposedTopColumn
                                        proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return .primary
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController,
                                    collapseSecondary secondaryViewController:UIViewController,
                                    onto primaryViewController:UIViewController) -> Bool {
        return true
    }
}
