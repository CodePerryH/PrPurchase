//
//  HomeViewController.swift
//  PrApplePurchase
//
//  Created by admin on 2022/2/11.
//

import UIKit

class HomeViewController: UIViewController {
    private lazy var goPay  : UIButton = {
        let bt = UIButton()
        bt.setTitle("去支付页面", for: .normal)
        bt.setTitleColor(.red, for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 33)
        bt.addTarget(self, action: #selector(goToPayButton), for: .touchUpInside)
        return bt
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(goPay)
        
        goPay.frame = CGRect(x: 0, y: 0, width: 200, height: 70)
        goPay.center = view.center
        // Do any additional setup after loading the view.
    }
    
    @objc func goToPayButton(){
        navigationController?.pushViewController(PayViewController(), animated: true)
    }
}
