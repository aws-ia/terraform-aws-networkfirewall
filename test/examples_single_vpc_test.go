package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesSingleVPC(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/single_vpc",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
