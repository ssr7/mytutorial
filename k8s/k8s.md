# Kubernetes
- There are a lot of components
## Node
- physical node or VM
## Pod
- Smallest unit in K8s
- Abstraction layer over container technology (like padman, docker , ...)
- Each Pod gets its own IP address. Howover If pod is deleted, IP address will be changed. :-(
## Service
- permannet(static) IP address  can atteched to each pod
- Lifesycle of POD and Service are not connected together 
### Exteranal service
- access in pulblic
### Internal  service
- access in just internal 
### Ingress
- handle all External traffic in convinent name and port like https://my-domian.com instead in http://10.25.40.21:8080

## Config map
- contains external configuration for services like DB_URL=mongo-db-service
- Do not put credentials into config map

## Secrect
- Like config map but for use to save credentials  like 
```bash
DB_USER=root 
DB_PASS=123
````
- base64 encoded
- The built-in  security mechanism  is not enabled by default 
- uas as envirenmnets variables or properties files 

## Volumes
- To save data stoage in container
- Storage on local machine , remote(external hdd) or outside in Ks8
- Ks8 does not manage data persistance 

## Replication
 - we have multiple nodes
 - service has 2 funciotnalies: permannet ip and load blancer
## development
 - define blue print to specify number of repliacas
 ## Stateful set
 - use shared storage for some pods (mongodb, elasticSearch , ...)
 - devlopment for replica and use shared storage
 - Is not easy deploy stateful state

## Ks8 architucture
 - Each node must have 3 process:
 1. container runtime like dokcer
 2. kubelet that interacts with both- the container and node: kublet start pod with a container inside
 3. KubeProxy: forward the reqeust: intelligence to forwarding request (select best desstination)

## How to interact with this cluster?
1. schedule pod?
2. monitor?
3. re-schedule/re-start pod?
4. join a new Node?


### Master node:
 - It has 4 processes that completly different from node
 1. API server: like a cluster gateway (initilize updata and query), acts as gatekeeprt for authentication  (client and kubecli and ... user API server to interact with cluster)
 2. Schduler: recevie data from API server and do schaduling to run task like turn on a pod . 1Where ti put a POD: choose the best node th run task
 3. Contoller Manager: detect cluster state changess and work with schulder and then kubelet is runtime
4. etcd: is the cluster brain: cluster changes get stored in the key value store. contoller manager works with data. The data contains avalaible resource, cluster state changes. cluster health. . ppllication data is not stored in etcd (key,value)

- we can make a cluster of master nodes.  so we have load balancer for API server and shred storage for etcd deamon.


 so we have master node and worker node
 - master  node needs less resources

## minicube
 - minicube has a lightwight worker and master node inorder to run test on local machine innsted of run in production env
 - docker is installed
 - install virtual machine and install worker and master node

## Kubectl
 - A cli to interacts with K8s cluster that wotks with API server
 - we can interact with API server with UI, API client and KUBECTL(the most powerfull 3 clients)
 - worker process: enables pods run on node


## Installation:
````bash
 Install a hypervisor like vmware, virtualbox or event hyperkit
 install minicube that contains kubecli(as a dependancy)
 install docker
 minicube start --vm-driver=hyperkit # create k8s cluster and download some stuff and config
 kubectl get nodes  # show nodes
 minikube status  # show state of components
 kubectl version
# kubectl for configuring the minikube cluster
# Minikube CLI for start up / deleting the cluster
````
## Main kubectl commands

````bash
kubectl get nodes # show nodes
kubectl get pod
kubectl get services 

kubectl create deployments # instead of pod ( deployment is abstraction layer over pods 
kubectl create deployment NAME --image=  [--dry-run] [options]

kubectl create deployment my-nginx  --image=nginx  # pull latest nginx from docker  

kubectl get pod # show nginx pod
kubectl get deployment # show deployments
    # my-ngix-<REPLICA_ID>-<POD_ID>
kubectl get replicaset
    # my-ngix-<REPLICA_ID>

 
````
- deployment:
    - blueprint for creating pods
    - most basic configuration for deployment(name and image to use)
    - rest defaults
    
- repliacaSet is managing the replicas of a pod
- we never have to create,update,delete a replicaset (in practice) 
- we can set replica set for pod in create phase 
````bash
kubectl edit deployment my-nginx  # open blueprint of pod with VIM 
# after that kubectl get pod show us teminate old image and start new instance
````
- Everything below deployment is handled by kubernetes

### kubectl debugging
#### kubectl logs
````bash
kubectl logs my-nginx-...
````
#### kubectl exec
````bash
kubectl exec -it my-nginx -- /bin/bash
````

### kubectl delete

````bash
kubectl delete deployment my-nginx
````

### kubectl apply
- get text file and run commands like docker-compose.yml in order create a pod with our options

- First `spec` definition in `file.yaml` is for `deployment` and second one for `pod `
````bash
kubectl apply -f nginx-development.yaml
kubectl get deployment
kubectl describe pod pod-name

````

 ## Replication
 - we have multiple nodes
 - service has 2 funciotnalies: permannet ip and load blancer
 ## development
 - define blue print to specify number of repliacas



### config file
- config files (blue print ) is stored in etcd storage
- etcd holds the current status of any k8s component
- format of config file is yaml 
- store the config file with our code or git repossitory
- The templte like:

````yaml
metadata:
        labels:
            app: nginx
spec: # blue print of pod
        containers:
            -name: nginx
            image: nginx:1.16
            ports:
                - containerPort: 8080



````
- each service is connected to multiple pods( that are created by deployment).
- We have ‍‍‍`deploymeny.yaml` for create pods and `service.yml` to create service.
- Every service can handle multiple IP and it uses load balancer to access pods
- export deployment config
````bash
kubectl get deployment nginx-deployment -o yaml > nginx-dep-result.yml
# contain status section

````
- delete deployment  and service base on file
````bash
kubectl delete -f nginx-deployment.yml
kubectl delete -f nginx-service.yml



kubectl get all # get all components
````

- secret example:
````bash
apiVersion: apps/v1
kind: Secret
metadata:
  name: mongodb-secret
type: Opaque # we have  another type like  TLS
data:
  mongo-root-username:
  mongo-root-password:
````

- generate password (not cleanr)
````bash
echo -n 'usernane' |base64

kubectl apply -f mongo-secret.yaml  # make secret before start
````
- example of deployment
````bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb-deployment
  labels:
    aapp: mongodb
  spec:
    replica: 1
    selector:
      matchlabels:
        app: mongodb
     template:
       metadata:
         lables:
           app: mongodb
       spec:
        containers:
        - name: mongodb
          image: mongodb
          ports:
          - containerPort: 27017
          env:
          - name: MONGO_INIT_DB_ROOT_USERNNAME
            valueFrom:
                secrectKeyRef:
                    name: mongodb-secret # can refrecnce external server
                    key: mongo-root-username
          - name: MONGO_INIT_DB_ROOT_PASSWORD
            valueFrom:
                secrectKeyRef:
                    name: mongodb-secret
                    key: mongo-root-password
          - name: MONGO_INIT_DB_URL
            valueFrom:
                configMapKeyRef:
                    name: mongodb-configMap
                    key: database_url
---
apiVersion: apps/v1
kind: Service
metadata:
  name: mongodb-expose-service
spec:
  selector:
    app: mongo-express
  type: LoadBlancer # this is extrenal service. for internal service , we do not need to define type
  ports:
    - protocol: TCP
      port: 8081
      targetPort: 8081
      nodePort: 3000 # that access from external network. 3000 to 32768

---
apiVersion: v1
kind: Service
metadata:
  name: mongodb-service
spec:
  selector:
    app: mongodb
  ports:
    - protocol: TCP
    port: 27017 # is expose port or service port
    targetPort: 27017 # deployment's port

````

````bash
kubectl get pod -watch
kubectl apply -f mongo.yml
kubectl get service
````
- in yaml `---` means documment seperation


- example of configMap
````bash
apiVersion: v1
kind: ConfigMap
metadata:
  name: mongodb-configMap
data:
  key1: value1
  database_url: mongodb-service


````


- assign external ip, we should run
````bash
kubectl get service
minikube service mongo-express
````





### namespace

- namespace is used to categorized environment in order to security issue and limit access
- For example we can have NS for dev,  staging and production 
- Default namespace is used to shared components such volumes 
- we can set default namespace with `cli` or define in `yaml file`.

- we can change defualt namespace 
````bash
kubens my-namespace
````



````bash

kubectl get all -n kubernetes-dashbord # show all components in NS
````

#### rules in ingress
- First we need to config for accessing to dashboard
````bash
apiVersion: networking.k8s.io/v1beta1
kind: ingress
metadata:
  name: dashabord-ingress
  namespace: kubernetes-dashabord
spec:
  rules:
  - host: dashabord.com
    http: 
      paths:
      - backend:
        serviceName: keber-dashabord # this is interal service and user when hit dashbord.com, internal service will be open(traffic is routed to internal service)
        servicePort: 80
        
````

- View ingress
```bash
kubectl get ingress -n kubernetes-dashbord --watch # return ip 
````
- view default value
````bash

kubectl describe ingress dashbord -n kubernetes-dashabord 
# view rules and path 

````

- multiple Path for same host. One domain and multiple service 
````bash 
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: simple-app
  annotaions:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.com 
    http:
      path: /analytics
      backend:
        serviceName: analytics-service
        servicePort: 3000
    - path: /shooping
      backend:
        serviceName: shopping-service
        servicePort: 8080
        

````
- multiple sub-domains or domains

````bash 
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: simple-app
  annotaions:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: analytics.domain.com 
    http:
      paths:
        backend:
          serviceName: analytics-service
          servicePort: 3000
  - host: shpping.domain.com 
    http:
      paths:
        backend:
          serviceName: shpping-service
          servicePort: 8080 

````



## Config TLS
- make a Secrect resource
````bash
apiVersion: v1
kind: Secrect
metadata:
  name: myapp-secret-tls
  namespace: default
data:
  tls.crt: base64 encoded cert
  tls.key: base64 encoded key
type: kubernetes.io/tls

````
- Use TLS config
````bash
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: simple-app
  annotaions:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - myapp.com
    SecrectName: myapp-secret-tls
  rules:
  - host: myapp.com 
    http:
      path: /analytics
      backend:
        serviceName: analytics-service
        servicePort: 3000
    - path: /shooping
      backend:
        serviceName: shopping-service
        servicePort: 8080
        

````

## Helm explained
- package manager for Kubernetes
- There are a lot of changes in Helm 
- To package YAML files and distribute them in public and private repositories  
### Halm Charts:
- Boundle of YAML files
- Create your own Helm Charts with Helm  
- Push them to Helm repository 
- Download and use existing ones
- For common apps we have charts in public repositories
- we can reuse thier configuration 

### Helm Search
- Public Registries: Discover & launch great kubernetes-ready apps 
- private Registries: share in oraganization 

### Templating Engine
- make template file for common and dynamic values for our resources
````bash
apiVersion: v1
kind: Pod
metadata: 
  name: {{.Values.name}}
spec:
  containers:
  - name: {{ .Values.container.name}}
    image: {{ .values.container.image}}
    port: {{ .values.container.port}}

````
- And then define `Values.yaml` and set values into it or also use `--set`  to set dynamic values
- So we have one template and multiple `values.yaml` files 
- This model usually is used in CI/CD 

### Helm Chart Structure
````bash
myChart/   # Top level 
  Chart.yaml # meta info about chart
  values.yaml # values for template files
  charts/ # chart dependancies
  templates/ # the actual template files  
...
````

- Install with helm
```bash
helm install <chartname> # Template file will be filled with the values from values.yaml

helm install --values=my-values.yaml <chartname> # override values
heml install --set version=2.0.0

````

### Helm Release Management
- Helm version 2 comes in 2 parts
1. Client (helm cli) `helm install <chartname>`
2. Service(Tiller) that recevie request from client
- every changes is saved in Tiller


- Keeping track of all chart executions
- Changes are applied to existing deployment instead of creating a new one
- Handling rollback

|revision| request|
|1       | Installed chart|
|2       | Upgraded to v 1.0.0|
|3       | Rolled back to 1|

- Thiller has too mush power and permission in cluster and there was security issue 
- In version 3 , Tiller is removed.

## K8s Volumes Explained
- We have 3 concepts:
1. Persistent Volume
2. Persistent Volume Claim
3. Storage Class

### Storage Requirements
1. Storage that doest not depend on the Pod Lifesycle
2. Storage must be avalaible on all nodes 
3. Storage need to survive even if cluster crashes

### Persistent Volume
- is a cluster resource like RAM, CPU , ... 
- is created via YAML file
````bash
apiVersion: v1
kind: PersistentVolume
metadata: 
  name: pv-name
spec:
  capacity:
    stoage: 5Gi
   volumeMode: FileSystem
   acceessModes:
    - ReadWriteOnce
  PersistentColumeReclaimPolicy: Recycle
  StorageClassname: slow
  mountOptions:
    - hard
    - nfsvers= 4.0
  nfs:
    path: /dir/path/on/nfs/server
    server: nfs-server-ip-address
    
  
     
````
- Persistent volume needs to physucal storage like: local disk, nft server , clould storage , ...

- manage and create them by ourself

- PV outside of the namespace
- Accessible to then whole clster
- Local volums type violate 2 ,3 Requirements or data persistance

- PV are already existed before creating a  POD, ...
- Admin confign storage resource ( like local , nfs, cloud-storage)
- Admin can make persistance volume
- Developer can claim for stoage and cluster find the best volume that can satisfy Developer's demands (PVC)

 - So developer set claim in yaml file like previous yaml file 
````bash
kind: PersistentVolumeClaim
...
metadata:
   name: pvc-name
spec:
  storageClassName: manual
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi

---
kind: POD
...
spec:
...
  volumes:
  - name: mypod
    PersistentVolumeClaim: 
      claimName: pvc-name
      
````
- claims must be in the same namespace   
- Volume is mounted into the POD (in volumes section)
- volume is mounted into Container ( in container section) this type are path  


- Lcoal volume is not create by PV and PVC and are managed by Kubernetes

#### different volume types
- we have 3 different volume types
1. secret
2. configMap
3. PersistentVolumeClaim
- we need to define volums and use them as a mount point in `volumeMounts`
````bash
spec:
  ...
  volumeMounts:
  - name: es-vol1
    mountPath: /var/lib/data
  - name: es-vol2
    mountPath: /var/lib/secret
  - name: es-vol3
    mountPath: /var/lig/config
  volumes:
  - name: es-vol1
    PersistentVolumeClaim:
      claimName: es-pv-claim
  - name: es-vol2
    secret: 
      secretName: es-Secrect
  - name: es-vol3
    configMap:
      name: es-config-map
  
````


### Storage class
- In real production env, there are a lot of request for PV and admin must handle these request. So  we can use another solution
- SC provisions Persistent Volumes dynamically when PersistentVolumeClaim claims it.   
- In PV we use `kind: PersistentVolume` but in storagClass we use another kind
- In PV, PVs must be created before POD

````bash
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: stoage-class-name
provisioner: kubernetes.io/aws-ebs # internal or external provisioner
parameters: # paramter of storage
  type: io1
  iopsPerGB: "10"
  fsType: ext4

````
- StorageClass is another abstraction level
- abstracts underlying storage provider
- parameters for that storage
- Create `PersistentVolumeClaim` to cliam from storageClass
````bash
apiVersion: v1
kind: PersistentVolumeClaim
metadata: 
  name: mypvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: storage-class-name


````
- Steps in storagClass
1. Pod claims storage via PVC
2. PVC requests storage from SC
3. StorageClass creates PV that meets the needs of the Claim


## Kubernetes StatefulSet explained
- Some pods need to save their state like database pod
- We do not have problem with stateless components for replications
- Replication is more defficault in stateful 
- In order to replicat data,we can use `pod indetidy` to handle all requests. 
- use Sticky identidy for each pod
- every pod is destroyed, new pod has same ID
- K8s use maser and worker to sycronize data between them
- Every worker must know about data changes
- New POD sycronize itself with another pod 
- For saving data, we must use `PV` instead of using just POD becuase with removing POD, data will be lost 

- Delete  operation (down scal) starts in replica from last
- We can set endpoint for each pod to access them thanks to loadbalancer service  

- when we restart a pod ip address is changed but name and endpoint stays same because Sticky identify retain state and retain role

- stateful applications not perfect for containerzed envirenmnets



## Kubernetes Service
- Each service is binded to pods 
- Each pod has its own IP Address
- Each pod can contian multiple containers such main app, log app
- Service stable ip address
- Service provides loadblanacer (randomly choose)
- loose coupling
- within & outside cluster


### ClusterIp Services
- default type: we no need to specify type 
 we have a pod with 2 containers and 2 ports and this pod is replicated all nodes.  
  ingres -> service(IP,PORT) -> choose a pod  ( use selector,  ...)
- K8s makes service endpoints 

### Multi-Port Services
- We have 2 ports in each pod and we want to open 2 port in equvalanet service 

### Headless Services
- In some cases, we need to connect to pod directly instead of connecting to sservice. such as statefull application (connect to master node because the master node has allowed to wtite data)
- Use DNS lookup to overcome this problem. DNS lookup for service- return single IP address (clusterIp). 
- Set clusterIp to "None"- return Pod Ip address instead


### Service type attribute
1. ClusterIP (is default and no need to set)
2. NodePort 
    - Open port from node to access to service directly. In this type, External traffix has access to fixed port on each worker Node
    - This type is not secure
````bash
apiVersion: v1
kind: Service
metadata: 
  name: ms-service-nodeport
  selector:
    app: microservice-nne
  ports:
  - protocol: TCP
    port: 3200
    targetPort: 3000
    nodePort: 30000 # from 30000 to 32768
`````
- View services
````bash
kubectl get svc
````
​         

3. LoadBalancer 'spec: type: LoadBalancer'
    - This is an extension of NodePort Service
    - NodePort Service is an extension of clusterIP service
    - A external loadbalancer that is implemented in a cloud provider access to our node port







