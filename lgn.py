# * encoding=utf-8 *
import datetime
import time
import re
import requests
from requests.exceptions import ConnectionError, ReadTimeout
import random
import sys
import os
import math
import threading
import Useragent
from urllib.parse import urlencode
import json
import logging

from requests.exceptions import ConnectTimeout,ReadTimeout

requests.packages.urllib3.disable_warnings()  # 因为使用了request verify=False, 所以https要忽略安全警告


# idpw 类

class idpw(object):
    idpwtime = 0 # 类变量
    # url = "http://172.30.201.10"
    # 按识别逻辑顺序排列
    url_list = ["http://wlgn.bjut.edu.cn", 
                "http://10.21.221.98",
                "http://lgn.bjut.edu.cn",
                ]
    test_url = "http://www.baidu.com"
    jf_url = "https://jfself.bjut.edu.cn"
    my_url=None     # 当前环境的认证网页 取自 url_list
    my_ip=None      # 当前校园网ip
    local_online=None     # 是否在线
    local_online_id=None
    local_online_id_username=None



    def __init__(self,id,pw,ser=0,**kwargs):
        if type(id) != type('str') or type(pw) != type('str') :
            raise ValueError("Para need str")
        self.id=id
        self.pw=pw
        self.ser=ser # ser 10.21.221.98 生效  运营商参数 0 校内网 campus 1 移动 cmcc 2 联通 unicom 3 电信 telecom
        self.UA=Useragent.random_one()
        self.home_body=None
        if not self.my_url:
            self.Which_Net()
        #if idpw.idpwtime == 0 or time.time() - idpw.idpwtime > 2: # 类变量访问 此处为上一实例设置值
            #pass
        #else:
            #time.sleep(0.5)
        #idpw.idpwtime = time.time() # 类变量赋值

    def __repr__(self):
        return dict(self)
    def __str__(self):
        return str(dict(self))
    def __iter__(self):
        return self
    def __next__(self):
        try:
            self.__getattribute__('__nextcount')
        except AttributeError:
            self.__setattr__('__nextcount',0)
        self.__setattr__('__nextcount', self.__getattribute__('__nextcount')+1)
        keys=('id','pw','flow')
        if self.__getattribute__('__nextcount') > len(keys):
            self.__delattr__('__nextcount')
            raise StopIteration
        return(keys[self.__getattribute__('__nextcount')-1],self.__getattribute__(keys[self.__getattribute__('__nextcount')-1]))

    def __del__(self):
        if self.sesions:
            self.sesions.close()

    def __lt__(self,other):
        if self.flow < other.flow:
            return True
        return False

    def __bytime__(self,addrname,func,validtime=0):
        name = addrname
        oldname = '__' + name + "_previous"  # 私有属性 存上一次的值
        timename = '__' + name + "_time"  # 私有属性 记录时间戳
        validname = '__' + name + "_validsecs"
        self.__setattr__(validname, validtime)
        error1 = 0
        if timename not in self.__dict__.keys():  # __dict__ 所有属性及值的字典（不含动态属性）
            error1 = 1
        else:  # 存在 获取
            previous = self.__getattribute__(oldname)
            previous_time = self.__getattribute__(timename)
        if error1 or time.time() - previous_time >= self.__getattribute__(validname):  # 初次 或 超时 重新设置
            previous = func()  # 获取值的方法
            self.__setattr__(oldname, previous)  # 设置 私有属性 存本次值 供下次访问
            self.__setattr__(timename, time.time())  # 设置 私有属性 记录时间戳
        present = previous
        #self.__setattr__(addrname,present)
        return present

    @property
    def right(self):  # 账号密码是否正确 jfself 验证
        if self.sesions:
            return True
        else:
            return False
    # cookies 超时重新获取

    @property   #动态属性 方法名为属性名
    def sesions(self):
        return self.__bytime__('sesions',self.trypass,validtime=3600)

    @property
    def __refresh_info(self):
        return self.__bytime__('refresh_info',self.get_net_info,validtime=60)

    @property
    def __user_netinfo(self):
        return self.__bytime__('user_netinfo',self.get_user_netinfo,validtime=60)

    @property
    def onlinestate(self):
        if  self.sesions:
            if self.__refresh_info['note']['onlinestate']:
                return True
        return False

    @property
    def active(self):
        if self.sesions:
            if self.__refresh_info['note']['status']=='正常':
                return True
        return False

    @property
    def flow(self):
        if self.sesions:
            return self.__user_netinfo['本月流量（MB）']
        return False

    @property
    def online_count(self):
        if self.sesions:
            return len(self.online_device())

    def login(self):
        res=False
        if self.my_url == self.url_list[0]:
            res=self.get_login()
        elif self.my.url == self.url_list[1]:
            res=self.B_login(ser=self.ser)
        elif self.my.url == self.url_list[2]:
            res=self.lgn_login()
        self.test_url(self.myurl)
        return res

    def logout(self):
        res = False
        if self.my_url == self.url_list[0]:
            res = self.get_logout()
        elif self.my.url == self.url_list[1]:
            res = self.B_logout()
        elif self.my.url == self.url_list[2]:
            res = self.lgn_logout()
        return res

    def lgn_login(self):
        id =self.id
        pw=self.pw
        UA=self.UA
        form_dict = {'DDDDD': id, 'upass': pw, 'v46s': '1', 'v6ip': '', 'f4serip': "172.30.201.2", '0MKKey': ''}
        res = requests.post(url=self.url_list[2], data=form_dict, headers={'User-Agent':UA}, verify=False)
        res.encoding = 'gb2312'
        if "error" in res.text:
            match_re = re.search(r'msga=\'(\w+)( \w+)+\'', res.text)  # user id error1 ldap auth error
            if match_re:
                if "error" in match_re.group(0):
                    if match_re.group(1) == "userid":
                        msg = "账号错误"
                    elif match_re.group(1) == "ldap":
                        msg = "密码错误"
                    elif 'waitsec' in match_re.group(1):
                        time.sleep(3.5)
                        # logging.info("账号" + form_dict["DDDDD"] +'waitsec')
                        if self.lgn_login(id, pw):
                            return 1
                        else:
                            return 0
                    # logging.info("账号" + form_dict["DDDDD"] + msg)
            return 0
        elif "<!--Dr.COMWebLoginID_3.htm-->" in res.text:
            return 1
        else:
            return 0

    def lgn_logout(self):
        UA=self.UA
        url = self.url_list[2] + "/F.htm"
        try:
            res = requests.get(url=url, headers={'User-Agent':UA}, verify=False, timeout=1.5)
        except ReadTimeout:
            return 0
        res.encoding = 'gb2312'
        if "<!--Dr.COMWebLoginID_2.htm-->" in res.text and "msga=''" in res.text:
            return 1
        else:
            return 0

    # 10.21.250.3 login
    def get_login(self):
        user_id=self.id
        pw=self.pw
        home_url=self.url_list[0]
        para_dict = {
            'callback': 'dr1002',
            'DDDDD': user_id,
            'upass': pw,
            '0MKKey': '123456',
            'R1': '0',
            'R2': '',
            'R3': '0',
            'R6': '0',
            'para': '00',
            'v6ip': '',
            'terminal_type': '1',
            'lang': 'zh-cn',
            'jsVersion': '4.1',
            'v': str(int(random.random() * 10000 + 500)),
            'lang': 'zh',

        }
        final_url = home_url + '/drcom/login?' + urlencode(para_dict)
        res = requests.get(url=final_url, headers={'User-agent':Useragent.random_one()})
        res.encoding = 'gbk'
        logintxt = res.text.replace(" ", '')
        try:
            back = json.loads(logintxt.replace('(', "").replace(')', '')[6:])
            return back['result']
        except Exception as e:
            # writeerror(logintxt, str(e) + '.txt')
            return 0

    # 10.21.250.3 logout
    def get_logout(self):
        home_url = self.url_list[0]
        para_dict = {
            "callback": 'dr1002',
            "jsVersion": '4.1',
            'v': str(int(random.random() * 10000 + 500)),
            'lang': 'zh',
        }
        final_url=home_url + '/drcom/logout?' + urlencode(para_dict)
        res = requests.get(url=final_url, headers={'User-agent':Useragent.random_one()})
        res.encoding = 'gbk'
        logouttxt = res.text
        try:
            back = json.loads(logouttxt.replace('(', '').replace(')', '').replace(' ', '')[6:])
            return back['result']
        except Exception as e:
            # writeerror(logouttxt, (e) + '.txt')
            return 0

    def B_login(self,ser=0):
        t_url=self.url_list[1]+":801/eportal/?"
        if ser == 0:
            ser= 'campus'
        elif ser == 0:
            ser = 'cmcc'
        elif ser == 0:
            ser = 'unicom'
        elif ser == 0:
            ser = 'telecom'
        else:
            return False
        user_id = self.id+'@'+ser # 目前
        pw=self.pw
        # res = requests.get(url = )
        timestamp1 = int(random.random()) * 10000
        para_dict = {
            'c': "Portal",
            'a': 'login',
            "callback": 'dr'+ str( timestamp1 + 500),
            'user_account': user_id,
            'user_password': pw,
            # "wlan_user_ip":ip,
            'wlan_user_mac':'000000000000',
            'wlan_ac_ip':'',
            'wlan_ac_name':'',
            'login_method': '1',
            "jsVersion": '3.0',
            '_': str(timestamp1),
        }
        res = requests.get(url=t_url + urlencode(para_dict), headers={'User-agent':Useragent.random_one()})
        res.encoding = 'utf-8'
        logintxt = res.text.replace(" ", '')
        try:
            back = json.loads(logintxt.replace('(', "").replace(')', '')[6:])
            # print(back)
            return back['result']
        except Exception as e:
            # print(str(e))
            return 0

    def B_logout(self):
        t_url = self.url_list[1] + ":801/eportal/?"
        timestamp1 = int(random.random()) * 10000
        para_dict = {
            'c': "Portal",
            'a': 'login',
            "callback": 'dr' + str(timestamp1 + 500),
            'user_account': 'drcom',
            'user_password': '123',
            # "wlan_user_ip":ip,
            'wlan_user_mac': '000000000000',
            'wlan_ac_ip': '',
            "wlan_user_ipv6":"",
            'wlan_ac_name': '',
            'login_method': '1',
            "jsVersion": '3.0',
            '_': str(timestamp1),
        }
        # wlan_vlan_id: 1
        # wlan_user_mac: 20ab481ca920
        res = requests.get(url=t_url + urlencode(para_dict), headers={'User-agent': Useragent.random_one()})
        res.encoding = 'utf-8'
        logintxt = res.text.replace(" ", '')
        try:
            back = json.loads(logintxt.replace('(', "").replace(')', '')[6:])
            # print(back)
            return back['result']
        except Exception as e:
            # print(str(e))
            return 0

    # 登录 jf.sekf.bjut.edu.cn 返回会话session对象
    def trypass(self):
        id = self.id
        pw = self.pw
        UA = self.UA
        jf_url=self.jf_url
        dict1 = {
            'account': id,
            'password': pw,
            'code': '',
            'checkcode': '',
            'Submit': '登 录',
        }
        s = requests.session()
        s.headers.update({"User-Agent": UA})
        s.verify=False
        try:
            res = s.get(url=jf_url + '/nav_login', timeout=3)
        except Exception as e:
            return False
        res.encoding = 'utf-8'
        txt = res.text
        result = re.search("checkcode=\"(\d+)\"", txt)  # 获取checkcode参数
        dict1['checkcode'] = result.group(1)
        randomNum = random.random()
        # 获取一下验证码图 不获取post会返回登录页面
        s.get(url=jf_url + '/RandomCodeAction.action', data={"randomNum": str(randomNum)})
        resp = s.post(url=jf_url + '/LoginAction.action', data=dict1)
        resp.encoding = 'utf-8'
        resptxt = resp.text
        flagstr = '余额'  # 登录正常页面得判断字符串
        if flagstr in resptxt:
            self.home_body = resptxt
            return s
        else:
            return False

    # 获取在线信息方法
    def get_net_info(self):
        jf_url = self.jf_url
        s=self.sesions
        resjson = s.get(url=jf_url + '/refreshaccount?t=' + str(random.random()))
        fresh_dict = json.loads(resjson.text)
        return fresh_dict

    #获取 用户及上网信息
    def get_user_netinfo(self):
        jf_url = self.jf_url
        s=self.sesions
        res =s.get(url=jf_url + '/nav_getUserInfo')
        # 替换对匹配无用字符串
        restxt = res.text.replace('\t', '').replace('\r\n', '').replace('&nbsp;', '').replace('<td class="t_r2"></td>','').replace("<font class=\"redtext\">", '').replace('</font>', '')
        match_list1 = re.findall(r'<td class="t_l">([\s\S]*?)</td>', restxt)  # 获取信息title
        match_list2 = re.findall(r'<td class="t_r1"[\s]?>([\s\S]*?)</td>', restxt)  # ~~~~~content
        dict1 = dict(zip(match_list1, match_list2))
        return dict1

    def get_user_all_info(self):
        a=self.get_net_info()
        prim={'status':a['note']['status'],'service':a['note']['service'],'leftmoney':a['note']['leftmoeny'],'id(name)':a['note']['welcome']}
        b=self.get_user_netinfo()
        prim.update(b)
        return prim

    # 返回在线设备 IP mac
    def online_device(self):
        jf_url = self.jf_url
        s = self.sesions
        res = s.get(url=jf_url+"/nav_offLine")
        res.encoding = 'utf-8'
        restxt = res.text.replace('\t', '').replace('\r\n', '').replace('&nbsp;', '')
        match_list = re.findall(r'<td>([0-9\.]+)</td><td></td><td>([A-Z0-9]{12})</td>',restxt)
        dict_list =[]
        for i in match_list:
            dict_list.append({'ip':i[0],'mac':i[1]})
        return dict_list

    # 检测链接是否可以联通，并获取一些信息
    @classmethod
    def test_url(cls, url):
        if not url in cls.url_list:
            return False
        try:
            rs = requests.get(url=url, headers={'User-agent': Useragent.random_one()}, timeout=0.5, verify=False)
        except ConnectTimeout:
            rs = False
        except ReadTimeout:
            rs = False
        if not rs:
            return False
        rs.encoding = 'utf-8'
        str_id=None
        str_mac =None
        str_v4ip = None
        str_time = None
        str_flow =None

        if "<!--Dr.COMWebLoginID_1.htm-->" in rs.text:
            cls.local_online = True
            if url != cls.url_list[2]:
                if url == cls.url_list[1]:
                    str_id=re.findall(r"uid='([BS]?\d+)'", rs.text)[0]
                    str_mac = re.findall(r"olmac='([\w\d]+)';", rs.text)[0]
                elif url == cls.url_list[0]:
                    str_id = re.findall(r"uid='([BS]?\d+)'", rs.text)
                    if len(str_id):       # 无感认证uid 为mac
                        str_id=str_id[0]
                    else:
                        str_mac=re.findall(r"uid='([\w\d]+)';", rs.text)[0]

                str_v4ip=re.findall(r"v4ip='([\d.]+)'", rs.text)[0]
            str_flow = re.findall(r"flow='(\d+) +'", rs.text)[0]
            str_time = re.findall(r"time='(\d+) +'", rs.text)[0]
        else:
            str_v4ip = re.findall(r"v46ip='([\d.]+)'", rs.text)[0]

        if str_id:
            cls.local_online_id=str_id
        if str_mac:
            cls.local_online_mac=str_mac
        if str_v4ip:
            cls.my_ip=str_v4ip

        return True
    
    # 获取本地上网信息 主要 是否在线 ip
    @classmethod
    def get_chkstatus(cls,url):
        if url in cls.url_list[:2]:
            status_url = url + "/drcom/chkstatus?callback="
        elif url ==cls.url_list[1]:
            status_url = cls.url_list[1] + "/drcom/chkstatus?callback="
        else:
            return False
        try:
            rs = requests.get(url=status_url, headers={'User-agent': Useragent.random_one()}, timeout=0.5, verify=False)
        except ConnectTimeout:
            rs = False
        except ReadTimeout:
            rs = False
        if not rs:
            return False
        txt=rs.text
        txt=txt[txt.index('(')+1:txt.index(')')-len(txt)]
        res=json.loads(txt)

        temp_online=bool(res['result'])
        cls.my_ip=res['v46ip']  # 'ss5' 也行
        if temp_online:
            if cls.my_url == cls.url_list[0]:
                cls.local_online=temp_online
            if cls.my_url == cls.url_list[1]:
                cls.local_online_id_username=res['NID']
            cls.local_online_id = res['uid']
        return res
    
    # 检测网络环境 判断认证url
    @classmethod
    def Which_Net(cls):
        for url in cls.url_list:
            if cls.test_url(url):
                cls.my_url=url
                break
        rs = cls.get_chkstatus(cls.my_url)
        if cls.my_url != cls.url_list[0]:
            # 10.21.221.98 chkstatus 返回当前校园网IP
            if rs:
                res_ip=cls.my_ip
                cls.my_url=rs['ss6']
                # 根据ip 分辨哪个网
                if re.match(r"172[.\d]+",res_ip):
                    cls.my_url=cls.url_list[2]
                elif re.match(r"10[.\d]+",res_ip):
                    cls.my_url=cls.url_list[1]
        return cls.my_url


t = threading.Thread(target=idpw.Which_Net)
t.start()
t.join()
