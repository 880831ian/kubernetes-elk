# Kubernetes (K8s) 自動化部屬及ELK Log分析
## 109 朝陽資訊工程系畢業專題題目
**說明：代補充**

**內附程式碼有些屬於範例，請依照自己執行後產生資料帶入，IP有些與圖片IP不符(因為我重新安裝好多次QQ)**

**以下目錄**
* 安裝虛擬機
* 安裝k8s
  * 執行腳本(3台虛擬機)
  * 初始化設定(master)
  * 安裝 Dashboard(master)

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

**3. 執行完畢檢查一下Log檔案**
```
cat log.txt
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/18.png)

# 初始化設定

**1. 初始化設定 (master)**
```
kubeadm init --apiserver-advertise-address=10.211.55.37 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --kubernetes-version=v1.15.2 --cri-socket="/var/run/dockershim.sock"
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/19.png)

**2. 初始化完成後，將下方join儲存，待會要在node1跟node2建立**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/20.png)

**3. 執行提示指令，並安裝通用的 flannel容器網路介面**
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/21.png)

**4. 加入node1跟node2的叢集**
```
kubeadm join 10.211.55.37:6443 --token gny70m.2v41qsd2t3jllxk --discovery-token-ca-cert-hash sha256:f25d9d5d03fe993976daa053f23c546fa946cb6faa92c82c5c1946806aa57932
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/22.png)

**5. 等待約1至兩分鐘，查詢主機叢集狀況**
```
kubectl get nodes
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/23.png)

**5. 等待約一至兩分鐘，查詢主機叢集狀況**
```
kubectl get nodes
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/23.png)

# 初始化設定

**1. 安裝 Dashboard(master)**
```
cd /tmp && wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta3/aio/deploy/recommended.yaml
mv recommended.yaml kubernetes-dashboard_v2.0.0-beta3.yaml
vim kubernetes-dashboard_v2.0.0-beta3.yaml
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/23.png)

**2. 設定 Dashboard**
```
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace:kube-system
  namespace:kubernetes-dashboard

spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 32222
  selector:
    k8s-app: kubernetes-dashboard
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/24.png)
