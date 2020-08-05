//
//  CCPointParticleEffect.m
//  007_粒子系统
//
//  Created by zsq on 2020/8/5.
//  Copyright © 2020 zsq. All rights reserved.
//

#import "CCPointParticleEffect.h"
#import "CCVertexAttribArrayBuffer.h"

//用于定义粒子属性的类型
typedef struct
{
    GLKVector3 emissionPosition;//发射位置
    GLKVector3 emissionVelocity;//发射速度
    GLKVector3 emissionForce;//发射重力
    GLKVector2 size;//发射大小
    GLKVector2 emissionTimeAndLife;//发射时间和寿命
}CCParticleAttributes;

//GLSL程序Uniform 参数
enum
{
    CCMVPMatrix,//MVP矩阵
    CCSamplers2D,//Samplers2D纹理
    CCElapsedSeconds,//耗时
    CCGravity,//重力
    CCNumUniforms//Uniforms个数
};

//属性标识符
typedef enum {
    CCParticleEmissionPosition = 0,//粒子发射位置
    CCParticleEmissionVelocity,//粒子发射速度
    CCParticleEmissionForce,//粒子发射重力
    CCParticleSize,//粒子发射大小
    CCParticleEmissionTimeAndLife,//粒子发射时间和寿命
} CCParticleAttrib;

@interface CCPointParticleEffect(){
    GLfloat elapsedSeconds;//耗时
    GLuint program;//程序
    GLint uniforms[CCNumUniforms];//Uniforms数组
}

//顶点属性数组缓冲区
@property (strong, nonatomic, readwrite)CCVertexAttribArrayBuffer  * particleAttributeBuffer;

//粒子个数
@property (nonatomic, assign, readonly) NSUInteger numberOfParticles;

//粒子属性数据
@property (nonatomic, strong, readonly) NSMutableData *particleAttributesData;

//是否更新粒子数据
@property (nonatomic, assign, readwrite) BOOL particleDataWasUpdated;

//加载shaders
- (BOOL)loadShaders;

//编译shaders
- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file;
//链接Program
- (BOOL)linkProgram:(GLuint)prog;

//验证Program
- (BOOL)validateProgram:(GLuint)prog;

@end

@implementation CCPointParticleEffect

@synthesize gravity;
@synthesize elapsedSeconds;
@synthesize texture2d0;
@synthesize transform;
@synthesize particleAttributeBuffer;
@synthesize particleAttributesData;
@synthesize particleDataWasUpdated;

- (instancetype)init{
    self = [super init];
    
    if (self != nil) {
        texture2d0 = [[GLKEffectPropertyTexture alloc] init];
        texture2d0.enabled = YES;
        texture2d0.name = 0;
        texture2d0.target = GLKTextureTarget2D;
        texture2d0.envMode = GLKTextureEnvModeReplace;
        
        transform = [[GLKEffectPropertyTransform alloc] init];
        
        gravity = CCDefaultGravity;
        
        elapsedSeconds = 0.0f;
        
        particleAttributesData = [NSMutableData data];
    }
    
    return self;
}

//获取粒子的属性值
- (CCParticleAttributes)particleAtIndex:(NSUInteger)anIndex
{
    //bytes:指向接收者内容的指针
    //获取粒子属性结构体内容 粒子[10]
    const CCParticleAttributes *particlesPtr = (const CCParticleAttributes *)[self.particleAttributesData bytes];
    
    //获取属性结构体中的某一个指标 粒子[1]
    return particlesPtr[anIndex];
}

//设置粒子的属性
- (void)setParticle:(CCParticleAttributes)aParticle
            atIndex:(NSUInteger)anIndex
{
  
    //1.
    CCParticleAttributes *particlesPtr =(CCParticleAttributes *) [self.particleAttributesData mutableBytes];
    
    //2.
    particlesPtr[anIndex] = aParticle;
    
    //3.
    self.particleDataWasUpdated = YES;
    
}

//添加一个粒子
- (void)addParticleAtPosition:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        force:(GLKVector3)aForce
                         size:(float)aSize
              lifeSpanSeconds:(NSTimeInterval)aSpan
          fadeDurationSeconds:(NSTimeInterval)aDuration;
{
    //1.创建一个新粒子
    CCParticleAttributes newParticle;
    
    //2.设置相关的参数
    newParticle.emissionPosition = aPosition;
    newParticle.emissionVelocity = aVelocity;
    newParticle.emissionForce = aForce;
    newParticle.size = GLKVector2Make(aSize, aDuration);
    newParticle.emissionTimeAndLife = GLKVector2Make(elapsedSeconds, elapsedSeconds+aSpan);
}


//默认重力加速度向量与地球的匹配
//{ 0，（-9.80665米/秒/秒），0 }假设+ Y坐标系的建立
//默认重力
const GLKVector3 CCDefaultGravity = {0.0f, -9.80665f, 0.0f};
@end
