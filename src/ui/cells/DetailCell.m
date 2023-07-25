    //
    //  DetailCell.m
    //  PortaFirmasUniv
    //
    //  Created by Sergio PH on 15/05/2018.
    //  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
    //

#import "DetailCell.h"
#import "UIFont+Styles.h"
#import "UIColor+Styles.h"
#import "TTTAttributedLabel.h"

@implementation DetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
        // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
        // Configure the view for the selected state
}

-(void)setCellTitle:(NSString *)value
{
    self.titleLabel.text = value;
    [self.titleLabel sizeToFit];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
}

-(void)setCellValue:(NSString *)value
{
    if(value != nil) {
        self.valueLabel.delegate = self;
        
            // Copy text into a variable to modify it
        NSString *valueFormatted = value;
        NSString *hrefString = @"href";
        
            // Detect links in text
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *matches = [detector matchesInString:value options:0 range:NSMakeRange(0, [value length])];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
                // If link, convert URL into HTML link
            if ([match resultType] == NSTextCheckingTypeLink) {
                    // Get URL
                NSURL *url = [match URL];
                    // Convert URL to String with HTML link format
                NSString *link = [NSString stringWithFormat:@"%s%@%s%@%s", "<a href='", url, "'>", url, "</a>"];
                
                    // Check if the URL is already included in HTML link format, that is, <a href="URL"></a>
                NSUInteger temporalLabelLenght = 8;
                NSUInteger temporalLabelStartIndex = matchRange.location - temporalLabelLenght;
                NSString *temporalLabel = [value substringWithRange:NSMakeRange(temporalLabelStartIndex, temporalLabelLenght)];
                    // If the temporary label does not come in HTML format, it is modified so that it does.
                if ([temporalLabel rangeOfString:hrefString].location == NSNotFound) {
                    valueFormatted = [valueFormatted stringByReplacingOccurrencesOfString:url.absoluteString withString:link];
                }
            }
        }
            // Update text
        value = valueFormatted;
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData: [value dataUsingEncoding:NSUnicodeStringEncoding]
                                                                                options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                     documentAttributes: nil
                                                                                  error: nil ];
        self.valueLabel.text = attributedString;
    }
}

-(void)setDarkStyle
{
    UIFont *headerFont = [UIFont headerFontStyle];
    self.titleLabel.font = headerFont;
    self.valueLabel.font = headerFont;
}

-(void)setValueBoldStyle
{
    [self setBoldStyle: self.valueLabel];
}

-(void)setTitleBoldStyle
{
    [self setBoldStyle: self.titleLabel];
}

-(void)setBoldStyle:(UILabel*)label
{
    if (![label.font.fontName containsString: @"Bold"]) {
        label.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",label.font.fontName] size:label.font.pointSize];
    }
}

-(void)setValueInNewViewStyle
{
    CGRect frameRect = self.titleLabel.frame;
    frameRect.size.width = 300;
    self.titleLabel.frame = frameRect;
    [self setTitleBoldStyle];
}

-(void)setClearStyle
{
    UIFont *titleFont = [UIFont clearStyleTitleDetailCell];
    self.titleLabel.font = titleFont;
    self.titleLabel.textColor = [UIColor clearStyleTitleDetailCell];
    UIFont *valueFont = [UIFont clearStyleValueDetailCell];
    self.valueLabel.font = valueFont;
    self.valueLabel.textColor =[UIColor clearStyleValueDetailCell];
}

-(void)hideLabelsIfNeeded:(BOOL)hidden
{
    for (UILabel* label in self.labels) {
        label.hidden = hidden;
    }
}

-(void)increaseTitleLabelWidth:(CGFloat)width
{
    self.titleConstraintWidth.constant = width;
}

#pragma mark - TTTAttributedLabel delegate
    // Function to detect when a link is clicked in a TTTAttributedLabel
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if( [[UIApplication sharedApplication] canOpenURL:url])
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
