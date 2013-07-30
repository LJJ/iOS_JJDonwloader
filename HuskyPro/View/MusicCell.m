//
//  MusicCell.m
//  HuskyPro
//
//  Created by LJJ on 13-7-29.
//  Copyright (c) 2013年 LJJ. All rights reserved.
//

#import "MusicCell.h"

@interface MusicCell ()

@end

@implementation MusicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _singerLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 100, 15)];
        _singerLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_singerLabel];
    }
    return self;
}


@end
