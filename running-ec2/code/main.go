package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
)

var client *ec2.Client

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	if err != nil {
		panic("configuration error, " + err.Error())
	}

	client = ec2.NewFromConfig(cfg)
}

func HandleRequest() ([]string, error) {

	result, err := client.DescribeInstances(context.TODO(), &ec2.DescribeInstancesInput{
		Filters: []types.Filter{
			{
				Name: aws.String("instance-state-name"),
				Values: []string{
					"running",
				},
			},
		},
	})

	if err != nil {
		return []string{}, err
	}

	var status []string
	for _, r := range result.Reservations {
		for _, ins := range r.Instances {
			status = append(status, fmt.Sprintf("InstanceID: %v State: %v", *ins.InstanceId, ins.State.Name))
		}

	}

	fmt.Println(status)

	return status, nil
}

func main() {
	lambda.Start(HandleRequest)
}
