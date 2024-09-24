# web アプリを Kubernetes にデプロイするための manifests サンプル
以下のphpアプリを動かすための manifests です。

[https://github.com/masa0221/sample-webapp-php](https://github.com/masa0221/sample-webapp-php)

## minikube にデプロイする場合
### 1. 環境用意
minikube を起動
```sh
minikube start
```

利用するアドオンを有効化
```sh
minikube addons enable ingress
```

### 2. イメージを読み込み
https://github.com/masa0221/sample-webapp-php でビルドしたコンテナイメージを読み込みます。

```sh
minikube image load webapp-php:latest
```
```sh
minikube image load webapp-nginx:latest
```

### 3. namespace を作成
```sh
kubectl create namespace webapp
```

### 4. manifests を適用
```sh
kubectl apply -k ./manifests/overlays/dev
```

#### 動作確認
```
❯ kubectl -n webapp get all,ingress
NAME                         READY   STATUS    RESTARTS   AGE
pod/db-789c57776b-bjk2j      1/1     Running   0          32s
pod/webapp-694f4f49f-kj25c   2/2     Running   0          32s

NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/db-service       ClusterIP   10.105.122.168   <none>        3306/TCP   32s
service/webapp-service   ClusterIP   10.97.139.209    <none>        8080/TCP   32s

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/db       1/1     1            1           32s
deployment.apps/webapp   1/1     1            1           32s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/db-789c57776b      1         1         1       32s
replicaset.apps/webapp-694f4f49f   1         1         1       32s

NAME                                       CLASS   HOSTS   ADDRESS        PORTS   AGE
ingress.networking.k8s.io/webapp-ingress   nginx   *       192.168.49.2   80      32s
```

```
❯ curl -i http://127.0.0.1
HTTP/1.1 200 OK
Date: Wed, 28 Aug 2024 07:57:43 GMT
Content-Type: text/html; charset=UTF-8
Transfer-Encoding: chunked
Connection: keep-alive
X-Powered-By: PHP/8.3.10

<!doctype html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.tailwindcss.com/3.0.0"></script>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen">
  <div class="bg-white p-10 rounded-lg shadow-lg">
    <h1 class="text-4xl font-bold underline text-gray-900">Hello! Docker Compose!</h1>
    <p class="mt-4 text-gray-600">PHP version: 8.3.10</p>
    <p class="mt-4 text-gray-600">MySQL version: 8.0.39</p>
  </div>
</body>
</html>
```

### 5. 削除
```
kubectl delete -k ./manifests/overlays/dev
```

## LICENSE
Apache License 2.0
