//
//  main.swift
//  sendhci
//
//  Created by Davide Toldo on 22.04.20.
//  Copyright © 2020 Davide Toldo. All rights reserved.
//

import Foundation

guard CommandLine.argc > 1 else {
    print("Please pass HCI command as hex.")
    exit(EXIT_SUCCESS)
}
guard let data = CommandLine.arguments[1].hexadecimal else {
    print("Command might not be valid. Exiting...")
    exit(EXIT_FAILURE)
}

let controller = IOBluetoothHostController.default()
let delegate = HCIDelegate()
controller?.delegate = delegate

var receiveBuffer: [UInt8] = Array(data)
var command: [UInt8] = []
command.append(receiveBuffer[1])
command.append(receiveBuffer[0])
command.append(contentsOf: receiveBuffer.dropFirst(2))

print(command.hexa)

let length: UInt8 = UInt8(receiveBuffer.count)

// Send command to Bluetooth HCI Controller
HCICommunicator.sendHCICommand(&command, len: length)

print("HCI Command sent successfully!")

// This 0.5 second timeout allows the HCI delegate to
// receive and print the result of your HCI command
// (and possibly others that are currently underway)
RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
