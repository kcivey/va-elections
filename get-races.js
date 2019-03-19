#!/usr/bin/env node

const cheerio = require('cheerio');
const _ = require('lodash');
const request = require('./request');
const houseUrl = 'https://www.vpap.org/elections/house/candidates/general/';
const senateUrl = 'https://www.vpap.org/elections/senate/candidates/general/';

request(houseUrl).then(processHtml);

function processHtml(html) {
    const $ = cheerio.load(html);
    const headers = $('table.table thead tr:first-child th')
        .map((i, th) => $(th).text().trim()).get();
    $('table.table tbody tr').each(function (i, tr) {
        const values = $(tr).find('td').map((i, td) => $(td).html().trim().replace(/\s+/g, ' '))
            .get();
        const record = _.zipObject(headers, values);
        console.log(record);
    });
}
