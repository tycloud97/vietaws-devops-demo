## Usage


**IMPORTANT:** Pin to the release tag (e.g. `?ref=tags/0.1.0`) of one of [releases](https://github.com/sweet-io-org/codepipeline-git-webhook/releases).


Create a GitHub Personal Access Token that has `admin:repo_hook` for full control of repository hooks; in otherwords, we need `write:repo_hook` to write repository hooks and `read:repo_hook` to read repository hooks.


```hcl
module "cicd_webhook" {
  source                     = "git::https://github.com/sweet-io-org/codepipeline-git-webhook.git?ref=tags/x.y.z"
  name                       = "webhook-name"
  stage                      = "develop"
  
  github_repositories        = ["microservice-XXXXXX"]
  github_default_branch_name = "develop"
  
  webhook_secret             = "AAABBBCCCDDD"
  codebuild_target_pipeline  = "codepipeline-target-name"
}
```

### Optional

```
events = ["push"] # See full list of events here: https://developer.github.com/v3/activity/events/types/
insecure_ssl = true
content_type = json
