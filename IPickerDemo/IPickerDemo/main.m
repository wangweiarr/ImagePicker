//
//  main.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <stdio.h>
#include <mach-o/arch.h>
#include <mach-o/loader.h>
const char *ByteOrder(enum NXByteOrder BO)
{
    switch (BO) {
        case NX_BigEndian:
            return "BigEndian";
            
        case NX_LittleEndian:
            return "LittleEndian";
            
        case NX_UnknownByteOrder:
            return "UnknownByteOrder";
            
        default:
            return "@@@";
    }
}
void displayArchMessage(){
    const NXArchInfo *local = NXGetLocalArchInfo();
    const NXArchInfo *know = NXGetAllArchInfos();
    while (know && know->description) {
        printf("know -> %s\t %x\t %x \t%s\n",know->description,know->cputype,know->cpusubtype,ByteOrder(know->byteorder));
        know++;
    }
    
    if (local) {
        printf("local -> %s\t %x\t %x \t%s\n",local->description,local->cputype,local->cpusubtype,ByteOrder(local->byteorder));
    }
}
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    //displayArchMessage();
    
}


