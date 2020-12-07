# Kubernetes (K8s) 自動化部屬及ELK Log分析
## 109 朝陽資訊工程系畢業專題題目
**說明：Docker是一種新興的虛擬化方式，它高效率虛擬化及易於遷移和擴展的特性，非常適合現代雲端的開發及佈署。但再其服務愈來愈複雜時，如何有效率的管理叢集和服務，將會成為一大課題。在各個容器管理工具中，又以Kubernetes的架構最為優秀，其微服務的特性成功解決了傳統單體架構服務造成不便，Kubernetes提供了良好的服務發現機制，讓每個服務互相通信。ELK是Elasticsearch、Logstash 及 Kibana 三個系統所組成的Log蒐集、分析、查詢系統，它可將繁鎖又沒效率的log查詢工作，整理成高效率、易查詢的介面。本專題藉由ELK的 Log蒐集、分析、查詢系統來實現Kubernetes微服務及自動化佈署的架構。**

**內附程式碼有些屬於範例，請依照自己執行後產生資料帶入，IP有些與圖片IP不符(因為我重新安裝好多次QQ)**

**感謝各方大神資料，才可以完成該專題**
* K8s安裝及設定 https://blog.tomy168.com/2019/08/centos-76-kubernetes.html
* elk教學 https://surprised128.medium.com/use-elk-to-monitor-docker-container-b2d5903920e2
* elk安裝及設定 https://github.com/deviantony/docker-elk.git
* elk-docker 系統文件 https://elk-docker.readthedocs.io/#disabling-ssl-tls

**以下目錄**
* 安裝虛擬機
* 安裝k8s
  * 執行腳本(3台虛擬機)
  * 初始化設定(master)
  * 安裝 Dashboard(master)
  * 資源監控安裝
* 安裝ELK
  * 安裝minikube
  * 設定elastic.yaml
  * 設定kibana.yaml 
  * 設定fluentd-rbac.yaml
  * 設定fluentd-daemonset.yaml
* 實作成果

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
```sh
git clone https://github.com/880831ian/kubernetes-elk.git
```

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/15.png)

**2. 執行k8s.sh腳本(輸入master ip 中間是空格，會自動產生檔案給/etc/hosts)**
```sh
sh k8s.sh 10.211.55 37
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/16.png)

**3. 執行完畢檢查一下Log檔案**
```
cat log.txt
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/18.png)

**4. !!!注意!!! Elasticsearch版本5後，無法正常啟動，請查詢vm.max_map_count，可以使用sysctl -w查寫入，若要永久可在/etc/sysctl.conf加入**
```
sysctl vm.max_map_count
sysctl -w vm.max_map_count=262144
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/41.png)
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/40.png)


# 初始化設定

**1. 初始化設定 (master)**
```sh
kubeadm init --apiserver-advertise-address=10.211.55.37 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --kubernetes-version=v1.15.2 --cri-socket="/var/run/dockershim.sock"
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/19.png)

**2. 初始化完成後，將下方join儲存，待會要在node1跟node2建立**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/20.png)

**3. 執行提示指令，並安裝通用的 flannel容器網路介面**
```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/21.png)

**4. 加入node1跟node2的叢集**
```sh
kubeadm join 10.211.55.37:6443 --token gny70m.2v41qsd2t3jllxk --discovery-token-ca-cert-hash sha256:f25d9d5d03fe993976daa053f23c546fa946cb6faa92c82c5c1946806aa57932
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/22.png)

**5. 等待約1至兩分鐘，查詢主機叢集狀況**
```sh
kubectl get nodes
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/23.png)

# 初始化設定

**1. 安裝 Dashboard(master)**
```sh
cd /tmp && wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta3/aio/deploy/recommended.yaml
mv recommended.yaml kubernetes-dashboard_v2.0.0-beta3.yaml
vim kubernetes-dashboard_v2.0.0-beta3.yaml
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/24.png)

**2. 設定 Dashboard 以32222 port為例**
```sh
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
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/25.png)

**3. 安裝 Dashboard**
```sh
vim admin-sa.yaml

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: admin
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system
  namespace: kubernetes-dashboard

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
  namespace: kubernetes-dashboard

  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/26.png)

**4. 匯入兩個檔案**
```sh
kubectl apply -f kubernetes-dashboard_v2.0.0-beta3.yaml
kubectl apply -f admin-sa.yaml
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/27.png)

**5. 取得dashboard管理者登入密鑰，並匯出password.txt**
```sh
kubectl get secret `kubectl get secret -n kubernetes-dashboard | grep admin-token | awk '{print $1}'` -o jsonpath={.data.token} -n kubernetes-dashboard | base64 -d >> password.txt
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/28.png)

**6. 瀏覽器輸入https://IP:32222 (記得要使用https !!! 備註：google chrome會有安全性的問題不能訪問，解決方式：確定在該網頁，鍵盤輸入thisisunsafe，就可以進入)**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/29.png)

**7. 登入後即可看到dashboard主畫面**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/30.png)

**8. 到kubernetes-dashboard設定，調整認證timeout時間**
```sh
- '--token-ttl=43200'
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/31.png)

**9. 會看到他自動重新佈署顯示黃燈，部屬完成後顯示綠燈**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/32.png)
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/33.png)

# 資源監控安裝

**1. 安裝 metrics-server(master)**
```sh
wget https://github.com/kubernetes-sigs/metrics-server/archive/v0.3.6.tar.gz
tar -zxvf v0.3.6.tar.gz
cd metrics-server-0.3.6/deploy/1.8+/
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/35.png)

**2. 修改 metrics-server**
```sh
vim metrics-server-deployment.yam

      - name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.3
        imagePullPolicy: IfNotPresent
        command:
            - /metrics-server
            - --kubelet-preferred-address-types=InternalIP
            - --kubelet-insecure-tls
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp 
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/36.png)


**3. 匯入metrics-server**
```sh
kubectl apply -f .
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/37.png)

**4. 顯示圖表示資訊**

![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/38.png)
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/39.png)

# 安裝minikube

**1. 下載minikube rpm檔案**
```sh
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -ivh minikube-latest.x86_64.rpm
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/42.png)

**2. 啟動minikube**
```sh
minikube start
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/43.png)

**3. minikube加入記憶體及處理器數量**
```sh
minikube start --momory 8192 --cpus 4
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/44.png)


**4. 創建一個新命名空間**
```sh
kubectl create namespace logging
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/45.png)


# 設定elastic.yaml

**1. 安裝Elasticsearch docker image**
```sh
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.10.0
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/46.png)

**2. 檢查elastic.yaml**
```sh
cat elastic.yaml
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/47.png)

**3. 匯入elastic.yaml到logging**
```sh
kubectl create -f elastic.yaml -n logging
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/48.png)

**4. 用K8s查看elasticsearch部屬狀況**

```sh
kubectl get pods -n logging
kubectl get service -n logging
```
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/49.png)
![image](https://github.com/880831ian/kubernetes-elk/blob/main/images/50.png)
