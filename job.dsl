job('qa-performance-testing') {
    description('')

    logRotator {
        numToKeep(2)
    }

    properties {
        jiraProjectProperty {
            // Specify siteName and projectKey
            siteName('JIRA_SITE_NAME')  // Replace with your actual Jira site name
            projectKey('PROJECT_KEY')   // Replace with your actual Jira project key
        }
        // Assuming these plugins don't need to be explicitly referenced
        diskUsageProperty()
        mavenRepoCleanerProperty {
            notOnThisProject(false)
        }
        parameters {
            choiceParam('ENVIRONMENT', ['ENV', 'UAT'], 'Select the environment')
            choiceParam('LOB', ['LOB', 'KBPL_Demo_load_2.jmx', 'LOAD_CCPBM_myanmar.jmx', 'Unnati_Flutter_Load_Test_UAT.jmx', 'Nepal_Load_Test_DEMO.jmx', 'SIMA_SG_Load_Test_DEMO.jmx', 'LOAD_mars_italy_UAT.jmx', 'LOAD_HCCB_DEMO.jmx', 'Sample_order_swire_UAT.jmx', 'LOAD_Marssampling_DEMO.jmx', 'LOAD_Pladis_DEMO.jmx', 'LOAD_COKE_SLK_DEMO.jmx', 'LOAD_digivyapaar_DEMO.jmx', 'BEPENSA_LOAD_DEMO.jmx'], 'Select your LOB')
            stringParam('NumOfUsers', '1', 'Number of Threads going to be used')
            stringParam('RampUpPeriod', '1', 'Ramp up period in seconds')
            stringParam('Duration', '1', 'Duration in seconds')
            stringParam('Auth', '', 'Bearer Token')
        }
    }

    scm {
        git {
            remote {
                url('https://applicatetech.git.beanstalkapp.com/load-test.git')
                credentials('applicate_git')
            }
            branches('*/master')
        }
    }

    steps {
        shell('''
            ls -ltr
            echo "Running for LOB ${LOB} for environment ${ENVIRONMENT}"
            /qa/apache-jmeter-5.6.2/bin/jmeter.sh -n -t common/${LOB} -l${LOB}.jtl -JNumOfUsers=${NumOfUsers} -JRampUpPeriod=${RampUpPeriod} -JDuration=${Duration} -JAuth="${Auth}"
            echo "THREAD : ${NumOfUsers} RAMP_UP_PERIOD : ${RampUpPeriod} DURATION : ${Duration}"
        '''.stripIndent())
    }

    publishers {
        performancePublisher {
            errorFailedThreshold(-1)
            errorUnstableThreshold(-1)
            sourceDataFiles('${LOB}.jtl')
            modeOfThreshold(false)
            failBuildIfNoResultFile(true)
            showTrendGraphs(true)
            modeThroughput(true)
            percentiles('0,50,90,100')
        }
        mailer {
            recipients('mazhar@salescode.ai')
            notifyEveryUnstableBuild(true)
            sendToIndividuals(false)
        }
    }
}
