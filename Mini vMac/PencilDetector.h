//
//  PencilDetector.h
//  Mini vMac
//
//  Created by vs on 5/24/18.
//  Copyright © 2018 namedfork. All rights reserved.
//

#ifndef PencilDetector_h
#define PencilDetector_h


//	from: https://stackoverflow.com/questions/32542250/detect-whether-apple-pencil-is-connected-to-an-ipad-pro

@import CoreBluetooth;

@interface PencilDetector : NSObject <CBCentralManagerDelegate>

- (instancetype)init;

@end

#endif /* PencilDetector_h */
