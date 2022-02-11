//
//  PayViewController.swift
//  PrApplePurchase
//
//  Created by admin on 2022/2/11.
//

import UIKit

class PayViewController: UIViewController {

    private lazy var desclabel  : UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.font = UIFont.systemFont(ofSize: 17)
        lb.textColor = .black
        lb.numberOfLines = 0
        return lb
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(desclabel)
        desclabel.frame = CGRect(x: 15, y: 150, width: UIScreen.main.bounds.width - 30, height: 500)
        desclabel.text = "进入购买页面，需要检测本地是否还有未完成验证的订单（支付了但没有向自己服务器发起验证的订单）。\n1、如果存在,需要主动向我们服务器发起验证，直到验证成功，才能进行 接下来购买的操作\n2.如果不存在，就可以进行正常的购买。\n\n内购流程（向服务器验证）： \n1、通过productId请求商品。\n2、向服务器下单，然后发起购买。（这步需要存储商品的订单号）\n3、支付完成，向服务器发起验证（如果服务器验证成功，删除2步中存储的订单号，没有验证成功则不删除）,验证成功finishTransaction，不成功不要finish"
        desclabel.sizeToFit()


        ///发起是否还有未验证的订单的检查
        PrPay.shared.checkUnVerifyTransaction()
        PrPay.shared.delegate = self

    }
    
    /// 发起支付方法
    func goToPay(){
        PrPay.shared.reuqestProduct(ProductId: "商品id")
    }

}

extension PayViewController :PrPayDelegate {
    func buySuccess() {
        print("支付成功了，这里可以做一些页面的刷新")

    }
    
    func buyFailed(type: PayFailedType) {
        print("支付失败了")
    }
    
}
