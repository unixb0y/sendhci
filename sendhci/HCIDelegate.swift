//
//  HCIDelegate.swift
//  IOBluetoothExtended
//
//  Created by Davide Toldo on 03.09.19.
//  Copyright © 2019 Davide Toldo. All rights reserved.
//

import Foundation

class HCIDelegate: NSObject {}

// The HCI delegate usually receives all HCI events and
// they can be handled / output via the following implementation.

extension HCIDelegate: IOBluetoothHostControllerDelegate {
    @objc(BluetoothHCIEventNotificationMessage:inNotificationMessage:)
    public func bluetoothHCIEventNotificationMessage(_ controller: IOBluetoothHostController,
        in message: UnsafeMutablePointer<IOBluetoothHCIEventNotificationMessage>) {
        
        let opcode = message.pointee.dataInfo.opcode
        let data = IOBluetoothHCIEventParameterData(message)
        if opcode == 0 { return }
        
        let dataInfo = message.pointee.dataInfo
        let opcod1 = String(format:"%02X", dataInfo.opcode)
        let opcod2 = Array(repeating: "0", count: 4-opcod1.count) + Array(opcod1)
        if opcod2.count < 4 { return }
        let opcod3 = "\(opcod2[2])\(opcod2[3])\(opcod2[0])\(opcod2[1])"
        
        var result = "04"
        result.append(String(format:"%02X", dataInfo._field7))
        result.append("\(String(format:"%02X", dataInfo.parameterSize+3))")
        result.append("01\(opcod3)")
        result.append(data.hexEncodedString())
        
        printFormatted(result)
        if result.count < 8 { return }
        
        // Version Information
        if opcode == 0x1001 {
            var temp = ""
            for i in [0,1,2,3,4,5,9,8,14,15,12,6,7,10,11] {
                temp.append(result[i*2])
                temp.append(result[i*2+1])
                // output temp
            }
        }
        // Connection Complete
        else if opcode == 0x0405 || opcode == 0x0409 {
            let orig = data.hexEncodedString()
            var temp = "0403"
            for i in [8,9,0,1,7,6,5,4,3,2] {
                temp.append(orig[i*2])
                temp.append(orig[i*2+1])
            }
            if temp.count != 24 { return }
            // output temp
        }
        // Disconnection Complete
        else if opcode == 0x0406 {
            let orig = data.hexEncodedString()
            if orig.count == 0 { return }
            var temp = "040504"
            for i in [2,1,0] {
                temp.append(orig[i*2])
                temp.append(orig[i*2+1])
                // output temp
            }
        }
        else {
            let temp = result.hexadecimal!
            if temp.count >= 8 {
                // output temp
            }
        }
    }
    
    func printFormatted(_ result: String) {
        let str = result.separate()
        var formatted = ""
        for (i, sub) in str.components(separatedBy: " ").enumerated() {
            if i % 8 == 7 {
                let rowIndex = i/8
                let start = result.index(result.startIndex, offsetBy: rowIndex * 32)
                let end = rowIndex * 32 + 32 < result.count ?
                    result.index(result.startIndex, offsetBy: rowIndex * 32 + 32) :
                    result.endIndex
                let range = start..<end
                let row = String(result[range])
                formatted.append(sub + " \(row.toAscii())\n")
            }
            else {
                formatted.append(sub + " ")
            }
        }

        print(formatted)
    }
}
