'use strict';

const express = require('express');
const fs = require('fs');
const logger = require('morgan');

const app = express();
app.use(logger('dev'));
app.use(express.static('./dist'));

app.use(function(req, res, next) {
  fs.createReadStream('./dist/index.html').pipe(res);
})

module.exports = app;
