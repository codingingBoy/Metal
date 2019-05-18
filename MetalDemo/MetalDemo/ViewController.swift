//
//  ViewController.swift
//  Metal
//
//  Created by JGL on 2018/7/14.
//  Copyright © 2018 JGL. All rights reserved.
//

import Cocoa
import simd
import MetalKit

class ViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    @IBOutlet weak var layout: NSCollectionViewFlowLayout!
    let dataSource = Example.allCases
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initCollectionView()

    }

    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ExampleItem.self, forItemWithIdentifier: ExampleItem.reuseId)
    }

}

extension ViewController {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: ExampleItem.reuseId, for: indexPath)
        guard let exmpleItem = item as? ExampleItem else {
            return item
        }
        exmpleItem.exmple = dataSource[indexPath.item]
        return exmpleItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let first = indexPaths.first, let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        let type = dataSource[first.item].destination
        let render = type.init(device: device)
        let vc = MetalViewController.init()
        vc.render = render
        vc.view.wantsLayer = true
        vc.view.frame = view.frame
        vc.view.layer?.backgroundColor = NSColor.lightGray.cgColor
        presentAsModalWindow(vc)
    }
}
