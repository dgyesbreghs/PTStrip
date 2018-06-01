//
//  PTButtonBarViewCell.h
//  PagerTab
//
//  Created by Dylan Gyesbreghs on 15/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTButtonBarViewCell : UICollectionViewCell

- (void)setupWithTitle:(NSString *)title;

+ (NSString *)reuseIdentifier;

@end
