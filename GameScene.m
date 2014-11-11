//
//  GameScene.m
//  MTDrawingFun
//
//  Created by morpheus on 2014/11/10.
//  Copyright (c) 2014年 ___Morpheus___. All rights reserved.
//

// This project shows how to make a scrolling window for game by using SKSpriteNode and UIKit and Core-Graphics
// scrolling window like backpacke or item window, you can scroll up/down for search some items




#import "GameScene.h"

@interface GameScene ()

@property (nonatomic, copy) SKColor *fontColor;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, assign) CGPoint beginPnt;
@property (nonatomic, assign) CGPoint movePnt;
@property (nonatomic, assign) CGPoint scrollPnt;
@property (nonatomic, strong) UIImage *fullImage;

@property (nonatomic, assign) CGSize fullsize;
@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, assign) CGSize visiblesize;

@property (nonatomic, strong) SKSpriteNode *showNode;

@end

@implementation GameScene

-(instancetype) initWithSize:(CGSize)size
{
    
    if (self = [super initWithSize:size]) {
        
        self.fontColor = [SKColor whiteColor];
        self.fontName = @"Helvetica";
        self.fontSize = 15.0f;

        
        
        _scrollPnt = CGPointMake(0, 0); // scrolling point
        _fullsize = CGSizeMake(73.0f * 3.0f + 20.0f, 1200); // full Image Size
        //_fullsize = CGSizeMake(73.0f * 3.0f + 20.0f, 73.0f *6.0f + 20.0f); // full Image Size
        _visiblesize = CGSizeMake(73.0f * 3.0f + 20.0f, 73.0f *2.0f + 20.0f); // visible Size
        NSLog(@"scale = %f", [UIScreen mainScreen].scale);
        
        // 1. Create Full image
        //_fullImage = [self getFullImageBySize:_fullsize];
        _fullImage = [self getFullImageTextBySize:_fullsize];
        NSLog(@"full image size = %@", NSStringFromCGSize(_fullImage.size));
        
        // 2. Get partial image for visible area
        UIImage *subImage = [self getSubImage:_fullImage ByPosition:CGPointMake(0,0) AndSize:_visiblesize];
        
        // 3. Create SKSpriteNode by using subImage
        SKTexture *texture = [SKTexture textureWithImage:subImage];
        
        _showNode = [SKSpriteNode spriteNodeWithTexture:texture];
        _showNode.anchorPoint = CGPointMake(0, 0);
        _showNode.position = CGPointMake(size.width/2 - _showNode.size.width/2, size.height/2 - _showNode.size.height/2);
        
        [self addChild:_showNode];
        
    }
    
    
    return self;
    
}


-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    
    
    /*
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 65;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    
    [self addChild:myLabel];
     */
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        //NSLog(@"point = %@", NSStringFromCGPoint(location));

        _movePnt = location; // initial moving point
    }
    
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];

        // scrolling by scroll bar
        float dist = _movePnt.y - location.y;
        
        // scrolling by Finger
        //float dist = location.y - _movePnt.y
        
        // Update SKSpriteNode's Texture by scrolling result
        [self retexture:dist];
        
        // Update current moving point
        _movePnt = location;
        


    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
    }
     */
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */

}


// Update SKSpriteNode's Texture by scrolling result
-(void) retexture:(float) dist
{
    _scrollPnt.y += dist;
    NSLog(@"_textSize.h = %f", _textSize.height);
    
    NSLog(@"scroll Poition = %@", NSStringFromCGPoint(_scrollPnt));
    if (_scrollPnt.y <= 0) {
        _scrollPnt.y -= dist;
        return;
    //} else if( _scrollPnt.y >= (_fullsize.height - _visiblesize.height) * 2.0f) {
    } else if( _scrollPnt.y >= (_textSize.height - _visiblesize.height) * 2.0f) {
        _scrollPnt.y -= dist;
        return;
    }
    
    UIImage *image = [self getSubImage:_fullImage ByPosition:_scrollPnt AndSize:_visiblesize];
    SKTexture *texture = [SKTexture textureWithImage:image];
    _showNode.texture = texture;
}


// Create Sub-Image by Scrolling
-(UIImage *) getSubImage:(UIImage *)fullImage ByPosition:(CGPoint)pos AndSize:(CGSize)size
{
    // 1. Begin Image Context
    //  you must use WithOptions for setting scale(the third parameter) for Retina 
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    
    // 2. Get Current Context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context == NULL) {
        NSLog(@"Error: No Context to flip");
        return nil;
    }
    
    // 3. Adjust Coordinate Origin
    //  UIKit origin  is Top-Left;
    //  Core-Graphics is Bottom-Left, so we need to flip
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    transform = CGAffineTransformTranslate(transform, 0.0f, -size.height);
    CGContextConcatCTM(context, transform);
    
    NSLog(@"image size = %@", NSStringFromCGSize(fullImage.size));
    NSLog(@"size = %@", NSStringFromCGSize(size));
    
    // 4. Point and Pixels convert
    //  UIKit is in  Points
    //  Quartz is in Pixels
    //  on Retina screen, Point = 2 Pixels
    //  now we need to convert UIImage to CGImageRef to use CG Drawing Operation
    //  so subImageRef's size need to multiply by 2 (from pixel to point)
    CGRect subImageArea = CGRectMake(pos.x, pos.y, size.width*2, size.height*2);
    CGImageRef fullImageRef = fullImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(fullImageRef, subImageArea);
    
    CGRect subRect = CGRectMake(0, 0, size.width, size.height);
    CGContextDrawImage(context, subRect, subImageRef);
    
    UIImage *subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
    
}

// Create a Full Image for scroll
- (UIImage *) getFullImageTextBySize:(CGSize)size
{
    NSString *text = @"盧雲 為天地立心、為生民立命、為往聖繼絕學、為萬世開太平；天地之間最後的聖光 山東濰縣人，自幼父母雙亡，苦讀自學，學得一身經世致用的好學問，卻不幸屢試不第，淪落到靠做酒肆店夥為生。\n在做酒肆店夥時為當地地痞陷害，又被貪官誣指為殺人犯，旦夕將死，適逢怒蒼山殘黨(太湖雙龍寨)劫獄救人，才得以脫困而出。逃獄之後，盧雲以拉縴為業，順運河而下直至揚州，在揚州入景泰朝大臣顧嗣源家為僮僕，後於一偶然機會(對聯)為顧所賞識，被網羅為顧府幕僚，嗣源獨生女顧倩兮亦對盧雲深有好感。\n同時，盧雲並獲得了武當派的練氣之法，以及怒蒼山殘黨陸孤瞻的拳法傳授，結合兩者，在武藝上自創 無絕心法 ，後遂成武林 心體氣術勢 五大宗中(練)氣一派的大師。盧雲雖受嗣源與倩兮賞識，但仍是有案在身之人，以此為顧府二姨娘所逐，再次淪落江湖，以賣山東大滷麵為生;當他在北京賣大滷麵時無意間救了被崑崙諸劍追殺的伍定遠，後又為征北大都督柳昂天麾下驍將秦仲海所賞識，得以出使西域和番，最後並在仲海的幫助下洗刷冤情，成為景泰王朝的一甲狀元，並和心愛的倩兮定下婚約，但是套用二姨娘的話，盧雲這人天生帶煞，走到哪裡哪裡就有人要倒霉，盧雲任狀元之後不久，朝中生變，武英景泰兩帝鬥爭日趨兇險，返京結婚的盧雲適逢柳昂天壽誕前往赴宴，卻遇上柳氏抄家滅門的慘禍，為保柳氏遺孤神秀，盧雲北走怒蒼山投秦仲海，卻為保嬰兒擋了仲海一刀，自此額頭上多了一隻眼，不得已只好南走貴州，卻又遇上朝廷殺手追逼，最後墜入白水大瀑布中，直到十年之後才因為無知少女瓊芳的援助得以脫困。\n脫困之後的盧雲，武功之高世所罕有（他歷經天下第一大水瀑的磨難，本已悟得崑崙絕學的劍芒，嗣後更悟得華山派的仁劍），但是身上卻一毛錢也沒有了，只好靠瓊芳的「不樂之捐」，買了個麵攤又幹起那賣山東大滷麵的行當，偏偏賣到了北京，一見自己相思十年的戀人顧倩兮，雖然仍然愛著她，卻不敢相認，只能默默的關注，以至因倉皇躲避丟掉了麵攤。\n之後因緣際會下，見到了傳說中的魔刀，更險些被魔刀激起天地萬物殺一空的戾氣……目前對盧雲最重要的，或許只剩下他對顧倩兮千纏萬繞的思念。";
 
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping; //To get multi-line
    paragraphStyle.alignment = SKLabelHorizontalAlignmentModeLeft;
    paragraphStyle.lineSpacing = 1;
    
    //Create the font using the values set by the user
    UIFont *font = [UIFont fontWithName:self.fontName size:self.fontSize];
    
    if (!font) {
        font = [UIFont fontWithName:@"Helvetica" size:self.fontSize];
        NSLog(@"The font you specified was unavailable. Defaulted to Helvetica.");
    }
    
    //Create our textAttributes dictionary that we'll use when drawing to the graphics context
    NSMutableDictionary *textAttributes = [NSMutableDictionary dictionary];
    
    //Font Name and size
    [textAttributes setObject:font forKey:NSFontAttributeName];
    
    //Line break mode and alignment
    [textAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    //Font Color
    [textAttributes setObject:self.fontColor forKey:NSForegroundColorAttributeName];
    
    
    // if paragraphWidth is not be set, set to default
    //_paragraphWidth = size.width;
    
    //Calculate the size that the "text" will take up, given our options.  We use the full screen size for the bounds
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(size.width, size.height)
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                                      attributes:textAttributes
                                         context:nil];
    
    
    //iOS7 uses fractional size values.  So we needed to ceil it to make sure we have enough room for display.
    textRect.size.height = ceil(textRect.size.height);
    textRect.size.width = ceil(textRect.size.width);
    
    _textSize = textRect.size;
    
    //Mac build crashes when the size is nothing - this also skips out on unecessary cycles below when the size is nothing
    if (textRect.size.width == 0 || textRect.size.height == 0) {
        return Nil;
    }
    
    textRect.size.height = ceil(textRect.size.height);
    textRect.size.width = ceil(textRect.size.width);
    
    //Mac build crashes when the size is nothing - this also skips out on unecessary cycles below when the size is nothing
    if (textRect.size.width == 0 || textRect.size.height == 0) {
        assert(1 && @"textRect size should not be zero");
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(textRect.size, NO, 0.0);
    [text drawInRect:textRect withAttributes:textAttributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return image;
}

-(UIImage *) getFullImageBySize:(CGSize)size
{
     // 1.
     UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
     
     //UIImage *test = [UIImage imageNamed:@"Spaceship"];
     UIImage *test = [UIImage imageNamed:@"Level1Empty"];
     NSLog(@"sub Image size = %@", NSStringFromCGSize(test.size));
     //test = [self scaleImage:test toScale:0.5];
     int maxW = size.width / (test.size.width + 20);
     int maxH = size.height / (test.size.height + 20);
     NSLog(@"size.h = %f, text.size.h = %f", size.height, test.size.height);
     NSLog(@"maxH = %d", maxH);
     int maxNum = maxW * maxH;
     
     
     for (int i = 0; i < maxNum; i++) {
     
     int m = i / maxW;
     int n = i % maxW;
     
     //UIImage *sprite = [UIImage imageNamed:@"Spaceship"];
     NSString *name = [NSString stringWithFormat:@"Level%dEmpty", i+1];
     UIImage *sprite = [UIImage imageNamed:name];
     //sprite = [self scaleImage:sprite toScale:0.5];
     [sprite drawAtPoint:CGPointMake((sprite.size.width + 20) * n + 20,
     (sprite.size.height + 20) * m + 20)];
     
     }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}



// Scale Image by Scale-Ratio
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
                                
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
    
}

@end
