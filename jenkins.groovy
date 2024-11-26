pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AKIAZI2LHRV2DQPR4IMN') // Add your Jenkins credential ID
        AWS_SECRET_ACCESS_KEY = credentials('r+EhExZlsSm+KwS/1wJKYxe70Q5UIqaZ3+DUjArw')
        //AWS_SESSION_TOKEN = credentials('aws-session-token')
        AWS_REGION = 'us-east-1' // Update with your AWS region
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/MazharNawaz2002/POC_Repo001.git'
            }
        }

        stage('Build SAM Application') {
            steps {
                sh 'sam build'
            }
        }

        stage('Deploy SAM Application') {
            steps {
                sh """
                sam deploy --template-file .aws-sam/build/template.yaml \
                           --stack-name your-sam-stack-name \
                           --capabilities CAPABILITY_IAM \
                           --region $AWS_REGION \
                           --no-confirm-changeset \
                           --resolve-s3
                """
            }
        }
    }
}
