#import "ImagePickersPlugin.h"
#import <Photos/Photos.h>
//#import <ZLPhotoBrowser/ZLPhotoBrowser.h>
//#import <ZLPhotoBrowser/ZLPhotoBrowser-umbrella.h>


#import "AKGallery.h"
#import "PlayTheVideoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking/AFNetworking.h>
@import ZLPhotoBrowser.Swift;

#define Frame_rectStatus ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define Frame_rectNav (self.navigationController.navigationBar.frame.size.height)
#define Frame_NavAndStatus (self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height)
#define CXCHeightX   (([UIScreen mainScreen].bounds.size.height>=812.00)?([[UIScreen mainScreen] bounds].size.height-34):([[UIScreen mainScreen] bounds].size.height)/1.000)
#define CXCWeight    (([[UIScreen mainScreen] bounds].size.width)/1.000)
@interface ImagePickersPlugin (){
    BOOL isShowGif;
}
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation ImagePickersPlugin
static NSString *const CHANNEL_NAME = @"flutter/image_pickers";

+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME
                                                                binaryMessenger:[registrar messenger]];
    ImagePickersPlugin *instance = [[ImagePickersPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}
-(UIColor*)stringChangeColor:(NSDictionary*)colorString{
    int alph =[[colorString objectForKey:@"a"] intValue];
    int red =[[colorString objectForKey:@"r"] intValue];
    int green =[[colorString objectForKey:@"g"] intValue];
    int blue =[[colorString objectForKey:@"b"] intValue];
    return [UIColor colorWithRed:red/255.00 green:green/255.00 blue:blue/255.00 alpha:alph/255.00];
}
-(void)colorChange:(NSDictionary*)colorString configuration:(ZLPhotoUIConfiguration*)configuration {
    
    
    UIColor* colorType =[self stringChangeColor:colorString];
    int light =[[colorString objectForKey:@"l"] intValue];
    
    /// ???????????????????????????
    [ZLPhotoUIConfiguration default].albumListBgColor =[UIColor whiteColor];
    [ZLPhotoUIConfiguration default].previewVCBgColor =[UIColor whiteColor];

    
    /// ???????????????
    [ZLPhotoUIConfiguration default].separatorColor =[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:0.98];
    /// ?????????????????????
    [ZLPhotoUIConfiguration default].thumbnailBgColor =[UIColor whiteColor];
    
    /// ??????????????????????????? ??????/??????/?????? ???????????????
    
    
    if(light<=179){
        /// ???????????????
        [ZLPhotoUIConfiguration default].navBarColor = colorType;
        /// ??????????????????
        [ZLPhotoUIConfiguration default].navTitleColor = [UIColor whiteColor];
        [ZLPhotoUIConfiguration default].navBarColorOfPreviewVC = colorType;

        
        ///  ????????????????????? ????????? ??????????????????
        [ZLPhotoUIConfiguration default].bottomToolViewBtnNormalTitleColor = [UIColor whiteColor];
        /// ????????????????????? ????????? ??????????????????
        [ZLPhotoUIConfiguration default].bottomToolViewBtnNormalBgColor =colorType;
        /// ????????????????????? ???????????? ??????????????????
        [ZLPhotoUIConfiguration default].bottomToolViewBtnDisableBgColor =colorType;
        [ZLPhotoUIConfiguration default].bottomToolViewBtnNormalBgColorOfPreviewVC =colorType;

        /// ????????????????????????????????????????????????
        [ZLPhotoUIConfiguration default].cameraRecodeProgressColor =colorType;
        /// ?????????????????????index background color
        [ZLPhotoUIConfiguration default].indexLabelBgColor =colorType;
        /// ?????????????????????
        [ZLPhotoUIConfiguration default].bottomToolViewBgColor = colorType;
        //??????????????????
        [ZLPhotoUIConfiguration default].navEmbedTitleViewBgColor = colorType;
    }else{
        /// ???????????????
        [ZLPhotoUIConfiguration default].navBarColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        /// ??????????????????
        [ZLPhotoUIConfiguration default].navTitleColor = [UIColor blackColor];
        [ZLPhotoUIConfiguration default].navBarColorOfPreviewVC = [UIColor blackColor];

        /// ????????????????????? ????????? ??????????????????
        [ZLPhotoUIConfiguration default].bottomToolViewBtnNormalBgColor =[UIColor blackColor];
        /// ????????????????????? ???????????? ??????????????????
        [ZLPhotoUIConfiguration default].bottomToolViewBtnDisableBgColor =[UIColor blackColor];
        /// ????????????????????????????????????????????????
        [ZLPhotoUIConfiguration default].cameraRecodeProgressColor =[UIColor blackColor];
        /// ?????????????????????index background color
        [ZLPhotoUIConfiguration default].indexLabelBgColor =[UIColor blackColor];
        /// ?????????????????????
        [ZLPhotoUIConfiguration default].bottomToolViewBgColor = [UIColor whiteColor];
        ///??????????????????
        [ZLPhotoUIConfiguration default].navEmbedTitleViewBgColor = [UIColor whiteColor];
    }
    /// ?????????????????? ??????title??????
    [ZLPhotoUIConfiguration default].albumListTitleColor = [UIColor blackColor];
    [ZLPhotoUIConfiguration default].navViewBlurEffectOfPreview =[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [ZLPhotoUIConfiguration default].navViewBlurEffectOfAlbumList =[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [ZLPhotoUIConfiguration default].bottomViewBlurEffectOfPreview =[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [ZLPhotoUIConfiguration default].bottomViewBlurEffectOfAlbumList =[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    
}
-(void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result
{
    resultBack =result;
    if([@"getPickerPaths" isEqualToString:call.method]){
        NSDictionary *dic = call.arguments;
        NSInteger selectCount =[[dic objectForKey:@"selectCount"] integerValue];//???????????????
        NSInteger compressSize =[[dic objectForKey:@"compressSize"] integerValue]*1024;//??????
        
        NSString *galleryMode =[NSString stringWithFormat:@"%@",[dic objectForKey:@"galleryMode"]];//??????????????????image video
        BOOL enableCrop =[[dic objectForKey:@"enableCrop"] boolValue];//????????????
        if(selectCount>1){
            enableCrop =NO;
        }
        NSInteger height =[[dic objectForKey:@"height"] integerValue];//????????????
        NSInteger width =[[dic objectForKey:@"width"] integerValue];//????????????
        BOOL showCamera =[[dic objectForKey:@"showCamera"] boolValue];//???????????????
        isShowGif =[[dic objectForKey:@"showGif"] boolValue];//????????????gif
        NSString *cameraMimeType =[dic objectForKey:@"cameraMimeType"];//type   photo video ?????????????????????????????????????????????????????????????????????
        ZLPhotoConfiguration *configuration =[ZLPhotoConfiguration default];
        configuration.maxSelectCount = selectCount;//????????????????????????
        configuration.allowMixSelect = NO;//?????????????????????
        configuration.allowTakePhotoInLibrary =showCamera;//?????????????????????
        configuration.allowSelectOriginal =NO;//???????????????
        configuration.allowEditImage =enableCrop;
        configuration.cellCornerRadio =5;
        configuration.editImageConfiguration.tools_objc=@[@1];
        configuration.editImageConfiguration.clipRatios=@[[[ZLImageClipRatio alloc]initWithTitle:@"" whRatio:((float)width/(float)height) isCircle:false]];
        
        if(cameraMimeType) {
            //cameraMimeType//type   photo video
            
            ZLPhotoUIConfiguration *configurationUI =[ZLPhotoUIConfiguration default];
            [self colorChange:[dic objectForKey:@"uiColor"] configuration:configurationUI];
            
            ZLCustomCamera *camera = [[ZLCustomCamera alloc] init];
            
            if ([cameraMimeType isEqualToString:@"photo"]) {
                configuration.allowTakePhoto =YES;
                configuration.allowRecordVideo =NO;
                configuration. allowSelectImage =YES;
                configuration.allowSelectVideo =NO;
            }else{
                configuration.allowTakePhoto = NO;
                configuration.allowRecordVideo = YES;
                configuration. allowSelectImage =NO;
                configuration.allowSelectVideo =YES;
            }


            configuration.maxSelectVideoDuration = 30000;
            configuration.maxRecordDuration =60;
            [[UIApplication sharedApplication].delegate.window.rootViewController  showDetailViewController:camera sender:nil];
            camera.takeDoneBlock = ^(UIImage *image, NSURL *videoUrl){
                NSLog(@"%@",videoUrl);
                NSLog(@"%@",image);
                if (image) {
                    NSData *data2=UIImageJPEGRepresentation(image , 1);
                    float size =(float)compressSize/data2.length;
                    if(size>=1){
                        size =1;
                    }
                    data2=UIImageJPEGRepresentation(image, size);
                    NSLog(@"_____??????__%ld",data2.length);
                    UIImage *imageFF =[UIImage imageWithData:data2];
                    //?????????????????????
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyyMMddHHmmss";
                    int  x = arc4random() % 10000;
                    NSString *name = [NSString stringWithFormat:@"%@01%d",[formatter stringFromDate:[NSDate date]],x];
                    NSString  *jpgPath = [NSHomeDirectory()     stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.%@",name,[self imageType:data2]]];
                    //???????????????
                    [UIImageJPEGRepresentation(imageFF,1) writeToFile:jpgPath atomically:YES];
                    NSDictionary *photoDic =@{
                        @"thumbPath":[NSString stringWithFormat:@"%@",jpgPath],
                        @"path":[NSString stringWithFormat:@"%@",jpgPath],
                    };
                    //????????????
                    NSArray *arr =@[photoDic];
                    result(arr);
                    return ;
                }else{
                    NSURL *url =videoUrl;
                    NSString *subString = [url.absoluteString substringFromIndex:7];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyyMMddHHmmss";
                    int  x = arc4random() % 10000;
                    NSString *name = [NSString stringWithFormat:@"%@%d",[formatter stringFromDate:[NSDate date]],x];
                    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
                    UIImage *img = [self getImage:subString];
                    NSData *data2=UIImageJPEGRepresentation(img , 1);
                    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@.%@",NSHomeDirectory(),name,[self imageType:data2]];
                    
                    [UIImageJPEGRepresentation(img,1) writeToFile:aPath3 atomically:YES];
                    
                    NSDictionary *photoDic = @{
                        @"thumbPath":[NSString stringWithFormat:@"%@",aPath3],
                        @"path":[NSString stringWithFormat:@"%@",subString],
                    };
                    NSArray *arr =@[photoDic];
                    result(arr);
                    return ;
                }
            };
            
        }else{
            ZLPhotoPreviewSheet *ac = [[ZLPhotoPreviewSheet alloc] init];
            configuration.maxSelectCount = selectCount;//????????????????????????
            configuration.allowMixSelect = NO;//?????????????????????
            configuration.allowTakePhotoInLibrary =showCamera;//?????????????????????
            configuration.allowSelectOriginal =NO;//???????????????
            configuration.allowEditImage =enableCrop;
            configuration.cellCornerRadio =5;
            configuration.editImageConfiguration.clipRatios=@[[[ZLImageClipRatio alloc]initWithTitle:@"" whRatio:((float)width/(float)height) isCircle:false]];
            configuration.allowSelectGif = isShowGif;
            if ([galleryMode isEqualToString:@"image"]) {
                configuration.allowTakePhoto =YES;
                configuration.allowRecordVideo =NO;
                configuration. allowSelectImage =YES;
                configuration.allowSelectVideo =NO;
            }else{
                configuration. allowSelectImage =NO;
                configuration.allowSelectVideo =YES;
                configuration.allowTakePhoto =NO;
                configuration.allowRecordVideo =YES;
            }
            
            ZLPhotoUIConfiguration *configurationUI =[ZLPhotoUIConfiguration default];
            
            [self colorChange:[dic objectForKey:@"uiColor"] configuration:configurationUI];
            [ac showPhotoLibraryWithSender:[UIApplication sharedApplication].delegate.window.rootViewController];
            NSMutableArray *arr =[[NSMutableArray alloc]init];
            
            ac.cancelBlock = ^{
                NSArray *arr =@[];
                result(arr);
            };
            
            ac.selectImageBlock = ^(NSArray<ZLResultModel *> * modelList, BOOL isB) {
                //your codes
                if (![galleryMode isEqualToString:@"image"]) {
                    
                    for (NSInteger i = 0; i < modelList.count; i++) {
                        // ?????????????????????PHAsset???
                        PHAsset *phAsset = modelList[i].asset;
                        PHImageManager *manage =[[PHImageManager alloc]init];
                        PHImageRequestOptions *option =[[PHImageRequestOptions alloc]init];
                        option.networkAccessAllowed =YES;
                        //??????
                        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                        options.version = PHVideoRequestOptionsVersionCurrent;
                        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                        PHImageManager *manager = [PHImageManager defaultManager];
                        [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                            
                            AVURLAsset *urlAsset = (AVURLAsset *)asset;
                            NSURL *url = urlAsset.URL;
                            NSString *subString = [url.absoluteString substringFromIndex:7];
                            
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            formatter.dateFormat = @"yyyyMMddHHmmss";
                            int  x = arc4random() % 10000;
                            NSString *name = [NSString stringWithFormat:@"%@%d",[formatter stringFromDate:[NSDate date]],x];
                            NSString  *jpgPath = [NSHomeDirectory()     stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
                            UIImage *img = [self getImage:subString]  ;
                            //???????????????
                            [UIImageJPEGRepresentation(img,1.0) writeToFile:jpgPath atomically:YES];
                            NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),name];
                            
                            //????????????
                            [arr addObject:@{
                                @"thumbPath":[NSString stringWithFormat:@"%@",aPath3],
                                @"path":[NSString stringWithFormat:@"%@",subString],
                            }];
                            //NSLog(@"%@",arr);
                            if (arr.count==modelList.count) {
                                result(arr);
                                return ;
                                
                            }
                            
                        }];
                    }
                }else{
                    if (modelList.count>0) {
                        [self saveImageView:0 imagePHAsset:modelList arr:arr  compressSize:compressSize result:(FlutterResult)result];
                    }
                    
                }
                
            };
            
            [ac showPhotoLibraryWithSender:[UIApplication sharedApplication].delegate.window.rootViewController];
        }
        
    } else if ([@"previewImages" isEqualToString:call.method]){
        
        NSDictionary *dic = call.arguments;
        NSMutableArray *arr =[[NSMutableArray alloc]init];
        NSArray *imageArr =[dic objectForKey:@"paths"];
        NSInteger initIndex =[[dic objectForKey:@"initIndex"] intValue];
        
        for (int i=0; i<imageArr.count; i++) {
            NSString *imgString  =imageArr[i];
            if ([[NSString stringWithFormat:@"%@",imgString] containsString:@"http"]||[imgString containsString:@"GIF"]||[[NSString stringWithFormat:@"%@",imgString] containsString:@"gif"]) {
                AKGalleryItem* item = [AKGalleryItem itemWithTitle:@"????????????" url:[NSString stringWithFormat:@"%@",imgString] img:nil];
                [arr addObject:item];
                
            }else if ([[NSString stringWithFormat:@"%@",imgString] containsString:@"var/"]||[[NSString stringWithFormat:@"%@",imgString] containsString:@"CoreSimulator/"]){
                
                UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@",imgString]]];
                AKGalleryItem* item = [AKGalleryItem itemWithTitle:@"????????????" url:nil img:image];
                [arr addObject:item];
            }
            if (i==imageArr.count-1) {
                AKGallery* gallery = AKGallery.new;
                gallery.items=arr;
                gallery.modalPresentationStyle = 0;
                gallery.custUI=AKGalleryCustUI.new;
                gallery.selectIndex=initIndex;
                gallery.completion=^{
                };
                //show gallery
                gallery.modalPresentationStyle =UIModalPresentationFullScreen;
                [[UIApplication sharedApplication].delegate.window.rootViewController presentAKGallery:gallery animated:YES completion:nil];
            }
        }
    }
    else if ([@"previewImage" isEqualToString:call.method]){
        NSDictionary *dic = call.arguments;
        NSMutableArray *arr =[[NSMutableArray alloc]init];
        BOOL isOnline =false;///???????????????
        if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]] containsString:@"http"]) {
            isOnline =true;
        }else if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]] containsString:@"var/"]||[[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]] containsString:@"CoreSimulator/"]){
            isOnline =false;
        }else{
            return;
        }
        AKGalleryItem* item = [AKGalleryItem itemWithTitle:@"????????????" url:isOnline==true?([NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]]):nil img:isOnline==true?nil:([UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]]]])];
        [arr addObject:item];
        AKGallery* gallery = AKGallery.new;
        gallery.items=arr;
        gallery.custUI=AKGalleryCustUI.new;
        gallery.selectIndex=0;
        gallery.completion=^{
        };
        gallery.modalPresentationStyle =UIModalPresentationFullScreen;
        [[UIApplication sharedApplication].delegate.window.rootViewController presentAKGallery:gallery animated:YES completion:nil];
        
    }else if ([@"previewVideo" isEqualToString:call.method]){
        NSDictionary *dic = call.arguments;
        PlayTheVideoVC *vc =[[PlayTheVideoVC alloc]init];
        vc.modalPresentationStyle=0;
        vc.videoUrl =[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]];
        vc.modalPresentationStyle =UIModalPresentationFullScreen;
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:vc animated:YES completion:^{
            
        }];
        
    }else if ([@"saveByteDataImageToGallery" isEqualToString:call.method]){
        NSDictionary *dic = call.arguments;
        FlutterStandardTypedData *data =[dic objectForKey:@"uint8List"];
        UIImage *image=[UIImage imageWithData:data.data];
        __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
         {
            NSString *str =assetURL.absoluteString;
            NSString *string =@"://";
            NSRange range = [str rangeOfString:string];//?????????????????????
            if(range.location+range.length<str.length){
                str = [str substringFromIndex:range.location+range.length];
                if (error) {
                    
                }else{
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyyMMddHHmmss";
                    NSString *string;
                    NSString *subStr = @"&ext=";//???????????????
                    if ([str containsString:subStr])
                    {//??????????????????
                        NSRange subStrRange = [str rangeOfString:subStr];//????????????????????????range
                        NSInteger index = subStrRange.location + subStrRange.length;//????????????????????????????????????????????????????????????
                        NSString *restStr = [str substringFromIndex:index];
                        string =restStr;
                    }else{
                        string =@"png";
                    }
                    NSString *name = [NSString stringWithFormat:@"%@01.%@",[formatter stringFromDate:[NSDate date]],string];
                    
                    NSString  *jpgPath = [NSHomeDirectory()     stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
                    //???????????????
                    [UIImageJPEGRepresentation(image,1.0) writeToFile:jpgPath atomically:YES];
                    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),name];
                    
                    result(aPath3);
                }
            }
            
        }];
        
    }
    else if([@"saveImageToGallery" isEqualToString:call.method]){
        NSDictionary *dic = call.arguments;
        NSString *url =[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]];
        if ([url.lastPathComponent containsString:@"gif"]||[url.lastPathComponent containsString:@"GIF"]) {
            
            [self saveGifImage:url];
        }else{
            UIImage *img =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
            __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib writeImageToSavedPhotosAlbum:img.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
             {
                NSString *str =assetURL.absoluteString;
                NSString *string =@"://";
                NSRange range = [str rangeOfString:string];//?????????????????????
                if(range.location+range.length<str.length){
                    str = [str substringFromIndex:range.location+range.length];
                    if (error) {
                        
                    }else{
                        result([NSString stringWithFormat:@"/%@",str]);
                    }
                }
                
            }];
        }
        
        
    }else if([@"saveVideoToGallery" isEqualToString:call.method]){
        NSDictionary *dic = call.arguments;
        NSString *urlString =[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]];
        [self  playerDownload :urlString];
    }
}

-(void)saveImageView:(NSInteger)index imagePHAsset:(NSArray<ZLResultModel *> *)modelList arr:(NSMutableArray*)arr compressSize:(NSInteger)compressSize result:(FlutterResult)result{
    PHImageManager *manage =[[PHImageManager alloc]init];
    PHImageRequestOptions *option =[[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    if (index==modelList.count) {
        
        NSMutableArray *urlArr =[[NSMutableArray alloc]init];
        
        for (int i=0; i<arr.count; i++) {
            if(([arr[i] containsString:@"GIF"]||[arr[i] containsString:@"gif"])&&isShowGif){
                NSDictionary *photoDic =@{
                    @"thumbPath":[NSString stringWithFormat:@"%@",arr[i]],
                    @"path":[NSString stringWithFormat:@"%@",arr[i]],
                };
                //????????????
                [urlArr addObject:photoDic];
            }else{
                UIImage *imag =[UIImage imageWithContentsOfFile:arr[i]];
                NSData *data2=UIImageJPEGRepresentation(imag , 1.0);
                if (data2.length>compressSize) {
                    //??????
                    data2=UIImageJPEGRepresentation(imag, (float)(compressSize/data2.length));
                }
                NSLog(@"_______%ld",data2.length);
                UIImage *image =[UIImage imageWithData:data2];
                //?????????????????????
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyyMMddHHmmss";
                NSString*urlString =arr[i];
                NSString *endString =[urlString lastPathComponent];
                
                if([endString containsString:@"gif"]||[endString containsString:@"GIF"]){
                    endString =@".png";
                }
                NSString *name = [NSString stringWithFormat:@"%@01%@",[formatter stringFromDate:[NSDate date]],endString];
                NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
                //???????????????
                [UIImageJPEGRepresentation(image,1.0) writeToFile:jpgPath atomically:YES];
                NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),name];
                
                NSDictionary *photoDic =@{
                    @"thumbPath":[NSString stringWithFormat:@"%@",aPath3],
                    @"path":[NSString stringWithFormat:@"%@",aPath3],
                };
                //????????????
                [urlArr addObject:photoDic];
            }
            
        }
        result(urlArr);
        return ;
        
    }
    PHAsset *asset  =modelList[index].asset;
    
    index++;
    [manage requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        UIImage *im =[UIImage imageWithData:imageData];
        //NSLog(@"info==%@",info);
        NSURL * path = [info objectForKey:@"PHImageFileURLKey"];
        NSString *str =path.absoluteString;
        NSString *imageLast = [str lastPathComponent];
        if (!path) {
            imageLast =[NSString stringWithFormat:@"%ld.%@",imageData.length,[dataUTI pathExtension]];
            ;
        }
        
        if((![dataUTI containsString:@"gif"])&&(![dataUTI containsString:@"GIF"])){
            
            //??????????????????????????????????????????????????????
            //?????????
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *name = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],imageLast];
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
            //???????????????
            [UIImageJPEGRepresentation(im,1.0) writeToFile:jpgPath atomically:YES];
            NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),name];
            //????????????
            [arr addObject:[NSString stringWithFormat:@"%@",aPath3]];
            [self saveImageView:index imagePHAsset:modelList arr:arr  compressSize:compressSize result:result];
        }else{
            NSData *gifData = imageData;
            NSString *str =    [ImagePickersPlugin createFile:gifData suffix:@".gif"];
            [arr addObject:[NSString stringWithFormat:@"%@",str]];
            [self saveImageView:index imagePHAsset:modelList arr:arr  compressSize:compressSize result:result];
        }
        
    }];
    
}





#pragma mark //??????gif
- (void)saveGifDataImage:(NSData*)data {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
    }completionHandler:^(BOOL success,NSError*_Nullableerror) {
        if(success && !_Nullableerror) {
            NSLog(@"????????????");
        }else{
            NSLog(@"????????????");
        }
    }];
}
- (void)saveGifImage:(NSString*)urlString {
    
    NSURL *fileUrl = [NSURL URLWithString:urlString];
    
    [[[NSURLSession sharedSession] downloadTaskWithURL:fileUrl completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"%@", location);
        
        NSData *data = [NSData dataWithContentsOfFile:location.path];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
            
        }completionHandler:^(BOOL success,NSError*_Nullableerror) {
            if(success && !error) {
                NSLog(@"????????????");
            }else{
                NSLog(@"????????????");
            }
        }];
    }]resume];
    
}

#pragma //mark ???????????????URL????????????????????????
-(UIImage *)getImage:(NSString *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

- (void)playerDownload:(NSString *)url{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString  *fullPath = [NSString stringWithFormat:@"%@/%@.mp4", documentsDirectory,[NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]]];
    NSURL *urlNew = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlNew];
    NSURLSessionDownloadTask *task =
    [manager downloadTaskWithRequest:request
                            progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:fullPath];
    }
                   completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"%@",response);
        [self saveVideo:fullPath];
    }];
    [task resume];
}

//videoPath?????????????????????????????????????????????
- (void)saveVideo:(NSString *)videoPath{
    if (videoPath) {
        NSURL *url = [NSURL URLWithString:videoPath];
        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
        if (compatible)
        {   //????????????????????????
            UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}
//?????????????????????????????????
- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"??????????????????%@", error.localizedDescription);
        resultBack(@"fail");
    }
    else {
        NSLog(@"??????????????????");
        resultBack(@"success");
        
    }
}

+ (NSString *)createFile:(NSData *)data suffix:(NSString *)suffix {
    NSString *tmpPath = [self temporaryFilePath:suffix];
    if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:data attributes:nil]) {
        return tmpPath;
    } else {
        nil;
    }
    return tmpPath;
}
+ (NSString *)temporaryFilePath:(NSString *)suffix {
    NSString *fileExtension = [@"image_picker_%@" stringByAppendingString:suffix];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *tmpFile = [NSString stringWithFormat:fileExtension, guid];
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];
    return tmpPath;
}
-(NSString*)imageType:(NSData*)data{
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"JPEG";
        case 0x89:
            return @"PNG";
        case 0x47:
            return @"GIF";
        case 0x49:
        case 0x4D:
            return @"PNG";
        case 0x52: {
            return @"PNG";
        }
        case 0x00: {
            return @"PNG";
        }
        default:
            return @"PNG";
    }
    return @"PNG";
}
@end
