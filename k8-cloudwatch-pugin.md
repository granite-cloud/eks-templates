# K8 CloudWatch Plugin for Custom Metrics

This is coped directly from the below source and can be used as a reference source.

Docs:
https://aws.amazon.com/blogs/compute/scaling-kubernetes-deployments-with-amazon-cloudwatch-metrics/

### Required IAM Role ( Use kube2iam )
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:GetMetricData"
            ],
            "Resource": "*"
        }
    ]
}
```

#### Deploy k8s-cloudwatch-adapter
kubectl apply -f https://raw.githubusercontent.com/awslabs/k8s-cloudwatch-adapter/master/deploy/adapter.yaml



#### Deploying an Amazon SQS application

Next, deploy a sample SQS application to test out k8s-cloudwatch-adapter. The SQS producer and consumer are provided, together with the YAML files for deploying the consumer, metric configuration, and HPA.

Both the producer and consumer use an SQS queue named helloworld. If it doesn’t exist already, the producer creates this queue.

Deploy the consumer with the following command:
```
kubectl apply -f https://raw.githubusercontent.com/awslabs/k8s-cloudwatch-adapter/master/samples/sqs/deploy/consumer-deployment.yaml
 ```

You can verify that the consumer is running with the following command:
```
kubectl get deploy sqs-consumer
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
sqs-consumer   1         1         1            0           5s
```

#### Set up Amazon CloudWatch metric and HPA
Next, create an ExternalMetric resource for the CloudWatch metric. Take note of the Kind value for this resource. This CRD resource tells the adapter how to retrieve metric data from CloudWatch.
You define the query parameters used to retrieve the ApproximateNumberOfMessagesVisible for an SQS queue named helloworld. For details about how metric data queries work, see CloudWatch GetMetricData API.

```
apiVersion: metrics.aws/v1alpha1
kind: ExternalMetric:
  metadata:
    name: hello-queue-length
  spec:
    name: hello-queue-length
    resource:
      resource: "deployment"
      queries:
        - id: sqs_helloworld
          metricStat:
            metric:
              namespace: "AWS/SQS"
              metricName: "ApproximateNumberOfMessagesVisible"
              dimensions:
                - name: QueueName
                  value: "helloworld"
            period: 300
            stat: Average
            unit: Count
          returnData: true
```


Then, set up the HPA for your consumer. Here is the configuration to use:

```
kind: HorizontalPodAutoscaler
apiVersion: autoscaling/v2beta1
metadata:
  name: sqs-consumer-scaler
spec:
  scaleTargetRef:
    apiVersion: apps/v1beta1
    kind: Deployment
    name: sqs-consumer
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: External
    external:
      metricName: hello-queue-length
      targetValue: 30

 ```

This HPA rule starts scaling out when the number of messages visible in your SQS queue exceeds 30, and scales in when there are fewer than 30 messages in the queue.

#### Create the HPA resource

```
kubectl apply -f https://raw.githubusercontent.com/awslabs/k8s-cloudwatch-adapter/master/samples/sqs/deploy/hpa.yaml
```



#### Create the ExternalMetric resource:

```
kubectl apply -f https://raw.githubusercontent.com/awslabs/k8s-cloudwatch-adapter/master/samples/sqs/deploy/externalmetric.yaml

 ```

#### Generate load using a producer

Finally, you can start generating messages to the queue:
```
kubectl apply -f https://raw.githubusercontent.com/awslabs/k8s-cloudwatch-adapter/master/samples/sqs/deploy/producer-deployment.yaml
```

On a separate terminal, you can now watch your HPA retrieving the queue length and start scaling the replicas. SQS metrics generate at five-minute intervals, so give the process a few minutes:
```
kubectl get hpa sqs-consumer-scaler -w
```
