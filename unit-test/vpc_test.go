package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"sort"
)

func getKeys(m map[string]string) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	return keys
}

func getValues(m map[string]string) []string {
	values := make([]string, 0, len(m))
	keys := getKeys(m)
	for _, k := range keys {
		values = append(values, m[k])
	}
	return values
}

func Test_ShouldBeCreateAndDestroyVPC(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "/unit-test")

	//given

	var defaultRegion = []string{
		"eu-central-1",
	}

	var restrictedRegionsList = []string{"us-east-1", "us-east-2", "us-west-1", "us-west-2", "ca-central-1", "sa-east-1", "eu-west-1", "eu-west-2", "eu-west-3", "ap-southeast-1",
		"ap-southeast-2", "ap-northeast-1", "ap-northeast-2", "ap-south-1", "eu-north-1"}

	awsRegion := aws.GetRandomStableRegion(t, defaultRegion, restrictedRegionsList)
	azs := aws.GetAvailabilityZones(t, awsRegion)

	expectedNatGatewayPublicIPTagKeys := []string{"Name", "Project", "Terraform"}
	excectedNatGatewayPublicIPTagValueOfOne := []string{"eu-central-1a", "VPC-Test", "true"}
	expectedNatGatewayPublicIPTagValueOfTwo := []string{"eu-central-1b", "VPC-Test", "true"}
	expectedNatGatewayPublicIPTagValueOfThree := []string{"eu-central-1c", "VPC-Test", "true"}
	expectedPrivateCidrBlocks := []string{"10.100.0.96/28", "10.100.0.112/28", "10.100.0.128/28"}
	expectedAvailabilityZones := []string{"eu-central-1a", "eu-central-1b", "eu-central-1c"}
	//when

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{

		TerraformDir: testFolder,

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	t.Log("Running Terraform Init and Apply")

	terraform.InitAndApply(t, terraformOptions)

	assert.True(t, len(azs) > 1)
	for _, az := range azs {
		assert.Regexp(t, fmt.Sprintf("^%s[a-z]$", awsRegion), az)
	}

	actualVPCCidr := terraform.Output(t, terraformOptions, "cidr_block")
	firstTwo := aws.GetFirstTwoOctets(actualVPCCidr)
	t.Log("Actual VPC Cidr :", actualVPCCidr)

	if firstTwo != "10.100" {
		t.Errorf("Received: %s, Expected: 10.0", firstTwo)
	}
	t.Log("First Two Octets of CIDR", firstTwo)
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")

	publicSubnetsIds := terraform.Output(t, terraformOptions, "public_subnets")
	privateSubnetsIds := terraform.Output(t, terraformOptions, "private_subnets")

	replacer := strings.NewReplacer("[", "", "]", "", "\"", "", "\n", "", " ", "")

	subnetPublicIds := replacer.Replace(publicSubnetsIds)
	subnetPrivateIds := replacer.Replace(privateSubnetsIds)

	arrayPublicSubnets := strings.Split(subnetPublicIds, ",")
	arrayPrivateSubnets := strings.Split(subnetPrivateIds, ",")

	require.Equal(t, 6, len(aws.GetSubnetsForVpc(t, vpcId, awsRegion)))

	for i := 0; i < len(arrayPrivateSubnets)-1; i++ {
		isPrivate, err := aws.IsPublicSubnetE(t, arrayPrivateSubnets[i], awsRegion)
		if err != nil {
			t.Errorf("Error Encountered: %s", err)
			return
		}
		assert.False(t, isPrivate)
		t.Log("Verified Private Subnet :", isPrivate)
	}

	for i := 0; i < len(arrayPublicSubnets)-1; i++ {
		isPublic, err := aws.IsPublicSubnetE(t, arrayPublicSubnets[i], awsRegion)
		if err != nil {
			t.Errorf("Error Encountered: %s", err)
			return
		}
		assert.True(t, isPublic)
		t.Log("Verified Public Subnet :", isPublic)
	}

	transitGatewayRouteTableId := terraform.Output(t, terraformOptions, "transit_gateway_route_table_id")
	transitGatewayVpcAtId := terraform.Output(t, terraformOptions, "transit_gateway_vpc_attachment_id")
	actualPrivateCidrBlocks := terraform.OutputList(t, terraformOptions, "private_subnet_cidr_block")
	actualNatGatewayPublicIPTagKeys := terraform.OutputMap(t, terraformOptions, "public_subnet_cidr_blocks_one")
	actualNatGatewayPublicIPTagKeyOfTwo := terraform.OutputMap(t, terraformOptions, "public_subnet_cidr_blocks_two")
	actualNatGatewayPublicIPTagKeyOfThree := terraform.OutputMap(t, terraformOptions, "public_subnet_cidr_blocks_three")
	actualNatGatewayPublicIPTagValueOfOne := actualNatGatewayPublicIPTagKeys

	//then

	assert.Equal(t, expectedNatGatewayPublicIPTagKeys, getKeys(actualNatGatewayPublicIPTagKeys))
	assert.Equal(t, excectedNatGatewayPublicIPTagValueOfOne, getValues(actualNatGatewayPublicIPTagValueOfOne))
	assert.Equal(t, expectedNatGatewayPublicIPTagValueOfTwo, getValues(actualNatGatewayPublicIPTagKeyOfTwo))
	assert.Equal(t, expectedNatGatewayPublicIPTagValueOfThree, getValues(actualNatGatewayPublicIPTagKeyOfThree))
	assert.Equal(t, expectedPrivateCidrBlocks, actualPrivateCidrBlocks)
	assert.Equal(t, expectedAvailabilityZones, azs)

	assert.Empty(t, transitGatewayRouteTableId)
	assert.Empty(t, transitGatewayVpcAtId)
}
