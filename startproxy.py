#!/usr/bin/env python2.7
#-*-coding:utf-8 -*-
'''
useful scripts to enable the IE proxy by modifying the related reg value using the _winreg library
written by ben
2015/05/25
'''
import os
import _winreg

proxy_host='127.0.0.1:8087'  #proxy host--- ip:port
def startproxy():
    key=_winreg.OpenKey(_winreg.HKEY_CURRENT_USER,r'Software\Microsoft\Windows\CurrentVersion\Internet Settings',0,_winreg.KEY_ALL_ACCESS)   #open the related reg
    print "start proxy: Proxy Enabled!"
    _winreg.SetValueEx(key,"ProxyEnable",0,_winreg.REG_DWORD,1)   #modify the "ProxyEnable" reg value to enable the proxy
    _winreg.SetValueEx(key,"ProxyServer",0,winreg.REG_SZ,proxy_host)  #set the proxy server
    _winreg.SetValueEx(key,"ProxyOverride",0,winreg.REG_SZ,'<local>') #set the proxy override

if __name__=='__main__':
    startproxy()


