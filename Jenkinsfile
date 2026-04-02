pipeline {
    agent any

    stages {
	stage('Preparation') {
	    steps {
		git branch: 'master', url: 'https://github.com/SPECCHIODB/VM_Appliance.git'
		sh 'rm -rf output-virtualbox-iso/'
	    }
	}
	stage('Inject CA private key') {
	    steps {
		withCredentials([
		    certificate(credentialsId: 'specchio_trust',
				keystoreVariable: 'SPECCHIO_KEYSTORE',
				aliasVariable: 'SPECCHIO_KEYSTORE_ALIAS',
				passwordVariable: 'SPECCHIO_KEYSTORE_PASSWORD')])
		{
		    sh 'cp /var/lib/jenkins/tls/production_ca.pkcs12 ansible/tls/production_ca.pkcs12'
		    sh 'echo ${SPECCHIO_KEYSTORE_ALIAS} > ansible/tls/production_ca_alias'
		    sh 'echo ${SPECCHIO_KEYSTORE_PASSWORD} > ansible/tls/production_ca_password'
		}
	    }
	}
	stage('Build') {
	    steps {
		sh '/usr/local/bin/packer build -force -timestamp-ui templates/specchio_centos7.6_virtualbox.json'
	    }
	}
	stage('Remove CA private key') {
	    steps {
		sh 'shred -f ansible/tls/production_ca.pkcs12'
		sh 'shred -f ansible/tls/production_ca_alias'
		sh 'shred -f ansible/tls/production_ca_password'
	    }
	}
	stage('Upload Archive') {
	    steps {
		archiveArtifacts artifacts: 'output-virtualbox-iso/*.ova', fingerprint: true
	    }
	}
    }
}
