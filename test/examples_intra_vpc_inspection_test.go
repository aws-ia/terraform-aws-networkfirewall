package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesIntraVPC(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/intra_vpc_inspection",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
