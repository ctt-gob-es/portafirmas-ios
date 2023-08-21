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
        
            // Format value
        value = [self formatValue:value];
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData: [value dataUsingEncoding:NSUnicodeStringEncoding]
                                                                                options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                     documentAttributes: nil
                                                                                  error: nil ];
        self.valueLabel.text = attributedString;
    }
}

    // Format string passed as parameter to be able to interpret HTML
- (NSString *)formatValue:(NSString *)value {
        // Replace "\r" inside list ("<ul></ul>" or "<ol></ol>") by ""
    NSString * valueFormatted = [self removeLineBreakInsideList:value];
        // Replace "\r" by "<br/>"
    valueFormatted = [valueFormatted stringByReplacingOccurrencesOfString:@"\r" withString:@"<br/>"];
        // Replace "\n" by "<br/>"
    valueFormatted = [valueFormatted stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        // Replace "<br/>" by " <br/> "
    valueFormatted = [valueFormatted stringByReplacingOccurrencesOfString:@"<br/>" withString:@" <br/> "];
        // Put HTTPS before links start with WWW
    valueFormatted = [valueFormatted replacingWithPattern:@"(?<!//)www." withTemplate:@"https://www." error:nil];
        // Replace ” by "
    valueFormatted = [valueFormatted stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    
        // Get text with links as HTML format
    valueFormatted = [self detectLinksOnString:valueFormatted];
    return valueFormatted;
}

    // Method to delete line breaks in HTML lists
- (NSString *)removeLineBreakInsideList:(NSString *) value {
    NSArray * tagsHtmlLists = @[@"ul", @"ol"];
    NSString * valueFormatted = value;
    
    for (NSString *tag in tagsHtmlLists) {
        NSString *finalText = @"";
        NSString *startLabelList = [NSString stringWithFormat:@"<%1$@>", tag];
        NSString *endLabelList = [NSString stringWithFormat:@"</%1$@>", tag];
        
        while ([valueFormatted containsString:startLabelList] == TRUE) {
            NSRange initLabelRange = [valueFormatted rangeOfString:startLabelList];
            NSRange endLabelRange = [valueFormatted rangeOfString:endLabelList];
            
            NSUInteger htmlListStartIndex = initLabelRange.location;
            NSUInteger htmlListEndIndex = endLabelRange.location + endLabelRange.length;
            NSRange htmlListRange = NSMakeRange(htmlListStartIndex, htmlListEndIndex - htmlListStartIndex);
            
            NSString *contentOutList = [valueFormatted substringWithRange:NSMakeRange(0, htmlListStartIndex)];
            finalText = [finalText stringByAppendingString:contentOutList];
            
            NSString *htmlList = [valueFormatted substringWithRange:htmlListRange];
            htmlList = [htmlList stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            finalText = [finalText stringByAppendingString:htmlList];
            
            valueFormatted = [valueFormatted substringWithRange:NSMakeRange(htmlListEndIndex, valueFormatted.length - htmlListEndIndex)];
        }
        valueFormatted = [finalText stringByAppendingString:valueFormatted];
    }
    
    return valueFormatted;
}

    // Detect links in the string that is passed as parameter and convert them to links in HTML format (if they are not already there)
- (NSString *)detectLinksOnString:(NSString *)value {
        // Variables
    NSString *valueFormatted = value;
    
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
            
                // Replace URLs that do not start with ", ' or > with the URL in HTML format
            NSString * pattern = [NSString stringWithFormat:@"(?<!\"|'|>)%@", url.absoluteString];
            valueFormatted = [valueFormatted replacingWithPattern:pattern withTemplate:link error:nil];
        }
    }
    
    return valueFormatted;
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

#pragma mark - TTTAttributedLabelDelegate
    // Function to detect when a link is clicked in a TTTAttributedLabel
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if( [[UIApplication sharedApplication] canOpenURL:url])
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
