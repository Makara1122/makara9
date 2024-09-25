#!/bin/bash

# Function to create a Jenkins job
create_job() {
    local job_name=$1
    echo "Creating job: $job_name"

    # Create the Jenkins job using curl
    response=$(curl -k -s -o /dev/null -w "%{http_code}" -u "makara:11a0af366772f1ffaa82317b5e99640b1a" \
        -H "Content-Type: application/xml" \
        -d "<flow-definition>
                <name>$job_name</name>
                <definition class='org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition'>
                    <script>pipeline {
                        agent any
                        stages {
                            stage('Build') {
                                steps {
                                    echo 'Building...'
                                }
                            }
                            stage('Test') {
                                steps {
                                    echo 'Testing...'
                                }
                            }
                            stage('Deploy') {
                                steps {
                                    echo 'Deploying...'
                                }
                            }
                        }
                    }</script>
                </definition>
            </flow-definition>" \
        "https://jenkins.psa-khmer.world/createItem?name=$job_name")

    if [[ "$response" -eq 200 ]]; then
        echo "Job $job_name created successfully."
    else
        echo "Failed to create job $job_name. HTTP response code: $response"
        exit 1
    fi
}

# Function to set job approval
 approve_input() {
    local job_name=$1
    echo "Approving input for job: $job_name"

    response=$(curl -k -s -o /dev/null -w "%{http_code}" -u "makara:11a0af366772f1ffaa82317b5e99640b1a" \
        "https://jenkins.psa-khmer.world/job/${job_name}/lastBuild/input/approve")

    if [[ "$response" -eq 200 ]]; then
        echo "Input approved for job $job_name."
    else
        echo "Failed to approve input for job $job_name. HTTP response code: $response"
        exit 1
    fi
}
# Function to trigger a build of the Jenkins job
trigger_build() {
    local job_name=$1
    echo "Triggering build for job: $job_name"

    # Trigger the build using curl
    build_response=$(curl -k -X POST -u "makara:11a0af366772f1ffaa82317b5e99640b1a" \
        "https://jenkins.psa-khmer.world/job/${job_name}/build" -o /dev/null -w "%{http_code}")

    if [[ "$build_response" -eq 201 ]]; then
        echo "Build triggered successfully for job: $job_name."
    else
        echo "Failed to trigger build for job $job_name. HTTP response code: $build_response"
        exit 1
    fi
}

# Function to delete a Jenkins job
delete_job() {
    local job_name=$1
    echo "Deleting job: $job_name"

    # Delete the Jenkins job using curl
    delete_response=$(curl -k -X POST -u "makara:11a0af366772f1ffaa82317b5e99640b1a" \
        "https://jenkins.psa-khmer.world/job/${job_name}/doDelete" -o /dev/null -w "%{http_code}")

    if [[ "$delete_response" -eq 200 ]]; then
        echo "Job $job_name deleted successfully."
    else
        echo "Failed to delete job $job_name. HTTP response code: $delete_response"
        exit 1
    fi
}

# Main script execution
echo "Welcome to Jenkins Job Management Script"

# Prompt for job name
read -p "Enter the job name: " job_name

# Create the job
create_job "$job_name"

# Ask if the user wants to set approval
read -p "Do you want to set approval for this job? (y/n): " set_approval_choice
if [[ "$set_approval_choice" == "y" ]]; then
    set_approval
fi

# Ask if the user wants to build the job
read -p "Do you want to build this job? (y/n): " build_choice
if [[ "$build_choice" == "y" ]]; then
    trigger_build "$job_name"
fi

# Ask if the user wants to delete the job
read -p "Do you want to delete this job? (y/n): " delete_choice
if [[ "$delete_choice" == "y" ]]; then
    delete_job "$job_name"
fi

echo "Script execution completed."

