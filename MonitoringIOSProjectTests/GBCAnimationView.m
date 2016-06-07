//
//  GBCAnimationImageView.m
//  PNGAnimatorDemo
//
//  Created by camacholaverde on 9/25/14.
//
//

#import "GBCAnimationView.h"

@interface GBCAnimationView()

//** private properties **

@property(nonatomic, strong) UIImageView *imageView;
///
@property (nonatomic, copy) NSArray *animationData;
///
@property (nonatomic, retain)NSTimer *animationTimer;
///
@property (nonatomic, assign)NSInteger animationStep;
///
@property (nonatomic, assign)NSTimeInterval animationDuration;

@property(nonatomic, strong) NSMutableArray *visualConstraints;

@end

@implementation GBCAnimationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [self addSubview:self.imageView];
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

-(NSMutableArray *) visualConstraints{
    if (!_visualConstraints) {
        _visualConstraints = [[NSMutableArray alloc] init];
    }
    return _visualConstraints;
}

-(void)layoutSubviews{
    [super layoutSubviews];

}

-(void)updateConstraints{
    NSLog(@"updating constraints");
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1
                                                                   constant:0.0];
    [self.visualConstraints addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1
                                               constant:0];
     [self.visualConstraints addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1
                                               constant:0];
    [self.visualConstraints addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1
                                               constant:0];
    [self.visualConstraints addObject:constraint];
    
    
    [self addConstraints:self.visualConstraints];
    
    [super updateConstraints];
}


-(UIImageView *)imageView{
    if (!_imageView ) {
        _imageView =[[UIImageView alloc] initWithFrame:self.frame];
    }
    return _imageView;
}

-(void)setAnimationWithAnimationURLs:(NSArray *)animationURLs animationFrameDuration:(NSTimeInterval)frameDuration animationRepeatCount:(NSInteger)repeatCount{
    
    //Check if the animations URLs have changed. In that case, update them and set a flag to set the new animationData variable.
    if (![[NSSet setWithArray:self.animationURLs] isEqualToSet:[NSSet setWithArray:animationURLs]]) {
        self.animationURLs = animationURLs;
        //The URLs are different or were not set. Load the animationData.
        [self loadAnimationData];
    }
    self.animationFrameDuration = frameDuration;
    self.animationRepeatCount = repeatCount;
    
    NSAssert([self.animationURLs count] > 1, @"animationURLs must include at least 2 urls");
    
    [self setupAnimation];
}


+(GBCAnimationView*)animationImageViewWithURLs:(NSArray*)animationURLs
                                      frameDuration:(NSTimeInterval)frameDuration
                                        repeatCount:(NSInteger)repeatCount{
    
    return [[GBCAnimationView alloc] initWithAnimationURLs:animationURLs animationFrameDuration:frameDuration animationRepeatCount:repeatCount];
}

+ (NSArray*) arrayWithNumberedNames:(NSString*)filenamePrefix
                         rangeStart:(NSInteger)rangeStart
                           rangeEnd:(NSInteger)rangeEnd
                       suffixFormat:(NSString*)suffixFormat
{
    NSMutableArray *numberedNames = [[NSMutableArray alloc] initWithCapacity:40];
    
    for (int i = (int)rangeStart; i <= rangeEnd; i++) {
        NSString *suffix = [NSString stringWithFormat:suffixFormat, i];
        NSString *filename = [NSString stringWithFormat:@"%@%@", filenamePrefix, suffix];
        
        [numberedNames addObject:filename];
    }
    
    NSArray *newArray = [NSArray arrayWithArray:numberedNames];
    return newArray;
}


+ (NSArray*) arrayWithResourcePrefixedURLs:(NSArray*)inNumberedNames
{
    NSMutableArray *URLs = [[NSMutableArray alloc] initWithCapacity:[inNumberedNames count]];
    NSBundle* appBundle = [NSBundle mainBundle];
    
    for ( NSString* path in inNumberedNames) {
        NSString* resPath = [appBundle pathForResource:path ofType:nil];
        NSURL* aURL = [NSURL fileURLWithPath:resPath];
        
        [URLs addObject:aURL];
    }
    
    NSArray *newArray = [NSArray arrayWithArray:URLs];
    return newArray;
}


//This is going to be the designated initializer. This method should be the setup method in order to use it from a storyboard
-(instancetype)initWithAnimationURLs:(NSArray*)animationURLs animationFrameDuration:(NSTimeInterval)frameDuration animationRepeatCount:(NSInteger)repeatCount{
    if (self = [super init]) {
        self.animationURLs = animationURLs;
        self.animationFrameDuration = frameDuration;
        self.animationRepeatCount = repeatCount;
        
        //Validations
        NSAssert([animationURLs count] > 1, @"animationURLs must include at least 2 urls");
        [self setupAnimation];
    }
    return self;
}


-(void)loadAnimationData{
    // Load animationData by reading from animationURLs
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithCapacity:[self.animationURLs count]];
    
    NSMutableArray *muArray = [NSMutableArray arrayWithCapacity:[self.animationURLs count]];
    for ( NSURL* aURL in self.animationURLs ) {
        NSString *urlKey = aURL.path;
        NSData *dataForKey = [dataDict objectForKey:urlKey];
        
        if (dataForKey == nil) {
            dataForKey = [NSData dataWithContentsOfURL:aURL];
            NSAssert(dataForKey, @"dataForKey");
            
            [dataDict setObject:dataForKey forKey:urlKey];
        }
        
        [muArray addObject:dataForKey];
    }
    self.animationData = [NSArray arrayWithArray:muArray];
}

-(void)setupAnimation{
    
    NSAssert(self.animationData, @"Animation data must not be nil ");
    int numFrames = (int)[self.animationURLs count];
    float duration = self.animationFrameDuration * numFrames;
    
    self->_animationNumFrames = numFrames;
    self.animationDuration = duration;
    
    // Display first frame of image animation
    
    self.animationStep = 0;
    
    [self animationShowFrame: self.animationStep];
    
    self.animationStep = self.animationStep + 1;
    
    if (self.animationAudioURL != nil) {
        AVAudioPlayer *avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.animationAudioURL
                                                                         error:nil];
        
        NSAssert(avPlayer, @"AVAudioPlayer could not be allocated");
        self.avAudioPlayer = avPlayer;
        
        [self.avAudioPlayer prepareToPlay];
    }
    
}

- (void) startAnimating
{
    self.animationTimer = [NSTimer timerWithTimeInterval: self.animationFrameDuration
                                                  target: self
                                                selector: @selector(animationTimerCallback:)
                                                userInfo: NULL
                                                 repeats: TRUE];
    
    [[NSRunLoop currentRunLoop] addTimer: self.animationTimer forMode: NSDefaultRunLoopMode];
    
    self.animationStep = 0;
    
    if (self.avAudioPlayer != nil)
        [self.avAudioPlayer play];
    
    // Send notification to object(s) that regestered interest in a start action
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ImageAnimatorDidStartNotification
     object:self];	
}


- (void) stopAnimating
{
    if (![self hasOngoingAnimation])
        return;
    
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    
    self.animationStep = self.animationNumFrames - 1;
    [self animationShowFrame: self.animationStep];
    
    if (self.avAudioPlayer != nil) {
        [self.avAudioPlayer stop];
        self.avAudioPlayer.currentTime = 0.0;
        self->lastReportedTime = 0.0;
    }
    
    // Send notification to object(s) that regestered interest in a stop action
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ImageAnimatorDidStopNotification
     object:self];	
}

- (BOOL) hasOngoingAnimation
{
    return (self.animationTimer != nil);
}

- (BOOL) isAnimating
{
    return (self.animationTimer != nil);
}

- (void) animationTimerCallback: (NSTimer *)timer {
    if (![self isAnimating])
        return;
    
    NSTimeInterval currentTime;
    NSUInteger frameNow;
    
    if (self.avAudioPlayer == nil) {
        self.animationStep += 1;
        
        //		currentTime = animationStep * animationFrameDuration;
        frameNow = self.animationStep;
    } else {
        currentTime = self.avAudioPlayer.currentTime;
        frameNow = (NSInteger) (currentTime / self.animationFrameDuration);
    }
    
    // Limit the range of frameNow to [0, SIZE-1]
    if (frameNow <= 0) {
        frameNow = 0;
    } else if (frameNow >= self.animationNumFrames) {
        frameNow = self.animationNumFrames - 1;
    }
    
    [self animationShowFrame: frameNow];
    //	animationStep = frameNow + 1;
    
    if (self.animationStep >= self.animationNumFrames) {
        [self stopAnimating];
        
        // Continue to loop animation until loop counter reaches 0
        
        if (self.animationRepeatCount > 0) {
            self.animationRepeatCount = self.animationRepeatCount - 1;
            [self startAnimating];
        }
    }
}


- (void) animationShowFrame: (NSInteger) frame {
    if ((frame >= self.animationNumFrames) || (frame < 0))
        return;
    
    NSData *data = [self.animationData objectAtIndex:frame];
    UIImage *img = [UIImage imageWithData:data];
    [self.imageView setImage:img];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.animationRepeatCount = 0;
    [self stopAnimating];
}

@end
