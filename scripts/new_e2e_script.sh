#!/bin/bash

NODE_SPECS="tests/e2e"
TEST_PORT=`perl -MSocket -le 'socket S, PF_INET, SOCK_STREAM,getprotobyname("tcp"); \$\$port = int(rand(1080))+1080; ++\$\$port until bind S, sockaddr_in(\$\$port,inet_aton("127.1")); print \$\$port'`
TEST_CONFIG="tests/e2e/test-config.json"
HOSTNAME=`hostname`
SELENIUM_HOST="localhost"
SELENIUM_PORT=4444
SELENIUM_BROWSER="chrome"

function create_config {
  echo "{" > $TEST_CONFIG
	echo "    \"selenium\": {" >> $TEST_CONFIG
	echo "        \"host\": \"$SELENIUM_HOST\"," >> $TEST_CONFIG
	echo "        \"port\": \"$SELENIUM_PORT\"," >> $TEST_CONFIG
	echo "        \"browser\": \"$SELENIUM_BROWSER\"" >> $TEST_CONFIG
	echo "    }," >> $TEST_CONFIG
	echo "    \"http\": {" >> $TEST_CONFIG
	echo "        \"host\": \"$HOSTNAME\"," >> $TEST_CONFIG
	echo "        \"port\": \"$TEST_PORT\"," >> $TEST_CONFIG
	echo "        \"entryPoint\": \"/demo\"" >> $TEST_CONFIG
	echo "    }," >> $TEST_CONFIG
	echo "    \"seleniumServer\": \"$SELENIUM_HOST\"," >> $TEST_CONFIG # for backward-compatibility
	echo "    \"url\": \"http://$HOSTNAME:$TEST_PORT/demo\"" >> $TEST_CONFIG # for backwrd-compatibility
	echo "}" >> $TEST_CONFIG

}

SCREENSHOTS_DIR="tests/e2e/screenshots"

function clean_screenshots {
  echo "Removing everything but *.baseline.png files from $SCREENSHOTS_DIR"
	find $SCREENSHOTS_DIR -type f ! -name *.baseline.png -exec rm -f {} \; || echo "No screenshots present"
}


function cleanup_existing_screenshots {
	echo "Reverting any changes in $SCREENSHOTS_DIR"
	git checkout $SCREENSHOTS_DIR || echo "Not using git"
}

function remote_e2e_test {
  build_mock
  do_remote_e2e_test
  cleanup_existing_screenshots
}

function build_mock {
  echo "nothing to do in building mocks"
}

function do_remote_e2e_test {
  clean_screenshots
  create_config
	scripts/webdriverioTester --server $WEBDRIVERIO_SERVER $WEBDRIVERIO_SERVER_EXTRAS
}

function check_env {
  if [ -z "$WEBDRIVERIO_SERVER" ]; then
      echo "error: WEBDRIVERIO_SERVER variable must be set"
      exit 1
  fi
}

function update_screenshots {
  for i in `find tests/e2e/screenshots -name '*.regression.png'`
  do
    echo "mv $i ${i/regression/baseline}"
    mv $i ${i/regression/baseline}
  done
}

if [ "$1" = "update_screenshots" ]; then
  update_screenshots
fi

if [ "$1" = "remote_e2e_test" ]; then
  check_env
  remote_e2e_test
fi
