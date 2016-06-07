//
//  GBCAnimationImageView.h
//  PNGAnimatorDemo
//
//  Created by camacholaverde on 9/25/14.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>

#define ImageAnimator15FPS (1.0/15)
#define ImageAnimator12FPS (1.0/12)
#define ImageAnimator10FPS (1.0/10)
#define ImageAnimator5FPS (1.0/5)

#define ImageAnimatorDidStartNotification @"ImageAnimatorDidStartNotification"
#define ImageAnimatorDidStopNotification @"ImageAnimatorDidStopNotification"


@interface GBCAnimationView : UIView{
    
@private
    NSTimeInterval lastReportedTime;
    
}

//** public properties **
///
@property(nonatomic, copy) NSArray *animationURLs;
///
@property(nonatomic, assign) NSTimeInterval animationFrameDuration;
///
@property(nonatomic, readonly) NSInteger animationNumFrames;
///
@property(nonatomic, assign) NSInteger animationRepeatCount;
///
@property(nonatomic, assign)UIImageOrientation animationOrientation;
///
@property(nonatomic, retain) NSURL *animationAudioURL;
///
@property (nonatomic, retain) AVAudioPlayer *avAudioPlayer;



//** public methods **

///Constructor
+ (GBCAnimationView *) animationImageViewWithURLs:(NSArray*)animationURLs frameDuration:(NSTimeInterval)frameDuration repeatCount:(NSInteger)repeatCount;

+ (NSArray*) arrayWithNumberedNames:(NSString*)filenamePrefix
                         rangeStart:(NSInteger)rangeStart
                           rangeEnd:(NSInteger)rangeEnd
                       suffixFormat:(NSString*)suffixFormat;


+ (NSArray*) arrayWithResourcePrefixedURLs:(NSArray*)inNumberedNames;

-(void)setAnimationWithAnimationURLs:(NSArray *)animationURLs animationFrameDuration:(NSTimeInterval)frameDuration animationRepeatCount:(NSInteger)repeatCount;

-(void) startAnimating;

- (void) stopAnimating;

- (BOOL) hasOngoingAnimation;

- (void) animationShowFrame: (NSInteger) frame;

@end
