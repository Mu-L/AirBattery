//
//  BatteryView.swift
//  AirBattery
//
//  Created by apple on 2024/2/23.
//

import SwiftUI

struct BatteryView: View {
    var item: Device
    var body: some View {
        let width = round(max(1, min(19, Double(item.batteryLevel)/100*19)))
        ZStack{
            ZStack(alignment: .leading) {
                Image("batt_outline_bold")
                Group{
                    Rectangle()
                        .fill(Color(getPowerColor(item)))
                        .frame(width: width, height: 8, alignment: .leading)
                        .clipShape(RoundedRectangle(cornerRadius: 1.5, style: .continuous))
                }.offset(x:2)
            }
            //.frame(width: 25.5, height: 12, alignment: .leading)
            if item.deviceID == "@MacInternalBattery" {
                if item.acPowered {
                    Image("batt_" + ((item.isCharging != 0 || item.isCharged) ? "bolt" : "plug") + "_mask")
                        .blendMode(.destinationOut)
                        .offset(x:-1.5)
                    Image("batt_" + ((item.isCharging != 0 || item.isCharged) ? "bolt" : "plug"))
                        .offset(x:-1.5)
                        .foregroundColor(Color("black_white"))
                }
            }else{
                if item.isCharging != 0 {
                    Image("batt_" + ((item.isCharging == 5) ? "plug" : "bolt") + "_mask")
                        .blendMode(.destinationOut)
                        .offset(x:-1.5)
                    Image("batt_" + ((item.isCharging == 5) ? "plug" : "bolt"))
                        .offset(x:-1.5)
                        .foregroundColor(Color("black_white"))
                }
            }
        }.compositingGroup()
    }
}

struct mainBatteryView: View {
    @State var item: iBattery = InternalBattery.status
    @AppStorage("statusBarBattPercent") var statusBarBattPercent = false
    @AppStorage("hidePercentWhenFull") var hidePercentWhenFull = false
    @AppStorage("intBattOnStatusBar") var intBattOnStatusBar = true
    @AppStorage("colorfulBattery") var colorfulBattery = false
    @AppStorage("hideLevel") var hideLevel = 90
    
    var body: some View {
        HStack(alignment: .center, spacing:4){
            if item.hasBattery && intBattOnStatusBar {
                let width = round(max(2, min(19, Double(item.batteryLevel)/100*19)))
                if statusBarBattPercent && !(hidePercentWhenFull && item.batteryLevel > hideLevel) {
                    Text("\(item.batteryLevel)%").font(.system(size: 11))
                }
                ZStack(alignment: .leading){
                    ZStack(alignment: .leading) {
                        if colorfulBattery {
                            Image("batt_outline_bold")
                        } else {
                            Image("batt_outline")
                        }
                        Group{
                            Rectangle()
                                .fill(colorfulBattery ? Color(getPowerColor(ib2ab(item))) : (item.batteryLevel <= 10 ? .red : .primary))
                                .frame(width: width, height: 8, alignment: .leading)
                                .clipShape(RoundedRectangle(cornerRadius: 1.5, style: .continuous))
                        }.offset(x:2)
                    }
                    if item.acPowered {
                        Image("batt_" + ((item.isCharging || item.isCharged) ? "bolt" : "plug") + "_mask")
                            .blendMode(.destinationOut)
                            .offset(x:6)
                        Image("batt_" + ((item.isCharging || item.isCharged) ? "bolt" : "plug"))
                            .offset(x:6)
                            .foregroundColor(Color("black_white"))
                    }
                }
                .compositingGroup()
            } else {
                Image("bolt.square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
        }
        .onReceive(dockTimer) { t in AppDelegate.shared.refeshPinnedBar() }
        .onReceive(mainTimer) { t in
            if item.hasBattery {
                InternalBattery.status = getPowerState()
                if intBattOnStatusBar {
                    item = InternalBattery.status
                    let width = statusBarItem.button?.frame.size.width
                    if statusBarBattPercent {
                        if hidePercentWhenFull && item.batteryLevel > hideLevel {
                            if width != 42 { AppDelegate.shared.setStatusBar(width: 42) }
                        } else {
                            if width != 76 { AppDelegate.shared.setStatusBar(width: 76) }
                        }
                    } else {
                        if width != 42 { AppDelegate.shared.setStatusBar(width: 42) }
                    }
                }
            }
        }
    }
}
