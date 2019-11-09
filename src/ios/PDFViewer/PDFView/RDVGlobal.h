//
//  VGlobal.h
//  RDPDFReader
//
//  Created by Radaee on 16/11/19.
//  Copyright © 2016年 radaee. All rights reserved.
//
#pragma once
#import <pthread.h>
#import "PDFObjc.h"

#define GLOBAL [RDVGlobal sharedInstance]

@interface RDVLocker :NSObject
{
    pthread_mutex_t mutex;
}
-(void)lock;
-(void)unlock;
@end

@interface RDVEvent :NSObject
{
    unsigned int flags;
    pthread_cond_t m_event;
    pthread_mutex_t mutex;
}
-(void)reset;
-(void)notify;
-(void)wait;
@end

@interface RDVGlobal :NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSMutableString *pdfName;
@property (strong, nonatomic) NSMutableString *pdfPath;
@property (strong, nonatomic) NSString *g_author;

@property (nonatomic) int g_render_quality;
@property (nonatomic) uint g_rect_color;
@property (nonatomic) uint g_line_color;
@property (nonatomic) uint g_ink_color;
@property (nonatomic) uint g_sel_color;
@property (nonatomic) uint g_oval_color;

@property (nonatomic) bool g_case_sensitive;
@property (nonatomic) bool g_match_whole_word;
@property (nonatomic) bool g_sel_right;
@property (nonatomic) bool g_screen_awake;
@property (nonatomic) bool g_save_doc;

@property (nonatomic) float g_ink_width;
@property (nonatomic) float g_rect_width;
@property (nonatomic) float g_line_width;
@property (nonatomic) float g_oval_width;
@property (nonatomic) float g_swipe_speed;
@property (nonatomic) float g_swipe_distance;

@property (nonatomic) int g_render_mode;
@property (nonatomic) float g_zoom_level;
@property (nonatomic) bool g_static_scale;
@property (nonatomic) bool g_paging_enabled;
@property (nonatomic) bool g_double_page_enabled;
@property (nonatomic) bool g_curl_enabled;
@property (nonatomic) bool g_cover_page_enabled;
@property (nonatomic) bool g_fit_signature_to_field;
@property (nonatomic) bool g_execute_annot_JS;
@property (nonatomic) bool g_dark_mode;
@property (nonatomic) bool g_annot_lock;
@property (nonatomic) bool g_annot_readonly;
@property (nonatomic) bool g_auto_launch_link;
@property (nonatomic) int renderQuality;

@property (nonatomic) uint g_annot_highlight_clr;
@property (nonatomic) uint g_annot_underline_clr;
@property (nonatomic) uint g_annot_strikeout_clr;
@property (nonatomic) uint g_annot_squiggly_clr;

@property (nonatomic) uint g_annot_transparency;

+ (RDVGlobal *)sharedInstance;
+ (void)Init;

- (void)setup;

@end

