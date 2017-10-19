//
//  Error.m
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "Error.h"


NSString* zcErrMsg(NSUInteger errcode)
{
    
    switch (errcode)
    {
        case ERR_INVALID_EMAIL:     return @"不是有效的邮箱地址";
        case ERR_INVALID_MOBILE_NO: return @"不是有效的手机号码";
        case ERR_NICKNAME_TOO_LONG: return @"昵称不能超过 8 个字";
        case ERR_NICKNAME_TOO_SHORT:return @"昵称不能少于 2 个字";
        case ERR_PASSWORD_TOO_LONG: return @"密码不能超过 20 个字符,必须为字母或者数字";
        case ERR_PASSWORD_TOO_SHORT:return @"密码不能少于 6 个字符,必须为字母或者数字";
        case ERR_NICK_NAME_IS_NIL:  return @"昵称不能为空";
        case ERR_INVALID_SMS_CODE:  return @"不是有效的验证码";
        case ERR_BLOCK_IS_NIL:      return @"block为空";
        case ERR_USER_INFO_IS_NIL:  return @"用户信息为空";
        case ERR_ADDRESS_LIST_IS_NIL: return @"通讯录为空";
        case ERR_STATUS_IS_NIL:     return @"用户状态为空";
        case ERR_ACCOUNTID_IS_NIL:  return @"用户id为空";
        case ERR_HEAD_IMG_IS_NIL:   return @"上传图片不能为空";
        case ERR_SEX_IS_NIL:        return @"性别不能为空";
        case ERR_PWD_NOT_NULL:      return @"密码不能为空";
        case ERR_PWD_NOT_SAME:      return @"两次输入密码不相同,请重新输入";
        case ERR_FREEDATE_IS_NIL:   return @"空闲日期为空";
        case ERR_FREEDATE_START_IS_NIL: return @"空闲开始日期为空";
        case ERR_IDEASEND_IS_NIL:       return @"内容不能为空";
        case ERR_USER_ID_IS_NIL:    return @"该用户id为空";
        case ERR_AddInterest_NOT_LONG: return @"输入标签不能超过8个字符";
        case ERR_ACTIVE_ID_IS_NIL:  return @"活动ID不能为空";
        case ERR_ACTIVE_CONTENT_IS_NIL: return @"活动内容不能为空";
        case ERR_ACTIVE_CONTENT_TOO_LONG: return @"活动内容不能超过30字";
        case ERR_DATE_IS_POST:      return @"时间已经过期,请重新选择";
        case ERR_GROUP_NAME_IS_NIL: return @"群名称为空";
        case ERR_GROUP_ID_IS_NIL:   return @"群ID为空";
        case ERR_PINYIN_IS_NIL:     return @"拼音为空";
        case ERR_FRIENDNAME_IS_NIL: return @"备注名为空";
        case ERR_PHONE_NO_IS_NIL:   return @"电话号码为空";
        case ERR_CONTENT_IS_NIL:    return @"分享内容为空";
        case ERR_COVER_IMG_IS_NIL:  return @"封面不能为空";
        case ERR_POSTID_IS_NIL:     return @"帖子ID为空";
        case ERR_REPOST_CONTENT_IS_NIL: return @"不能发表空的评论";
        case ERR_TAGS_IS_NIL:       return @"请填写标签";
        case ERR_POSITION_IS_NIL:   return @"请填写具体位置";
        case ERR_REPOST_ID_IS_NIL:  return @"帖子ID为空";
        case ERR_INVITE_CODE_LENGTH_TOO_SHORT: return @"邀请码长度太少";
        case ERR_UID_IS_NIL:        return @"登录ID为空";
    }
    
    return [NSString stringWithFormat:@"错误码:%lu(0x%lx) 是个无效的错误码", (unsigned long)errcode, (unsigned long)errcode];
}
