package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesPrivateOnly(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/central_inspection_with_egress",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
