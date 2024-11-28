Devops Test Question
========================

For this test I created a CI pipeline with github actions to automatically build a new image in packer, which can then be deployed via the included terraform (main.tf). To run this yourself you can simply fork the repo and set the appropriate AWS env variables to build a simple packer image that hosts the symfony demo app using an sqlite DB. 

Things I would do to make this production-ready
------------

  * Sqlite replaced with non-ephemeral RDS.
  * ELB/ALB in front of an auto-scaling group for resilience/scalability, ssl/dns.
  * Automatically invoke deployment after successful test/build.
  * CI-Based terraform deployments with state storage.
  * tune nginx/php-fpm configuration (shm sizes, worker limits, apc/apcu settings, possible external memcache/redis for session data + symfony cache).
  * deployment approval steps, e2e testing
  * some sort of stats collection/monitoring stack (grafana, loki, mimir or whatever).
  * proper alerting for critical conditions 

Drawbacks of current setup
----------
AMI Builds are comparitively slow to docker builds, this whole process could be accelerated greatly with an AMI that simply pulls the latest docker image on launch setup in an autoscaling group. 
Alternately if this is fast enough you could deploy this with a cloudformation asg with a blue/green setup. 

Installation
------------

**Step 1.**

Simply clone this repo and set your own AWS keys as environment secrets in github actions, it will build an AMI in the us-east-1 region, which the terraform will deploy. You will need to update the terraform ami owner filter for the source AMI for it to pick up the image. Once the first build is completed successfully, simply run the included terraform to deploy this. 

**Step 2.** 
just terraform CLI for this step, CI/Cloud-based would be ideal here but I ran out of time.
run `terraform init` within the terraform folder followed by plan and once you're satisfied terraform apply.
visit the dns name provided after ~30 seconds for t2.micro type instances. interact, edit some fields, do what you will. 
