[ci-img]: https://img.shields.io/travis/ciena-blueplanet/webdriverio-client.svg "Travis CI Build Status"
[ci-url]: https://travis-ci.org/ciena-blueplanet/webdriverio-client

[cov-img]: https://img.shields.io/coveralls/ciena-blueplanet/webdriverio-client.svg "Coveralls Code Coverage"
[cov-url]: https://coveralls.io/github/ciena-blueplanet/webdriverio-client

[npm-img]: https://img.shields.io/npm/v/webdriverio-client.svg "NPM Version"
[npm-url]: https://www.npmjs.com/package/webdriverio-client


# webdriverio-client

This is a client for the  [webdriverio-server](https://github.com/ciena-blueplanet/webdriverio-server).

## Setup

Setting up e2e tests for your app requires

1. Prerequisites
1. Setting up boilerplate
1. Writing tests

### Prerequisites

These instructions assume that you already have a server (either Mac or Ubuntu) running the [webdriverio-server](https://github.com/ciena-blueplanet/webdriverio-server). The client will need :

- [NodeJS >= 5.3 (including NPM)](https://github.com/creationix/nvm)


### Setting up boilerplate

We will describe a typical installation scenario with an ember project, but the client can easily be adapted for use with react projects (or any other setup).

In these instructions, we assume that the fully built application package is placed in the `dist` folder (default ember output directory) and the e2e tests are in the `tests/e2e` folder. If these are different for your application, just change these in the following instructions to point to the right place.


First, install `webdriverio-client` and also add it to the devDependencies.

```bash
npm install webdriverio-client --save-dev
```

Now, we will setup some command shortcuts for e2e testing. Edit `package.json` and add the following 2 command to the scripts section (create the scripts sections if its missing)...

```json
  "scripts": {
    "e2e-test": "wdio-client remote_e2e_test serverip:3000 dist tests/e2e",
    "update-screenshots": "wdio-client update_screenshots"
  }
```

The first command `e2e-test` passes 4 arguments to the `wdio-client` script - `remote_e2e_test`, `serverip:3000`, `dist` and `tests/e2e`... the last 3 can be modified to suit your application. Here, `serverip` is the ip address of the server running the `webdriverio-server` process, which typically runs on port `3000`. `dist` and `tests/e2e` are the application package folder and e2e tests folder, respectively.

We will now create the directory structure required for the e2e tests, screenshots and jasmine config file.

```bash
mkdir tests
mkdir tests/e2e
mkdir tests/e2e/screenshots
```

Create `tests/e2e/jasmine.json` and add the following...

```json
{
    "spec_dir": "tests",
    "spec_files": [
        "e2e/**/*-spec.js"
    ]
}
```

Also, add the following to `.gitignore`...

```
test.tar.gz
tests/e2e/test-config.json
tests/e2e/screenshots/diff
```

### Writing tests
Now, we are ready to create an e2e test. Create `tests/e2e/main-spec.js` and paste the following...


```javascript
var webdriverio = require('webdriverio');
var webdrivercss = require('webdrivercss');
var testUtils = require('../../testUtils/utils').e2e
var testConfig = require('./test-config.json');

var url = testUtils.getUrl(testConfig);

var NORMAL_VIEWPORT_WIDTH = 1280;
var NORMAL_VIEWPORT_HEIGHT = 800;

describe('myapp e2e tests using ' + url, function () {
    var client, commonScreenshots;
    jasmine.DEFAULT_TIMEOUT_INTERVAL = 9999999;

    beforeEach(function () {
        commonScreenshots = {
            name: 'content',
            elem: 'html',
        };

        client = testUtils.init(webdriverio, webdrivercss, testConfig);

        client
            .setViewportSize({width: NORMAL_VIEWPORT_WIDTH, height: NORMAL_VIEWPORT_HEIGHT})
            .url(url);
    });

    afterEach(function (done) {
      client.end(done);
    });

    it('main-page renders appropriately', function (done) {
        client
            .pause(1000)
            .verifyScreenshots('main-page', [commonScreenshots], function () {
              client.call(done);
            });
    });

});
```

Since this test executes on the `webdriverio-server`, the dependencies only need to be installed on the server machine (they are, when using the webdriverio-server). So we don't need to worry about all the requires at the top.


### Running the tests

To execute e2e tests...

```bash
npm run e2e-test
```

If tests fail because of a mismatch in screenshots, you can inspect the differences by checking out the images in `tests/e2e/screenshots/diff`.

If the new screenshots are accurate, you can update your reference screenshots by running

```bash
npm run update-screenshots
```
