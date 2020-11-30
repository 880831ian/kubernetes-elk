# Kubernetes (K8s) 自動化部屬及ELK Log分析
## 109 朝陽資訊工程系畢業專題題目
**說明：代補充**

**以下目錄**
* 安裝虛擬機
* 安裝k8s
  * Item 2a
  * Item 2b

# 安裝虛擬機
**系統規格架構圖**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/13.png)

**1. 設備於Mac OS上，使用Parallels Desktop建立3台虛擬機。**
```
https://www.parallels.com/hk/products/desktop/
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/1.png)

**2. 虛擬機取名為master、node1、node2**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/2.png)

**3. 系統配置每一台CPU為2、core、Ram為2G、Memory 32GB**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/5.png)

**4. 選擇中文>繁體中文(台灣)**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/6.png)

**5. 記得開啟網路連線，並修改hostname**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/8.png)

**6. 設定root密碼，並重新啟動**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/10.png)

# 安裝K8s

**1. 先用git 來下載所需檔案 (3台機器都需要執行)**
```
git clone https://github.com/880831ian/kubernetes-elk.git
```

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/15.png)

**2. 執行k8s.sh腳本(輸入master ip 中間是空格，會自動產生檔案給/etc/hosts)**
```
sh k8s.sh 10.211.55 37
```

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/16.png)
