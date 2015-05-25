#!/usr/bin/env python2.7
#-*-coding:utf-8 -*-
'''
useful scripts to disenable the IE proxy by modifying the related reg value using the _winreg library
written by ben
2015/05/25
'''
import os
import _winreg

def disableproxy():
    key=_winreg.OpenKey(_winreg.HKEY_CURRENT_USER,r'Software\Microsoft\Windows\CurrentVersion\Internet Settings',0,_winreg.KEY_ALL_ACCESS) #open the related reg
    _winreg.SetValueEx(key,"ProxyEnable",0,_winreg.REG_DWORD,0) #modify the "ProxyEnable" reg value to disenable the proxy

if __name__=='__main__':
    disableproxy()


