//
//  PrPay.swift
//  Created by ifly_Perry on 2021/6/3.

 
import UIKit
import StoreKit


/// 错误
enum PayFailedType {

    case notProduct
    case restored
    case cancel
    case failed

}

/// 支付回调
protocol PrPayDelegate : NSObject {
    func buySuccess()
    func buyFailed(type : PayFailedType)

    
}
let orderIdMark = "orderId"
class PrPay: NSObject {

    static let shared = PrPay()

    ///要购买的商品id
    private var ProductId : String = ""

    ///订单id，由服务器生成 用于下单完成向服务器验证
    var orderId : String = ""
    
    weak var delegate : PrPayDelegate?
    
    override init() {
        super.init()
    }
    
    func addObserver(){
        SKPaymentQueue.default().add(self)

    }
    /// 请求对应的商品
    /// - Parameter ProductId: 商品id
    func reuqestProduct(ProductId:String){
        if SKPaymentQueue.canMakePayments() {
            self.ProductId = ProductId
            reuqestProductData(type: ProductId)
        }
        
    }
    private func reuqestProductData(type: String) {
        let product = [type]
        let set = NSSet(array: product as [AnyObject])
        let request = SKProductsRequest(productIdentifiers: set as! Set<String>)
        request.delegate = self
        request.start()
    }
    
    
    /// 检测是否还有未完成的订单；有会发起验证请求
    /// - Returns: 是否能正常购买
    func checkUnVerifyTransaction() -> Bool{
        if SKPaymentQueue.default().transactions.count > 0 {

            if let orderid = (UserDefaults.value(forKey: orderIdMark)) as? String {
                orderId = orderid
                self.paymentQueue(SKPaymentQueue.default(), updatedTransactions: SKPaymentQueue.default().transactions)
            }
            return false

        }
        return true
    }
    
    
    
    /// 支付失败
    /// - Parameters:
    ///   - transaction: 支付事务
    ///   - finishTransaction: 是否结束
    func payFailed(transaction:SKPaymentTransaction?,finishTransaction:Bool = true){

        if let dlg = delegate {
            dlg.buyFailed(type: .restored)
        }
        if finishTransaction {
            if let tran = transaction {
                SKPaymentQueue.default().finishTransaction(tran)
            }
            ///结束事务也需要清空本地存储的订单
            UserDefaults.setValue(nil, forKey: orderIdMark)
            orderId = ""
        }
    }

}
extension PrPay : SKPaymentTransactionObserver, SKProductsRequestDelegate {
    ///SKProductsRequestDelegate商品请求回调
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count == 0 {
            if let dlg = delegate {
                dlg.buyFailed(type: .notProduct)
            }

        }
        var prod: SKProduct?
        for pro in response.products {
            if pro.productIdentifier == self.ProductId {
                prod = pro
            }
        }
        if let produ = prod {
            ///发起下单请求
            creteOrder(product: produ)
   
        }
    }
    
    ///SKPaymentTransactionObserver购买回调
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tran in transactions {
     
            switch tran.transactionState {
            case .purchased:
                ///购买成功
               prPayverifyPurchase(transaction: tran)
                
            case .purchasing:
                /////商品添加进列表
                break
            case .restored:
                ///已经购买了
                payFailed(transaction: tran)

            case .failed:
                payFailed(transaction: tran)

            default:
                payFailed(transaction: tran)

                break
            }
        }
    }
    
    ///支付错误
    func request(_ request: SKRequest, didFailWithError error: Error) {

        payFailed(transaction: nil)

    }
    ///结束请求
    func requestDidFinish(_ request: SKRequest) {
        
    }
 
    
}
extension PrPay {
    
    /// 向服务器下单 (网络请求的代码就不拿出来了)
    func creteOrder(product : SKProduct){
        orderId = ""
//        ApiProvider.requestData(SSApi.mood_buySkin(),model:orderModel.self,alert: false) { [self] (type, msg, res) in
//            if type == .success {
                ///发起内购之前存储商品id  用于丢单情况下的二次验证
                let orderid = "请求得到的orderId"
                UserDefaults.setValue(orderid, forKey: orderIdMark)
                orderId = orderid
                ///向苹果服务器发起内购
                let payment = SKMutablePayment(product: product)
                SKPaymentQueue.default().add(payment)
//            } else {
//            }
//        }
        
       
    }
    
    /// 支付服务器验证1
    /// - Parameters:
    ///   - transactionId: 凭证
    func prPayverifyPurchase(transaction:SKPaymentTransaction){

        if orderId.count <= 1{
            orderId =  (UserDefaults.value(forKey: orderIdMark)) as! String

        }
  
        if orderId.count <= 1 {
            payFailed(transaction: transaction)
            return
        }
        /// 获取收据
        let receiptUrl = Bundle.main.appStoreReceiptURL
        let data = NSData(contentsOf: receiptUrl!)
        if let _ = transaction.transactionIdentifier,let str = data?.base64EncodedString(options: .endLineWithLineFeed){
            validationOrder(orderId: orderId, receipt: str, transaction: transaction)
        } else {
            payFailed(transaction:transaction,finishTransaction: true)
        }
    }
    
    /// 支付完成向自己服务器验证2
    /// - Parameters:
    ///   - orderId: 自己服务器生成的订单
    ///   - receipt : 收据
    ///   - transaction:SKPaymentTransaction
    func validationOrder(orderId:String,receipt:String,transaction:SKPaymentTransaction){

        ///发起验证网络请求 transactionId 为普通商品购买的凭证id； originalTransactionId 为订阅商品购买的凭证id
//        ApiProvider.requestNotDolls(SSApi.pay_vildSerives(orderCode:orderId, receiptData: receipt, transactionId:transaction.transactionIdentifier,originalTransactionId: transaction.original?.transactionIdentifier),alert: false) {[self](type, msg, res) in
            if true {

                if let dlg = delegate {
                    dlg.buySuccess()
                }
                ///验证成功 移除凭证 和临时存储的商品
                SKPaymentQueue.default().finishTransaction(transaction)
                UserDefaults.setValue(nil, forKey: orderId)
            } else {
                payFailed(transaction:nil,finishTransaction: false)
            }
//        }

    }
}
