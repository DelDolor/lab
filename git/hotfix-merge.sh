#Start by refreshing the main branch in the dm-web project. Then, create and check out the hotfix branch. Finally, merge the broken access control patch from the security/broken-access-control branch into the hotfix branch.
cd ~/code/localrepo
git checkout main
git pull
git checkout -b hotfix
git merge -m "feat: broken access control" origin/security/broken-access-control

#Start the deployment to the web-green service by pushing the patches to the hotfix branch.
git push origin hotfix

#Committing the change automatically kicks off the hotfix deployment pipeline that will create the green Kubernetes service and the pod containing the security patches. You can view the state of the deployment by going to dm-web pipelines and viewing the state of the latest build.
#Select the most recent build to view the progress of the deployment. Monitor the progress of the deploy-aws job. Feel free to move to the next step while the deployment is running.
