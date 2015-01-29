//
//  DWTagList.m
//
//  Created by Dominic Wroblewski on 07/07/2012.
//  Copyright (c) 2012 Terracoding LTD. All rights reserved.
//

#import "DWTagList.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 10.0f
#define LABEL_MARGIN_DEFAULT 5.0f
#define BOTTOM_MARGIN_DEFAULT 5.0f
#define FONT_SIZE_DEFAULT 13.0f
#define HORIZONTAL_PADDING_DEFAULT 7.0f
#define VERTICAL_PADDING_DEFAULT 3.0f
#define BACKGROUND_COLOR [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00]
#define TEXT_COLOR [UIColor blackColor]
#define TEXT_SHADOW_COLOR [UIColor whiteColor]
#define TEXT_SHADOW_OFFSET CGSizeMake(0.0f, 1.0f)
#define BORDER_COLOR [UIColor lightGrayColor]
#define BORDER_WIDTH 1.0f
#define HIGHLIGHTED_BACKGROUND_COLOR [UIColor colorWithRed:0.40 green:0.80 blue:1.00 alpha:0.5]
#define DEFAULT_AUTOMATIC_RESIZE NO
#define DEFAULT_SHOW_TAG_MENU NO

@interface DWTagList () <DWTagViewDelegate>

@end

@implementation DWTagList

@synthesize view, textArray, automaticResize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.automaticResize = DEFAULT_AUTOMATIC_RESIZE;
        self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
        self.font = [UIFont systemFontOfSize:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
        self.cornerRadius = CORNER_RADIUS;
        self.borderColor = BORDER_COLOR;
        self.borderWidth = BORDER_WIDTH;
        self.textColor = TEXT_COLOR;
        self.textShadowColor = TEXT_SHADOW_COLOR;
        self.textShadowOffset = TEXT_SHADOW_OFFSET;
        self.showTagMenu = DEFAULT_SHOW_TAG_MENU;
        
        self.selectedTextColor = TEXT_COLOR;
        self.selectedTextShadowColor = TEXT_SHADOW_COLOR;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
        self.font = [UIFont systemFontOfSize:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
        self.cornerRadius = CORNER_RADIUS;
        self.borderColor = BORDER_COLOR;
        self.borderWidth = BORDER_WIDTH;
        self.textColor = TEXT_COLOR;
        self.textShadowColor = TEXT_SHADOW_COLOR;
        self.textShadowOffset = TEXT_SHADOW_OFFSET;
        self.showTagMenu = DEFAULT_SHOW_TAG_MENU;
        
        self.selectedTextColor = TEXT_COLOR;
        self.selectedTextShadowColor = TEXT_SHADOW_COLOR;
    }
    return self;
}

- (NSMutableIndexSet *)selectedIndexes {
    if (!_selectedIndexes) {
        NSMutableIndexSet *newSet = [NSMutableIndexSet new];
        _selectedIndexes = newSet;
    }
    return _selectedIndexes;
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    _selectedTextColor = selectedTextColor;
    [self display];
}

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor {
    _highlightedTextColor = highlightedTextColor;
    [self display];
}

- (void)setTags:(NSArray *)array
{
    textArray = [[NSArray alloc] initWithArray:array];
    sizeFit = CGSizeZero;
    if (automaticResize) {
        [self display];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeFit.width, sizeFit.height);
    }
    else {
        [self display];
    }
}

- (void)setTagBackgroundColor:(UIColor *)color
{
    lblBackgroundColor = color;
    [self display];
}

- (void)setTagHighlightColor:(UIColor *)color
{
    self.highlightedBackgroundColor = color;
    [self display];
}

- (void)setTagSelectedColor:(UIColor *)color {
    self.selectedBackgroundColor = color;
    [self display];
}

- (void)setViewOnly:(BOOL)viewOnly
{
    if (_viewOnly != viewOnly) {
        _viewOnly = viewOnly;
        [self display];
    }
}

- (void)setHorizontalPadding:(CGFloat)horizontalPadding {
    _horizontalPadding = horizontalPadding;
    [self display];
}

- (void)setVerticalPadding:(CGFloat)verticalPadding {
    _verticalPadding = verticalPadding;
    [self display];
}

- (void)setLabelMargin:(CGFloat)labelMargin {
    _labelMargin = labelMargin;
    [self display];
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin;
    [self display];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)display
{
    NSMutableArray *tagViews = [NSMutableArray array];
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[DWTagView class]]) {
            DWTagView *tagView = (DWTagView*)subview;
            for (UIGestureRecognizer *gesture in [subview gestureRecognizers]) {
                [subview removeGestureRecognizer:gesture];
            }
            
            [tagView.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
            tagView.button.selected = NO;
            tagView.button.backgroundColor = [self getBackgroundColor];
            [tagViews addObject:subview];
        }
        [subview removeFromSuperview];
    }
    
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    
    NSInteger tag = 0;
    for (id text in textArray) {
        DWTagView *tagView;
        if (tagViews.count > 0) {
            tagView = [tagViews lastObject];
            [tagViews removeLastObject];
        }
        else {
            tagView = [[DWTagView alloc] init];
        }
        
        BOOL isSelected = [self.selectedIndexes containsIndex:tag];
        
        NSString *title = isSelected ? [text stringByAppendingString:@" -"] : [text stringByAppendingString:@" +"];
        
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [attrTitle addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier" size:16.0] range:NSMakeRange(attrTitle.length - 1, 1)];
        if (isSelected) {
            [attrTitle addAttribute:NSForegroundColorAttributeName value:self.selectedTextColor range:NSMakeRange(0, attrTitle.length)];
            
        } else {
            [attrTitle addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, attrTitle.length - 1)];
            [attrTitle addAttribute:NSForegroundColorAttributeName value:self.borderColor range:NSMakeRange(attrTitle.length - 1, 1)];
        }
        
        [tagView updateWithString:attrTitle
                             font:self.font
               constrainedToWidth:self.frame.size.width - (self.horizontalPadding * 2)
                          padding:CGSizeMake(self.horizontalPadding, self.verticalPadding)
                     minimumWidth:self.minimumWidth
         ];
        
        if (gotPreviousFrame) {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + tagView.frame.size.width + self.labelMargin > self.frame.size.width) {
                newRect.origin = CGPointMake(0, previousFrame.origin.y + tagView.frame.size.height + self.bottomMargin);
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + self.labelMargin, previousFrame.origin.y);
            }
            newRect.size = tagView.frame.size;
            [tagView setFrame:newRect];
        }
        
        previousFrame = tagView.frame;
        gotPreviousFrame = YES;
        
        [tagView setBackgroundColor:[self.selectedIndexes containsIndex:tag] ? [self getSelectedBackgroundColor] : [self getBackgroundColor]];
        [tagView setCornerRadius:self.cornerRadius];
        [tagView setBorderColor:self.borderColor.CGColor];
        [tagView setBorderWidth:self.borderWidth];
        [tagView setTextColor:self.textColor];
        [tagView setTextShadowColor:self.textShadowColor];
        [tagView setTextShadowOffset:self.textShadowOffset];
        
        [tagView setSelectedTextColor:self.selectedTextColor];
        [tagView setSelectedTextShadowColor:self.selectedTextShadowColor];
        
        [tagView setHighlightedTextColor:self.highlightedTextColor];
        [tagView setHighlightedTextShadowColor:self.highlightedTextShadowColor];
        
        [tagView setTag:tag];
        [tagView setDelegate:self];
        
        tagView.button.selected = [self.selectedIndexes containsIndex:tag];
        
        tag++;
        
        [self addSubview:tagView];
        
        if (!_viewOnly) {
            [tagView.button addTarget:self action:@selector(touchDownInside:) forControlEvents:UIControlEventTouchDown];
            [tagView.button addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [tagView.button addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
            [tagView.button addTarget:self action:@selector(touchDragInside:) forControlEvents:UIControlEventTouchDragInside];
        }
    }
    
    sizeFit = CGSizeMake(self.frame.size.width, previousFrame.origin.y + previousFrame.size.height + self.bottomMargin + 1.0f);
    self.contentSize = sizeFit;
}

- (CGSize)fittedSize
{
    return sizeFit;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    [self setContentOffset: CGPointMake(0.0, self.contentSize.height - self.bounds.size.height + self.contentInset.bottom) animated: animated];
}

- (void)touchDownInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [button setBackgroundColor:self.highlightedBackgroundColor];
}

- (void)touchUpInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    DWTagView *tagView = (DWTagView *)[button superview];
    
    if ([self.tagDelegate respondsToSelector:@selector(selectedTag:tagIndex:)]) {
        [self.tagDelegate selectedTag:tagView.button.titleLabel.text tagIndex:tagView.tag];
    }
    
    if ([self.tagDelegate respondsToSelector:@selector(selectedTag:)]) {
        [self.tagDelegate selectedTag:tagView.button.titleLabel.text];
    }
    
    if (self.showTagMenu) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:tagView.frame inView:self];
        [menuController setMenuVisible:YES animated:YES];
        [tagView becomeFirstResponder];
    } else {
        if ([self.selectedIndexes containsIndex:tagView.tag]) {
            [self.selectedIndexes removeIndex:tagView.tag];
            [self display];
            
        } else {
            [self.selectedIndexes addIndex:tagView.tag];
            [self display];
        }
    }
}

- (void)touchDragExit:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [button setBackgroundColor:[self getBackgroundColor]];
}

- (void)touchDragInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [button setBackgroundColor:[self getBackgroundColor]];
}

- (UIColor *)getBackgroundColor
{
    if (!lblBackgroundColor) {
        return BACKGROUND_COLOR;
    } else {
        return lblBackgroundColor;
    }
}

- (UIColor *)getSelectedBackgroundColor
{
    if (!self.selectedBackgroundColor) {
        return BACKGROUND_COLOR;
    } else {
        return self.selectedBackgroundColor;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    [self display];
}

- (void)setBorderColor:(UIColor*)borderColor
{
    _borderColor = borderColor;
    [self display];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self display];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self display];
}

- (void)setTextShadowColor:(UIColor *)textShadowColor
{
    _textShadowColor = textShadowColor;
    [self display];
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset
{
    _textShadowOffset = textShadowOffset;
    [self display];
}

- (void)dealloc
{
    view = nil;
    textArray = nil;
    lblBackgroundColor = nil;
}

#pragma mark - DWTagViewDelegate

- (void)tagViewWantsToBeDeleted:(DWTagView *)tagView {
    NSMutableArray *mTextArray = [self.textArray mutableCopy];
    [mTextArray removeObject:tagView.button.titleLabel.text];
    [self setTags:mTextArray];
    
    if ([self.tagDelegate respondsToSelector:@selector(tagListTagsChanged:)]) {
        [self.tagDelegate tagListTagsChanged:self];
    }
}

@end


@implementation DWTagView

- (id)init
{
    self = [super init];
    if (self) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [_button setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
        [_button setTitleColor:TEXT_COLOR forState:UIControlStateHighlighted];
        [_button setTitleColor:TEXT_COLOR forState:UIControlStateSelected];
        [_button setTitleShadowColor:TEXT_SHADOW_COLOR forState:UIControlStateNormal];
        [_button setTitleShadowColor:TEXT_SHADOW_COLOR forState:UIControlStateHighlighted];
        [_button setTitleShadowColor:TEXT_SHADOW_COLOR forState:UIControlStateSelected];
        _button.titleLabel.shadowOffset = TEXT_SHADOW_OFFSET;
        
        [_button setFrame:self.frame];
        [self addSubview:_button];
        
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:CORNER_RADIUS];
        [self.layer setBorderColor:BORDER_COLOR.CGColor];
        [self.layer setBorderWidth:BORDER_WIDTH];
    }
    return self;
}

- (void)updateWithString:(id)text font:(UIFont*)font constrainedToWidth:(CGFloat)maxWidth padding:(CGSize)padding minimumWidth:(CGFloat)minimumWidth
{
    CGSize textSize = CGSizeZero;
    BOOL isTextAttributedString = [text isKindOfClass:[NSAttributedString class]];
    
    if (isTextAttributedString) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
//        [attributedString addAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, ((NSAttributedString *)text).string.length)];
        
        textSize = [attributedString boundingRectWithSize:CGSizeMake(maxWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        [_button setAttributedTitle:[attributedString copy] forState:UIControlStateNormal];
        [_button setAttributedTitle:[attributedString copy] forState:UIControlStateHighlighted];
        [_button setAttributedTitle:[attributedString copy] forState:UIControlStateSelected];
    } else {
        textSize = [text sizeWithFont:font forWidth:maxWidth lineBreakMode:NSLineBreakByTruncatingTail];
        [_button setTitle:text forState:UIControlStateNormal];
        [_button setTitle:text forState:UIControlStateHighlighted];
        [_button setTitle:text forState:UIControlStateSelected];
    }
    
    textSize.width = MAX(textSize.width, minimumWidth);
    textSize.height += padding.height*2;
    
    self.frame = CGRectMake(0, 0, textSize.width+padding.width*2, textSize.height);
    _button.frame = CGRectMake(/*padding.width*/0, 0, /*MIN(textSize.width, */self.frame.size.width/*)*/, /*textSize.height*/self.frame.size.height);
    _button.titleLabel.font = font;
    
    [_button setAccessibilityLabel:_button.titleLabel.text];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    [self.layer setCornerRadius:cornerRadius];
}

- (void)setBorderColor:(CGColorRef)borderColor
{
    [self.layer setBorderColor:borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    [self.layer setBorderWidth:borderWidth];
}

- (void)setLabelText:(NSString*)text
{
    [_button setTitle:text forState:UIControlStateNormal];
    [_button setTitle:text forState:UIControlStateHighlighted];
    [_button setTitle:text forState:UIControlStateSelected];
}

- (void)setTextColor:(UIColor *)textColor
{
    [_button setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)setTextShadowColor:(UIColor*)textShadowColor
{
    [_button setTitleShadowColor:textShadowColor forState:UIControlStateNormal];
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset
{
    _button.titleLabel.shadowOffset = textShadowOffset;
}

- (void)setSelectedTextColor:(UIColor *)textColor
{
    [_button setTitleColor:textColor forState:UIControlStateSelected];
}

- (void)setSelectedTextShadowColor:(UIColor*)textShadowColor
{
    [_button setTitleShadowColor:textShadowColor forState:UIControlStateSelected];
}

- (void)setHighlightedTextColor:(UIColor *)textColor
{
    [_button setTitleColor:textColor forState:UIControlStateHighlighted];
    [_button setTitleColor:textColor forState:UIControlStateHighlighted | UIControlStateSelected];
}

- (void)setHighlightedTextShadowColor:(UIColor*)textShadowColor
{
    [_button setTitleShadowColor:textShadowColor forState:UIControlStateHighlighted];
    [_button setTitleShadowColor:textShadowColor forState:UIControlStateHighlighted | UIControlStateSelected];
}

- (void)dealloc
{
    _button = nil;
}

#pragma mark - UIMenuController support

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:)) || (action == @selector(delete:));
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.button.titleLabel.text];
}

- (void)delete:(id)sender
{
    [self.delegate tagViewWantsToBeDeleted:self];
}

@end
