//
//  VGlobal.c
//  RDPDFReader
//
//  Created by Radaee on 16/11/19.
//  Copyright © 2016年 radaee. All rights reserved.
//
#include "RDVGlobal.h"
#import "PDFObjc.h"

@implementation RDVLocker
-(id)init
{
    if( self = [super init] )
    {
        pthread_mutex_init( &mutex, NULL );
    }
    return self;
}
-(void)dealloc
{
    pthread_mutex_destroy( &mutex );
}
-(void)lock
{
    pthread_mutex_lock( &mutex );
}
-(void)unlock
{
    pthread_mutex_unlock( &mutex );
}
@end

@implementation RDVEvent
-(id)init
{
    if( self = [super init] )
    {
        pthread_cond_init( &m_event, NULL );
        pthread_mutex_init( &mutex, NULL );
        flags = 0;
    }
    return self;
}
-(void)dealloc
{
    pthread_cond_destroy( &m_event );
    pthread_mutex_destroy( &mutex );
}
-(void)reset
{
    pthread_mutex_lock( &mutex );
    flags = 0;
    pthread_mutex_unlock( &mutex );
}
-(void)notify
{
    pthread_mutex_lock( &mutex );
    if( flags & 2 )
        pthread_cond_signal( &m_event );
        else
            flags |= 1;
            pthread_mutex_unlock( &mutex );
            }
-(void)wait
{
    pthread_mutex_lock( &mutex );
    if( !(flags & 1) )
    {
        flags |= 2;
        pthread_cond_wait( &m_event, &mutex );
        flags &= (~2);
    }
    else
        flags &= (~1);
        pthread_mutex_unlock( &mutex );
        }
@end

@implementation RDVGlobal
+ (RDVGlobal *)sharedInstance
{
    static RDVGlobal *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RDVGlobal alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}
+ (void)Init
{
    //Global_activeStandard("com.radaee.pdf.PDFViewer", "Radaee", "radaee_com@yahoo.cn", "3BQIA5-IW8GQM-H3CRUZ-WAJQ9H-FADG6Z-XEBCAO");
    //Global_activeProfession("com.radaee.pdf.PDFViewer", "Radaee", "radaee_com@yahoo.cn", "MP8SG1-7SPIWP-H3CRUZ-WAJQ9H-FADG6Z-XEBCAO");
    //Global_activePremium("com.radaee.pdf.PDFViewer", "Radaee", "radaee_com@yahoo.cn", "89WG9I-HCL62K-H3CRUZ-WAJQ9H-FADG6Z-XEBCAO");
    /*
    [[NSUserDefaults standardUserDefaults] setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:@"actBundleId"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Radaee" forKey:@"actCompany"];
    [[NSUserDefaults standardUserDefaults] setObject:@"radaee_com@yahoo.cn" forKey:@"actEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:@"89WG9I-HCL62K-H3CRUZ-WAJQ9H-FADG6Z-XEBCAO" forKey:@"actSerial"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"actActivationType"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    */
    BOOL isActive = NO;
    int licenseType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"actActivationType"] intValue];
    NSLog(@"LICENSE: %i", licenseType);
    NSLog(@"COMPANY: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"actCompany"]);
    NSLog(@"EMAIL: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"actEmail"]);
    NSLog(@"KEY: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"actSerial"]);
    NSLog(@"BUNDLE: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"actBundleId"]);
    
    switch (licenseType) {
        case 0:
        {
            NSLog(@"standard");
            isActive = Global_activeStandard([[[NSUserDefaults standardUserDefaults] objectForKey:@"actBundleId"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actCompany"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actEmail"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actSerial"] UTF8String]);
            break;
        }
        case 1:
        {
            NSLog(@"professional");
            isActive = Global_activeProfession([[[NSUserDefaults standardUserDefaults] objectForKey:@"actBundleId"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actCompany"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actEmail"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actSerial"] UTF8String]);
            break;
        }
        case 2:
        {
            NSLog(@"premium");
            isActive = Global_activePremium([[[NSUserDefaults standardUserDefaults] objectForKey:@"actBundleId"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actCompany"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actEmail"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actSerial"] UTF8String]);
            break;
        }
        default:
        {
            NSLog(@"default");
            isActive = NO;
            break;
        }
    }
    
    if (isActive)
        NSLog(@"License active");
    else
        NSLog(@"License not active");
    
    [[NSUserDefaults standardUserDefaults] setBool:isActive forKey:@"actIsActive"];
    
    NSString *cmaps_path = [[NSBundle mainBundle] pathForResource:@"cmaps" ofType:@"dat" inDirectory:@"cmaps"];
    NSString *umaps_path = [[NSBundle mainBundle] pathForResource:@"umaps" ofType:@"dat" inDirectory:@"cmaps"];
    NSString *cmyk_path = [[NSBundle mainBundle] pathForResource:@"cmyk_rgb" ofType:@"dat" inDirectory:@"cmaps"];
    
    // check resources
    if (![[NSFileManager defaultManager] fileExistsAtPath:cmaps_path]) {
        NSLog(@"Check resources files: cmaps.dat not found.");
        NSLog(@"Include fdat and cmaps folders as resources (like demo project)");
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cmaps_path]) {
        NSLog(@"Check resources files: umaps.dat not found.");
        NSLog(@"Include fdat and cmaps folders as resources (like demo project)");
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cmaps_path]) {
        NSLog(@"Check resources files: cmyk_rgb.dat not found.");
        NSLog(@"Include fdat and cmaps folders as resources (like demo project)");
        return;
    }
    
    Global_setCMapsPath([cmaps_path UTF8String], [umaps_path UTF8String]);
    Global_setCMYKProfile([cmyk_path UTF8String]);
    
    // Add Standard Resources
    NSString *stdResFolder = [[NSBundle mainBundle] pathForResource:@"fdat/stdRes" ofType:nil];
    int i = 0;
    for (NSString *fpath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:stdResFolder error:nil]) {
        NSLog(@"%@", [stdResFolder stringByAppendingPathComponent:fpath]);
        Global_loadStdFont(i, [[stdResFolder stringByAppendingPathComponent:fpath] UTF8String]);
        i++;
    }
    
    // Add Standard Fonts
    Global_fontfileListStart();
    NSString *stdFontFolder = [[NSBundle mainBundle] pathForResource:@"fdat/stdFont" ofType:nil];
    for (NSString *fpath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:stdFontFolder error:nil]) {
        NSLog(@"%@", [stdFontFolder stringByAppendingPathComponent:fpath]);
        Global_fontfileListAdd([[stdFontFolder stringByAppendingPathComponent:fpath] UTF8String]);
    }
    
    Global_fontfileListEnd();
    
    Global_fontfileMapping("Arial",                        "Arimo");
    Global_fontfileMapping("Arial Bold",                   "Arimo Bold");
    Global_fontfileMapping("Arial BoldItalic",             "Arimo Bold Italic");
    Global_fontfileMapping("Arial Italic",                 "Arimo Italic");
    Global_fontfileMapping("Arial,Bold",                   "Arimo Bold");
    Global_fontfileMapping("Arial,BoldItalic",             "Arimo Bold Italic");
    Global_fontfileMapping("Arial,Italic",                 "Arimo Italic");
    Global_fontfileMapping("Arial-Bold",                   "Arimo Bold");
    Global_fontfileMapping("Arial-BoldItalic",             "Arimo Bold Italic");
    Global_fontfileMapping("Arial-Italic",                 "Arimo Italic");
    Global_fontfileMapping("ArialMT",                      "Arimo");
    Global_fontfileMapping("Calibri",                      "Arimo");
    Global_fontfileMapping("Calibri Bold",                 "Arimo Bold");
    Global_fontfileMapping("Calibri BoldItalic",           "Arimo Bold Italic");
    Global_fontfileMapping("Calibri Italic",               "Arimo Italic");
    Global_fontfileMapping("Calibri,Bold",                 "Arimo Bold");
    Global_fontfileMapping("Calibri,BoldItalic",           "Arimo Bold Italic");
    Global_fontfileMapping("Calibri,Italic",               "Arimo Italic");
    Global_fontfileMapping("Calibri-Bold",                 "Arimo Bold");
    Global_fontfileMapping("Calibri-BoldItalic",           "Arimo Bold Italic");
    Global_fontfileMapping("Calibri-Italic",               "Arimo Italic");
    Global_fontfileMapping("Helvetica",                    "Arimo");
    Global_fontfileMapping("Helvetica Bold",               "Arimo Bold");
    Global_fontfileMapping("Helvetica BoldItalic",         "Arimo Bold Italic");
    Global_fontfileMapping("Helvetica Italic",             "Arimo Italic");
    Global_fontfileMapping("Helvetica,Bold",               "Arimo,Bold");
    Global_fontfileMapping("Helvetica,BoldItalic",         "Arimo Bold Italic");
    Global_fontfileMapping("Helvetica,Italic",             "Arimo Italic");
    Global_fontfileMapping("Helvetica-Bold",               "Arimo Bold");
    Global_fontfileMapping("Helvetica-BoldItalic",         "Arimo Bold Italic");
    Global_fontfileMapping("Helvetica-Italic",             "Arimo Italic");
    Global_fontfileMapping("Garamond",                     "TeXGyreTermes-Regular");
    Global_fontfileMapping("Garamond,Bold",                "TeXGyreTermes-Bold");
    Global_fontfileMapping("Garamond,BoldItalic",          "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("Garamond,Italic",              "TeXGyreTermes-Italic");
    Global_fontfileMapping("Garamond-Bold",                "TeXGyreTermes-Bold");
    Global_fontfileMapping("Garamond-BoldItalic",          "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("Garamond-Italic",              "TeXGyreTermes-Italic");
    Global_fontfileMapping("Times",                        "TeXGyreTermes-Regular");
    Global_fontfileMapping("Times,Bold",                   "TeXGyreTermes-Bold");
    Global_fontfileMapping("Times,BoldItalic",             "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("Times,Italic",                 "TeXGyreTermes-Italic");
    Global_fontfileMapping("Times-Bold",                   "TeXGyreTermes-Bold");
    Global_fontfileMapping("Times-BoldItalic",             "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("Times-Italic",                 "TeXGyreTermes-Italic");
    Global_fontfileMapping("Times-Roman",                  "TeXGyreTermes-Regular");
    Global_fontfileMapping("Times New Roman",              "TeXGyreTermes-Regular");
    Global_fontfileMapping("Times New Roman,Bold",         "TeXGyreTermes-Bold");
    Global_fontfileMapping("Times New Roman,BoldItalic",   "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("Times New Roman,Italic",       "TeXGyreTermes-Italic");
    Global_fontfileMapping("Times New Roman-Bold",         "TeXGyreTermes-Bold");
    Global_fontfileMapping("Times New Roman-BoldItalic",   "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("Times New Roman-Italic",       "TeXGyreTermes-Italic");
    Global_fontfileMapping("TimesNewRoman",                "TeXGyreTermes-Regular");
    Global_fontfileMapping("TimesNewRoman,Bold",           "TeXGyreTermes-Bold");
    Global_fontfileMapping("TimesNewRoman,BoldItalic",     "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("TimesNewRoman,Italic",         "TeXGyreTermes-Italic");
    Global_fontfileMapping("TimesNewRoman-Bold",           "TeXGyreTermes-Bold");
    Global_fontfileMapping("TimesNewRoman-BoldItalic",     "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("TimesNewRoman-Italic",         "TeXGyreTermes-Italic");
    Global_fontfileMapping("TimesNewRomanPS",              "TeXGyreTermes-Regular");
    Global_fontfileMapping("TimesNewRomanPS,Bold",         "TeXGyreTermes-Bold");
    Global_fontfileMapping("TimesNewRomanPS,BoldItalic",   "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("TimesNewRomanPS,Italic",       "TeXGyreTermes-Italic");
    Global_fontfileMapping("TimesNewRomanPS-Bold",         "TeXGyreTermes-Bold");
    Global_fontfileMapping("TimesNewRomanPS-BoldItalic",   "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("TimesNewRomanPS-Italic",       "TeXGyreTermes-Italic");
    Global_fontfileMapping("TimesNewRomanPSMT",            "TeXGyreTermes-Regular");
    Global_fontfileMapping("TimesNewRomanPSMT,Bold",       "TeXGyreTermes-Bold");
    Global_fontfileMapping("TimesNewRomanPSMT,BoldItalic", "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("TimesNewRomanPSMT,Italic",     "TeXGyreTermes-Italic");
    Global_fontfileMapping("TimesNewRomanPSMT-Bold",       "TeXGyreTermes-Bold");
    Global_fontfileMapping("TimesNewRomanPSMT-BoldItalic", "TeXGyreTermes-BoldItalic");
    Global_fontfileMapping("TimesNewRomanPSMT-Italic",     "TeXGyreTermes-Italic");
    Global_fontfileMapping("Courier",                      "Cousine");
    Global_fontfileMapping("Courier Bold",                 "Cousine Bold");
    Global_fontfileMapping("Courier BoldItalic",           "Cousine Bold Italic");
    Global_fontfileMapping("Courier Italic",               "Cousine Italic");
    Global_fontfileMapping("Courier,Bold",                 "Cousine Bold");
    Global_fontfileMapping("Courier,BoldItalic",           "Cousine Bold Italic");
    Global_fontfileMapping("Courier,Italic",               "Cousine Italic");
    Global_fontfileMapping("Courier-Bold",                 "Cousine Bold");
    Global_fontfileMapping("Courier-BoldItalic",           "Cousine Bold Italic");
    Global_fontfileMapping("Courier-Italic",               "Cousine Italic");
    Global_fontfileMapping("Courier New",                  "Cousine");
    Global_fontfileMapping("Courier New Bold",             "Cousine Bold");
    Global_fontfileMapping("Courier New BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("Courier New Italic",           "Cousine Italic");
    Global_fontfileMapping("Courier New,Bold",             "Cousine Bold");
    Global_fontfileMapping("Courier New,BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("Courier New,Italic",           "Cousine Italic");
    Global_fontfileMapping("Courier New-Bold",             "Cousine Bold");
    Global_fontfileMapping("Courier New-BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("Courier New-Italic",           "Cousine Italic");
    Global_fontfileMapping("CourierNew",                   "Cousine");
    Global_fontfileMapping("CourierNew Bold",              "Cousine Bold");
    Global_fontfileMapping("CourierNew BoldItalic",        "Cousine Bold Italic");
    Global_fontfileMapping("CourierNew Italic",            "Cousine Italic");
    Global_fontfileMapping("CourierNew,Bold",              "Cousine Bold");
    Global_fontfileMapping("CourierNew,BoldItalic",        "Cousine Bold Italic");
    Global_fontfileMapping("CourierNew,Italic",            "Cousine Italic");
    Global_fontfileMapping("CourierNew-Bold",              "Cousine Bold");
    Global_fontfileMapping("CourierNew-BoldItalic",        "Cousine Bold Italic");
    Global_fontfileMapping("CourierNew-Italic",            "Cousine Italic");
    
    bool ret;
    ret = Global_setDefaultFont(NULL, "BousungEG-Light-GB", false);
    ret = Global_setDefaultFont(NULL, "BousungEG-Light-GB", true);
    ret = Global_setDefaultFont("GB1", "BousungEG-Light-GB", false);
    ret = Global_setDefaultFont("GB1", "BousungEG-Light-GB", true);
    ret = Global_setDefaultFont("CNS1", "BousungEG-Light-GB", false);
    ret = Global_setDefaultFont("CNS1", "BousungEG-Light-GB", true);
    //radaee don't know which font should used in Japan or Korea, so use "BousungEG"
    //developers may need modify codes below:
    Global_setDefaultFont("Japan1", "BousungEG-Light-GB", false);
    Global_setDefaultFont("Japan1", "BousungEG-Light-GB", true);
    Global_setDefaultFont("Korea1", "BousungEG-Light-GB", false);
    Global_setDefaultFont("Korea1", "BousungEG-Light-GB", true);
    Global_setAnnotFont( "Helvetica" );//Global_setAnnotFont( "BousungEG-Light-GB" );
    
    
    Global_setAnnotTransparency(0x200040FF);
    [[RDVGlobal sharedInstance] setup];
}

- (void)setup {
    GLOBAL.g_render_quality = mode_normal;
    
    _g_render_mode = 0;
    _g_navigation_mode = 1;
    _g_zoom_level = 3; //double tap, (2-5)
    _g_layout_zoom_level = 11; //pinch to zoom
    _g_ink_width = 2;
    _g_rect_width = 2;
    _g_line_width = 2;
    _g_oval_width = 2;
    _g_swipe_speed = 0.15f;
    _g_swipe_distance= 1.0f;
    _g_render_quality = 1;
    _g_zoom_step = 1;
    
    _g_rect_color = 0xFF000000;
    _g_line_color = 0xFF000000;
    _g_ink_color = 0xFF000000;
    _g_sel_color = 0x400000C0;
    _g_oval_color = 0xFF000000;
    _g_line_annot_fill_color = 0xFF000000;
    _g_rect_annot_fill_color = 0;
    _g_ellipse_annot_fill_color = 0;
    _g_annot_highlight_clr = 0xFFFFFF00;
    _g_annot_underline_clr = 0xFF0000FF;
    _g_annot_strikeout_clr = 0xFFFF0000;
    _g_annot_squiggly_clr = 0xFF00FF00;
    
    _g_line_annot_style1 = 0;
    _g_line_annot_style2 = 1;
    _g_readerview_bg_color = 0xFFBFBFBF;
    _g_thumbview_height = 99;
    _g_find_primary_color = 0x400000C0;
    
    _g_static_scale = false;
    _g_curl_enabled = false;
    _g_cover_page_enabled = false;
    _g_fit_signature_to_field = true;
    _g_execute_annot_JS = true;
    _g_dark_mode = false;
    _g_annot_lock = true;
    _g_annot_readonly = true;
    _g_paging_enabled = true;
    _g_double_page_enabled = true;
    _g_curl_enabled = false;
    _g_cover_page_enabled = false;
    _g_case_sensitive = false;
    _g_match_whole_word = false;
    _g_sel_right= false;
    _g_screen_awake = false;
    _g_auto_launch_link = true;
    _g_save_doc = false;
    _g_highlight_annotation = true;
    _g_enable_graphical_signature = true;
    
    _g_author = @"";
    _g_sign_pad_descr = @"Sign here";
}

- (void)setG_annot_transparency:(uint)g_annot_transparency {
    Global_setAnnotTransparency(g_annot_transparency);
}

@end
