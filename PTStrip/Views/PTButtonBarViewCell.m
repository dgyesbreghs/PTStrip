//
//  PTButtonBarViewCell.m
//  PagerTab
//
//  Created by Dylan Gyesbreghs on 15/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import "PTButtonBarViewCell.h"

@interface PTButtonBarViewCell()

@property (nonatomic, weak) IBOutlet UILabel *label;

@end

@implementation PTButtonBarViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitHeader;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.accessibilityTraits |= UIAccessibilityTraitSelected;
    } else {
        self.accessibilityTraits &= ~UIAccessibilityTraitSelected;
    }
}

- (void)setupWithTitle:(NSString *)title {
    self.label.text = title;
    self.accessibilityLabel = title;
}

#pragma mark - Reuse Identifier

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

@end
