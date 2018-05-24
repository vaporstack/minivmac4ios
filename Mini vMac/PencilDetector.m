//
//  PencilDetector.m
//  Mini vMac
//
//  Created by vs on 5/24/18.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

//	from: https://stackoverflow.com/questions/32542250/detect-whether-apple-pencil-is-connected-to-an-ipad-pro

#include "PencilDetector.h"

@interface PencilDetector ()

@end

@implementation PencilDetector
{
	CBCentralManager* m_centralManager;
}

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		// Save a reference to the central manager. Without doing this, we never get
		// the call to centralManagerDidUpdateState method.
		m_centralManager = [[CBCentralManager alloc] initWithDelegate:self
									queue:nil
								      options:nil];
	}
	
	return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	if ([central state] == CBCentralManagerStatePoweredOn)
	{
		// Device information UUID
		NSArray* myArray = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"180A"]];
		
		NSArray* peripherals =
		[m_centralManager retrieveConnectedPeripheralsWithServices:myArray];
		for (CBPeripheral* peripheral in peripherals)
		{
			if ([[peripheral name] isEqualToString:@"Apple Pencil"])
			{
				// The Apple pencil is connected
			}
		}
	}
}

@end
