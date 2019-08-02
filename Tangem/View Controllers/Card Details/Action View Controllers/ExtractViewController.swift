//
//  ExtractViewController.swift
//  Tangem
//
//  Created by Gennady Berezovsky on 02.09.18.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import Foundation
import CoreNFC
import TangemKit

@available(iOS 13.0, *)
class ExtractViewController: ModalActionViewController {
    
    var card: Card!
    var onDone: (()-> Void)?
    var fee: (min: String, normal: String, max: String)?
    var feeTimer: Timer?
    
    @IBOutlet weak var targetText: UITextField!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var feeText: UITextField!
    
    private var readerSession: NFCTagReaderSession?
    private var startDate = Date()
    @IBOutlet weak var feeControl: UISegmentedControl!
    
    @IBAction func feePresetChanged(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        updateFee()
    }
    
    func updateFee() {
        switch feeControl.selectedSegmentIndex {
        case 0:
            feeText.text = fee?.min ?? ""
        case 1:
            feeText.text = fee?.normal ?? ""
        case 2:
            feeText.text = fee?.max ?? ""
        default:
            feeText.text = ""
        }
    }
    
    
    @IBAction func targetChanged(_ sender: UITextField, forEvent event: UIEvent) {
        tryUpdateFeePreset()
    }
    @IBAction func amountChanged(_ sender: UITextField, forEvent event: UIEvent) {
        tryUpdateFeePreset()
    }
    
    @IBAction func scanTapped() {
        
        guard validateInput() else {
            return
        }
    
        readerSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        readerSession?.alertMessage = "Hold your iPhone near a Tangem card"
        readerSession?.begin()
    }
    
    func validateInput() -> Bool {
        if targetText.text == card.walletPublicKey {
            return false
        }
        
        
        //TODO: validate input
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        amountText.text = card.walletValue
    }
    
    func tryUpdateFeePreset() {
        feeTimer?.invalidate()
        
        guard let targetAddress = targetText.text,
            let amount = amountText.text,
            !targetAddress.isEmpty,
            !amount.isEmpty else {
                return
        }
        
        feeTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(0.3), repeats: false, block: { [weak self] _ in
            guard let cProvider = self?.card.cardEngine as? CoinProvider else {
                return
            }
            cProvider.getFee(targetAddress: targetAddress, amount: amount) {[weak self] fee in
                guard let self = self,
                    let fee = fee else {
                        return
                }
                self.fee = fee
                DispatchQueue.main.async {
                     self.updateFee()
                }
                print("min fee: \(fee.min) normal fee: \(fee.normal) max fee \(fee.max)")
            }
        })
    }
    
}


@available(iOS 13.0, *)
extension ExtractViewController: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        let dateDiff = Calendar.current.dateComponents([.second,.nanosecond], from: self.startDate, to: Date())
        print("Session invalidated was executed for:\(dateDiff.second ?? 0).\(dateDiff.nanosecond ?? 0) sec.")
        print(error)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if case let .iso7816(tag7816) = tags.first {
            let nfcTag = tags.first!
            session.connect(to: nfcTag) {[unowned self] error in
                self.startDate = Date()
                guard error == nil else {
                    session.invalidate(errorMessage: error!.localizedDescription)
                    return
                }
                
                
              /*  let signApduBytes15: [UInt8] = "00FB0000000195102091B4D142823F7D20C5F08DF69122DE43F35F057A988D9619F6D3138485C9A2030108BB0000000000018911202AC9A6746ACA543AF8DFF39894CFE8173AFBA21EB01C6FAE33D52947222855EF51012050FF0140916E19992E7F9B1E8D9267C3324616DAC8F4199419C6E4EBF68FDA985F4B64EAFB8D8391FC40575DCA6D3C363BC46A3F64EBF484FBA9187CDF62AEE6CBCE6C1FD2A60F77213D0DBD109F34125031F04F216EDB400497FF3A8A60CFC8B9FA818B65D6DBDE870D6748711A34185851787D49879F34F46476B9EF551DC2A6F3B4EDAFE2A7945ED45FCD8D5103FCEE5343B87F044842491766D1810A00F9548E94FFCF34AAE21BEEBC83B4980296F074EA0D48EC49F5D547ABD5C3D5A090104409F08520EDACB060C65D4B071A2DEE677564DEC3FDBB8EBD6099F97A663FDE471B17FAAF1696A3087E6D51EBED35AD8606AB8CB90060BAA2A7654E4F5ABBAFED9BC1287DA32EC5EB11EFA2AF08C5D898A5F32BDEAD4C786A778A6F37BEFC4F445B11B93B3713B52B256D836D79A473FEFCAE970C384439BEE47C0A4FF9E7A73448E7 ".asciiHexToData()!
                
                let signApduBytes5: [UInt8] = "00FB0000000195102091B4D142823F7D20C5F08DF69122DE43F35F057A988D9619F6D3138485C9A2030108BB0000000000001511202AC9A6746ACA543AF8DFF39894CFE8173AFBA21EB01C6FAE33D52947222855EF51012050FF0140916E19992E7F9B1E8D9267C3324616DAC8F4199419C6E4EBF68FDA985F4B64EAFB8D8391FC40575DCA6D3C363BC46A3F64EBF484FBA9187CDF62AEE6CBCE6C1FD2A60F77213D0DBD109F34125031F04F216EDB400497FF3A8A60CFC8B9FA818B65D6DBDE870D6748711A34185851787D49879F34F46476B9EF551DC2A6F3B4EDAFE2A7945ED45FCD8D5103FCEE5343B87F044842491766D1810A00F9548E94FFCF34AAE21BEEBC83B4980296F074EA0D48EC49F5D547ABD5C3D5A090104409F08520EDACB060C65D4B071A2DEE677564DEC3FDBB8EBD6099F97A663FDE471B17FAAF1696A3087E6D51EBED35AD8606AB8CB90060BAA2A7654E4F5ABBAFED9BC1287DA32EC5EB11EFA2AF08C5D898A5F32BDEAD4C786A778A6F37BEFC4F445B11B93B3713B52B256D836D79A473FEFCAE970C384439BEE47C0A4FF9E7A73448E7".asciiHexToData()!
                
                */
                
                
                let cProvider = self.card.cardEngine as! CoinProvider
                let hashToSign = cProvider.getHashForSignature(amount: self.amountText.text!, fee: self.feeText.text!, includeFee: false, targetAddress: self.targetText.text!)
                
                print(hashToSign!.toHexString())
                
                //TODO: create sign apdu from ui and transaction data
                //let commandApdu = CommandApdu(with: .sign, tlv: [])
                //let signApduBytes = commandApdu.buildCommand()
                
                let cardId = self.card.cardID.asciiHexToData()!
                let hSize = [UInt8(hashToSign!.count)]
                
                let tlvData = [
                    CardTLV(.pin, value: "000000".sha256().asciiHexToData()),
                    CardTLV(.cardId, value: cardId),
                    CardTLV(.pin2, value: "000".sha256().asciiHexToData()),
                    CardTLV(.transactionOutHashSize, value: hSize),
                    CardTLV(.transactionOutHash, value: hashToSign?.bytes)]
                
                let commandApdu = CommandApdu(with: .sign, tlv: tlvData)
                let signApduBytes = commandApdu.buildCommand()
                for tlv in tlvData {
                     print(tlv.value!.toHexString())
                }
                
                print(signApduBytes.toHexString())
                let signApdu = NFCISO7816APDU(data: Data(bytes: signApduBytes))!
                self.sendSignRequest(to: tag7816, with: session, signApdu)
            }
        }
        
    }
    
    private func sendSignRequest(to tag: NFCISO7816Tag, with session: NFCTagReaderSession, _ apdu: NFCISO7816APDU) {
        tag.sendCommand(apdu: apdu) {[unowned self] (data, sw1, sw2, apduError) in
            guard apduError == nil else {
                // session.invalidate(errorMessage: apduError!.localizedDescription)
                session.alertMessage = "Hold your iPhone near a Tangem card"
                session.restartPolling()
                return
            }
            
            let respApdu = ResponseApdu(with: data, sw1: sw1, sw2: sw2)
            
            if let cardState = respApdu.state {
                switch cardState {
                case .needPause:
                    if let remainingMilliseconds = respApdu.tlv[.pause]?.intValue {
                        self.readerSession?.alertMessage = "Security delay: \(remainingMilliseconds/100) seconds"
                    }
                    
                    if respApdu.tlv[.flash] != nil {
                        let dateDiff = Calendar.current.dateComponents([.second,.nanosecond], from: self.startDate, to: Date())
                        print("Restart polling:\(dateDiff.second ?? 0).\(dateDiff.nanosecond ?? 0) sec.")
                        self.readerSession?.restartPolling()
                        
                    } else {
                        self.sendSignRequest(to: tag, with: session, apdu)
                    }
                    
                case .processCompleted:
                    session.alertMessage = "Signed :)"
                    session.invalidate()
                    if let sign = respApdu.tlv[.signature]?.value {
                        // session.alertMessage = "Signed :)"
                        let cProvider = self.card.cardEngine as! CoinProvider
                        cProvider.sendToBlockchain(signFromCard: sign) {result in
                            if result {
                                print("Tx send successfully")
                            } else {
                                print("error")
                            }
                              DispatchQueue.main.async {
                                self.dismiss(animated: true) {
                                    self.onDone?()
                                }
                            }
                        }
                    }
                    
                    let dateDiff = Calendar.current.dateComponents([.second,.nanosecond], from: self.startDate, to: Date())
                    print("Command sign was executed for:\(dateDiff.second ?? 0).\(dateDiff.nanosecond ?? 0) sec.")
                //TODO: send sign somewhere
                default:
                    session.invalidate(errorMessage: cardState.localizedDescription)
                }
            } else {
                session.invalidate(errorMessage: "Unknown card state: \(sw1) \(sw2)")
            }
        }
    }

}
