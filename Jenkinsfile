import com.cloudbees.plugins.credentials.CredentialsProvider
import com.cloudbees.plugins.credentials.common.StandardUsernameCredentials
import org.jenkinsci.plugins.gitclient.Git
import org.jenkinsci.plugins.gitclient.GitClient
import org.eclipse.jgit.transport.URIish;

env_branch_name = env
    .BRANCH_NAME
    .replace(" ", "")
    .toLowerCase()
env_job_name = env
    .JOB_NAME
    .replace(" ", "")
    .toLowerCase()
env_build_number = env.BUILD_NUMBER
YELLOW = "#FFFF00"
GREEN = "#ADFF2F"
RED = "#F08080"
PURPLE = "#800080"
enum DeployOptions {
    DEPLOY_FOR_TENANT_AND_SET_CONN_STR,
    DEPLOY_FOR_TENANT_AND_SET_CONN_STR_QUEUE_FOR_OTHER_TENANTS,
    DEPLOY_FOR_TENANT_AND_SET_CONN_STR_AND_UPGRADE_OTHER_TENANTS
}
isAutoBuild = true
isAdhoc = false
isMakeForOnPrem = false
isMakeForCloud = false
target = "filesync-alpha"
dockerRep = "develop"
deployAllowed = false

if (env_branch_name.contains("develop")) {
    target = "k8s-alpha"
    dockerRep = "develop"
}

if (env.JOB_NAME.toLowerCase().contains("adhoc")) {
    isAutoBuild = false
    isAdhoc = true
    env_branch_name = env
        .Branch
        .replace("/", "-")
    jobName = "flex-"
} else {
    env_branch_name = env
        .BRANCH_NAME
        .replace(" ", "")
        .toLowerCase()
    deployAllowed = true
    isMakeForCloud = true
    jobName = "tsla-"
}

if (env.Target) {
    target = env
        .Target
        .toLowerCase()
}

def TerraformSettings(element) {
    return [
        'TF_VAR_JOB_NAME=' + jobName,
        "TF_VAR_Deployment_Owner=${jobUserName}",
        'TF_VAR_BUILD_NUMBER=' + element,
        'TF_VAR_DEPLOY_CONTEXT=' + element,
        'TF_VAR_TARGET=' + target,
        'TF_VAR_namespace=' + target.toLowerCase(),
        'TF_VAR_namespace_context=rest',
        'TF_VAR_base_domain=revpro.cloud',
        'TF_VAR_ecs_cluster=' + target.toUpperCase() + '-cluster',
        // 'TF_VAR_api_image=' ,
        "TF_VAR_AWS_DEFAULT_REGION=us-west-2",
        "TF_VAR_AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}",
        "TF_VAR_AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
    ]
}

def AWSSettings() {
    // These are the AWS_SETTINGS used for executing AWS TASKS
    withCredentials([
        [$class: 'AmazonWebServicesCredentialsBinding',
        getAccessKeyVariable: 'AWS_ACCESS_KEY_ID',
        getSecretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
    ]) {
        return [ "AWS_ACCESS_KEY_ID=${   }", "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"]
    }
}

// These are the settings for build information
def BuildSettings(element) {
    return [
        'BRANCH=' + dockerRep,
        'JOB_NAME=' + env_job_name,
        'TF_VAR_JOB_NAME=' + env_job_name,
        'BRANCH_NAME=' + dockerRep,
        'BUILD_NUMBER=' + element
    ]
}

def executeNodeBranch(folder, binaryName) {
    checkout scm

    jobUserId = "jenkins"
    jobUserName = "jenkins-tesla"
    jobUserEmail = "kishorkumarravi@gmail.com"

    withCredentials([
        [$class: 'AmazonWebServicesCredentialsBinding',
        getAccessKeyVariable: 'AWS_ACCESS_KEY_ID',
        getSecretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
    ]) {
        withEnv(AWSSettings() + TerraformSettings('') + BuildSettings('')) {

            stage('Pylint'){
                sh "make tests || true"
                step([$class: 'WarningsPublisher',
                parserConfigurations: [
                    [parserName: 'PYLint',
                    pattern: 'lint/*.out']
                ],
                unstableTotalAll: '0',
                usePreviousBuildAsReference: true])
            }

            stage('Docker Publish to devOps') {
                sh "printenv"
                sh "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
                sh "make daws"
                sh "printenv"
                echo "Completed publishing"
                sh "make deploy-${target.toLowerCase()}"
            }
        } //end env
    } //end credentials
}

properties([disableConcurrentBuilds()])
stage('Connect to Jenkins Node') {
    executeNodeBranch('./', 'k8s')
}