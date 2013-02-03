//
//  BLEDetailCellData.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/2/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDetailCellData.h"

@implementation BLEDetailCellData

@synthesize textLabelText = _textLabelText;
@synthesize detailTextLabelText =  _detailTextLabelText;


-(NSString *)textLabelText
{
    if (_textLabelText == nil)
    {
        _textLabelText = @"";
    }
    return _textLabelText;
}

-(void)setTextLabelText:(NSString *)textLabelText
{
    _textLabelText = textLabelText;
}

-(void)setDetailTextLabelText:(NSString *)textLabelText
{
    _detailTextLabelText = textLabelText;
}

-(NSString *)detailTextLabelText
{
    if (_detailTextLabelText == nil)
    {
        _detailTextLabelText = @"";
    }
    return _detailTextLabelText;
}


-(void)setLabelText: (NSString *)textLabel andDetailText:(NSString *)detailText
{
    if (textLabel)
    {
        self.textLabelText = textLabel;
    }
    
    if (detailText)
    {
        self.detailTextLabelText = detailText;
    }
}
@end
