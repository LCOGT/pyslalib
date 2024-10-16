#!/usr/bin/env groovy

/*
 * I freely admit that this is the stupidest possible method of using Jenkins
 * to run some commands inside a Docker container. However, I am completely
 * unable to make the Jenkins Docker Plugin work (it simply hangs forever, even
 * with a minimal "hello world" test case).
 *
 * So I gave up and did this the stupid way, because it works. It is definitely
 * very fragile, and is likely to break easily. For example, if the Jenkins
 * worker uid/gid is changed, etc. But hey ¯\_(ツ)_/¯, at least it works, right?
 */

@Library('lco-shared-libs@0.1.0') _

pipeline {
	agent any
	stages {
		// This step is needed because the permissions of all of the files we're
		// building here gets all sorts of messed up due to the pact of evil between
		// Jenkins and Docker. This breaks Jenkins. I hate Jenkins. It is the worst.
		stage('Pre-build cleanup') {
			steps {
				sh 'docker pull centos:7'
				sh 'docker run --rm -v $PWD:/io centos:7 /usr/bin/find /io -uid 0 -delete'
			}
		}
		stage('Build source distribution package') {
			steps {
				sh 'docker run --rm -v $PWD:/io python:3.7-slim /bin/bash /io/build-sdist.sh'
			}
		}
		stage('Build i686 wheels') {
			steps {
				sh 'docker pull quay.io/pypa/manylinux1_i686:latest'
				sh 'docker run --rm -v $PWD:/io quay.io/pypa/manylinux1_i686:latest linux32 /bin/bash /io/build-wheels.sh'
			}
		}
		stage('Build x86_64 wheels') {
			steps {
				sh 'docker pull quay.io/pypa/manylinux1_x86_64:latest'
				sh 'docker run --rm -v $PWD:/io quay.io/pypa/manylinux1_x86_64:latest /bin/bash /io/build-wheels.sh'
			}
		}
		// This post-build cleanup is needed for the same reasons as the pre-build
		// cleanup, except that we need to run it to un-break all of the permissions
		// problems for the next Jenkins run. This is because Jenkins runs various
		// permissions checks before we even get into our pipeline, and these permissions
		// checks cause the build to fail. I really hate Jenkins.
		stage('Post-build cleanup') {
			steps {
				sh 'docker pull centos:7'
				sh 'docker run --rm -v $PWD:/io centos:7 /usr/bin/find /io -uid 0 -delete'
			}
		}
	}
	post {
		always { postBuildNotify() }
	}
}
