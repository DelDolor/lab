# Defect Dojo
Use Defect Dojo to aggregate, triage, and verify their vulnerability findings. Defect Dojo is an open-source application security posture management (ASPM) platform that allows you to manage your product security, cloud native security, cloud security, and network security findings in a single platform. In addition to the open-source offering, Defect Dojo also offers a commercial version with additional features such as enterprise single sign-on (SAML / OAuth), notifications, and premium support.

## Basics
- Product type = Gitlab group
- Product = Gitlab repo (CI_PROJECT_PATH)
- Product grade is displayed in the user interface as an A - F grade, while the Defect Dojo API returns this value as a numeric value from 0 - 100
- Each Defect Dojo product will have one to many Engagements, which has one to many Tests, which contains one to many Findings 
- Data formats that are supported by Defect Dojo: Product details screen, Findings > Import Scan Results
  - AWS Prowler V3 - Exports from AWS Prowler v3 in JSON format or from Prowler v4 in OCSF-JSON format.
  - Chef Inspect Log - Chef Inspect log file
  - CycloneDX Scan - Support CycloneDX XML and JSON report formats (compatible with 1.4).
  - SARIF - SARIF report file can be imported in SARIF format.
  - Semgrep JSON Report - Import Semgrep output (--json)
  - Trivy Scan - Import trivy JSON scan report.
  - ZAP Scan - ZAP XML report format.

## Demo scan results
Several security scans including Semgrep, Trivy configuration file analysis, and Trivy container image scanning

- **operations/dm-infrastructure-aws** 
  - imports the Checkov findings
- **audit/sabre-cloud-audit** 
  - importing the Prowler findings
- **applications/dm-api**
  - Download any available artifacts from the dm-api merge request pipelines into the ${CI_PROJECT_DIR}/tests directory
  - Import all of the SARIF result files in the semgrep, trivy-fs directories
  - Import the Trivy results in the trivy-scan-aws test directory.

## Secure score (product grade calculation)
The Defect Dojo Product Grade Calculation uses Active and Verified findings to reduce the starting value of 100 (no findings). The calculation starts by looking at the highest Severity level of a finding and reducing the grade a base level.
- Highest Severity Level: Maximum Grade
    - Critical: 40
    - High: 60
    - Medium: 80
    - Low: 95
  
Further points are then deducted from the grade for each additional finding based on the following table:
- Severity Level: Reduction per Finding
    - Critical: 5
    - High: 3
    - Medium: 2
    - Low: 1

### Read products grad from DD API (API Key from Vault)
```
export DEFECTDOJO_API_KEY=$(vault kv get -field=token kv/dm/tokens/defect-dojo)
curl -sL "https://dojo.xxx.labs/api/v2/products/?name=applications/dm-api" --header "Content-Type: application/json" --header "Authorization: Token $DEFECTDOJO_API_KEY" | jq '.results[]'
```

### Create andon cord (policy)
- Browse to the Defect Dojo applications/xx product details page
- Use the hamburger menu button (≡) in the Description table to view the Edit Product menu. Then, select the + Add Custom Fields option.
- The *product_grade_failure* custom field creates a policy that sets the product's minimum grade before **failing the build**. Set the custom field Name to *product_grade_failure* and a *Value that is less than your product's current score*. Then, press the Save & Add Another button to create the custom field and add a new one.
- The *product_grade_warning* custom field creates a policy that sets the product's minimum grade before **marking the build as unhealthy (yellow)**. Set the custom field Name to product_grade_warning and a *Value that is greater than your product's current score*. Then, press the Save button to create the second custom field.

## Defect Dojo policy as code component
- Jokainen pipeline pitää lähettää testiartifaktit Defect Dojoon ja tämän voi automatisoida/pakottaa
- GitLab CI Catalog provides reusable GitLab Components
    - https://gitlab.com/explore/catalog
    - https://to-be-continuous.gitlab.io/doc/
- To include a new component in a GitLab CI pipeline, the pipeline's include statement includes a new component reference to the repository hosting the component along with any input parameters:

```
include:
  - component: gitlab.com/org/repo/component-name@branch|tag
    inputs:
      var1: value
      var2: value
````

- CI Template from DM repo is based on to-be-continuous-defect-dojo releae but has some enhancements:
  - Reading the Defect Dojo API key from the Vault
  - Controlling the tag and stage for the Defect Dojo job
  - Importing Prowler, Trivy, and SARIF scan results formats
  - Configuring policy as code checks to mark the job as unhealthy or failed based on the product's health score
- customized DM Defect Dojo component is hosted in the operations/dm-ci-templates GitLab repository

## CI Template
When building a GitLab CI component, you must create a template directory in the root of the repository. Each component is defined in a directory inside the template directory that must contain a template.yml file. To reference the component in a GitLab CI pipeline, the include statement's component's path has the full path to the GitLab repository, following by the component's directory name, following by an @ symbol and the branch name, release tag, or commit hash.

To reference the DM Defect Dojo component, the full path to the GitLab repository is https://gitlab.xxx.labs/operations/dm-ci-templates/, followed by the templates's directory name defect-dojo, following by the @main ref to use the code from the main branch.


```
- component: gitlab.xxx.labs/operations/dm-ci-templates/defect-dojo@main

```


