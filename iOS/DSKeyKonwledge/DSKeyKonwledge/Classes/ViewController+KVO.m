//
//  ViewController+KVOTest.m
//  DSKeyKonwledge
//
//  Created by davis on 2021/2/19.
//

#import "ViewController+KVO.h"
#import "objc/runtime.h"
@implementation ViewController (KVO)
- (void)initKVO{
    self.message1 = [[DSMessage alloc]init];
    self.message2 = [[DSMessage alloc]init];
    
    NSLog(@"添加KVO之前:%p",[self.message1 methodForSelector:@selector(setText:)]);
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.message1 addObserver:self forKeyPath:@"text" options:options context:@"123"];
    NSLog(@"添加KVO之后:%p",[self.message1 methodForSelector:@selector(setText:)]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //self.message1->isa :  NSKVONotifying_DSMessage
    //self.message2->isa :  DSMessage
    self.message1.text = @"1111";
    self.message2.text = @"2222";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"123") {
        NSLog(@"监听到%@的%@属性改变 - %@ - %@", object,keyPath,change,context);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
