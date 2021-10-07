./mvnw clean install -DskipTests

./mvnw spring-boot:build-image -DskipTests

docker tag demo:0.0.1-SNAPSHOT k3d-registry.localhost:5000/springboot-producer

docker tag demo-dapr-consumer:0.0.1-SNAPSHOT k3d-registry.localhost:5000/dapr-consumer

docker tag demo-dapr-producer:0.0.1-SNAPSHOT k3d-registry.localhost:5000/dapr-producer

docker tag demo-consumer:0.0.1-SNAPSHOT k3d-registry.localhost:5000/springboot-consumer

docker push k3d-registry.localhost:5000/dapr-consumer

docker push k3d-registry.localhost:5000/dapr-producer

docker push k3d-registry.localhost:5000/springboot-producer

docker push k3d-registry.localhost:5000/springboot-consumer

k create deploy dapr-consumer --image=k3d-registry.localhost:5000/dapr-consumer --dry-run=client -o yaml >> deploy/dapr-consumer.yaml

k apply -f springboot-producer.yaml -n kafka

k apply -f springboot-consumer.yaml -n kafka

k apply -f deploy/dapr-consumer.yaml

k port-forward pod/springboot-producer-5ffd95fd9-x4zfv 9999:8081 -n kafka

k create deploy dapr-producer --image=k3d-registry.localhost:5000/dapr-producer --dry-run=client -o yaml >> deploy/dapr-producer.yaml

kubectl create service nodeport dapr-producer-service --tcp=8083:8083 --dry-run=client -o yaml >> deploy/dapr-producer.yaml

kubectl create service nodeport dapr-consumer-service --tcp=3000:3000 --dry-run=client -o yaml >> deploy/dapr-consumer.yaml

k port-forward pod/dapr-producer-7fbbc8776-c67w4 8888:8083

docker build . -t k3d-registry.localhost:5000/kafka-function

Host.Startup[515]
      A host error has occurred during startup operation '28adf352-d223-4609-8a23-953e513826ce'.
System.DllNotFoundException: Failed to load the librdkafka native library.

dapr run --app-id pubsub-kafka ./mvnw spring-boot:run --components-path ../components/pubsub

docker run -d  --name docker-client docker.io/bitnami/kafka:2.8.0-debian-10-r84 sleep infinity

docker  container exec -it docker-client bash

{"requestTime": 100, "clientIdentifier": {"hostName": "host1", "ipAddress": "10.0.0.1"}, "employeeNames": ["amp1", "emp2"], "active": "YES"}

k get pods -n kafka

k apply -f deploy/keda-kafka-scaledobject.yaml

 kubectl exec --tty -i dapr-kafka-client --namespace kafka -- bash

kafka-topics.sh --create --topic users --bootstrap-server dapr-kafka.kafka:9092 --partitions 10 --replication-factor 1
kafka-topics.sh --alter --topic users --bootstrap-server dapr-kafka.kafka:9092 --partitions 10

 kafka-console-producer.sh --broker-list dapr-kafka.kafka:9092 --topic users
