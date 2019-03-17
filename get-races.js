#!/usr/bin/env node

const cheerio = require('cheerio');
const request = require('./request');
const houseUrl = 'https://www.vpap.org/elections/house/candidates/general/';
const senateUrl = 'https://www.vpap.org/elections/senate/candidates/general/';

request(houseUrl).then(() => request(senateUrl));

function processHtml(html) {
    const $ = cheerio.load(html);
    $('table.table > tr')
}
