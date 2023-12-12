# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@js-temporal/polyfill", to: "https://ga.jspm.io/npm:@js-temporal/polyfill@0.4.4/dist/index.esm.js"
pin "jsbi", to: "https://ga.jspm.io/npm:jsbi@4.3.0/dist/jsbi-umd.js"
