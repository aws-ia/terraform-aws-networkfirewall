package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesCentralInspection(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/central_inspection_without_egress",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
