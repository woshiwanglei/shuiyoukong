//
//  Error.h
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#define RET_OK                  0x0
#define RET_SERVER_SUCC         200
#define RET_SERVER_FAIL         0X1
#define RET_VALID_EMAIL         0x1001
#define RET_VALID_MOBILE_NO     0x1002
#define RET_NICKNAME_AVAILABLE  0x1003      // the nickname is available
#define RET_NICKNAME_OCCUPIED   0x1004      // the nickname is occupied
#define RET_MOBILE_NO_AVAILABLE 0x1005      // the mobile no is available
#define RET_MOBILE_NO_OCCUPIED  0x1006      // the mobile no is occupied
#define RET_EMAIL_AVAILABLE     0x1007      // the email is available
#define RET_EMAIL_OCCUPIED      0x1008      // the email is occupied

/* ERR code */
#define ERR_BASE                0x10000000  // this is a delimiter only
#define ERR_INVALID_EMAIL       0x10000001
#define ERR_INVALID_MOBILE_NO   0x10000002
#define ERR_PASSWORD_TOO_SHORT  0x10000003
#define ERR_PASSWORD_TOO_LONG   0x10000004
#define ERR_NICKNAME_TOO_SHORT  0x10000005
#define ERR_NICKNAME_TOO_LONG   0x10000006
#define ERR_NICK_NAME_IS_NIL    0x10000007
#define ERR_INVALID_SMS_CODE    0x10000008
#define ERR_BLOCK_IS_NIL        0x10000009
#define ERR_USER_INFO_IS_NIL    0x1000000A
#define ERR_ADDRESS_LIST_IS_NIL 0x1000000B
#define ERR_STATUS_IS_NIL       0x1000000C
#define ERR_ACCOUNTID_IS_NIL    0x1000000D
#define ERR_TAG_IS_NIL          0x1000000E
#define ERR_HEAD_IMG_IS_NIL     0x1000000F
#define ERR_SEX_IS_NIL          0x10000010
#define ERR_PWD_NOT_SAME        0x10000011
#define ERR_PWD_NOT_NULL        0x10000012
#define ERR_PWD_NEXT_NOTNULL    0x10000013
#define ERR_FREEDATE_IS_NIL     0x10000014
#define ERR_FREEDATE_START_IS_NIL 0x10000015
#define ERR_IDEASEND_IS_NIL     0x10000016
#define ERR_USER_ID_IS_NIL      0x10000017
#define ERR_AddInterest_NOT_LONG 0x10000018
#define ERR_ACTIVE_ID_IS_NIL      0x10000019
#define ERR_ACTIVE_CONTENT_IS_NIL 0x1000001A
#define ERR_ACTIVE_CONTENT_TOO_LONG 0x1000001B
#define ERR_DATE_IS_POST        0x1000001C
#define ERR_GROUP_NAME_IS_NIL   0x1000001D
#define ERR_GROUP_ID_IS_NIL     0x1000001E
#define ERR_PINYIN_IS_NIL       0x1000001F
#define ERR_FRIENDNAME_IS_NIL       0x10000020
#define ERR_PHONE_NO_IS_NIL       0x10000021
#define ERR_CONTENT_IS_NIL       0x10000022
#define ERR_COVER_IMG_IS_NIL     0x10000023
#define ERR_POSTID_IS_NIL     0x10000024
#define ERR_REPOST_CONTENT_IS_NIL     0x10000025
#define ERR_TAGS_IS_NIL    0x10000026
#define ERR_POSITION_IS_NIL    0x10000027
#define ERR_REPOST_ID_IS_NIL    0x10000028
#define ERR_ACTIVE_TITLE_IS_NIL 0x10000029
#define ERR_INVITE_CODE_LENGTH_TOO_SHORT 0x1000002A
#define ERR_UID_IS_NIL 0x1000002B

/* server err code*/
#define ERR_SERVER_401 401

NSString* zcErrMsg(NSUInteger errcode);
