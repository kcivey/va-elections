#!/usr/bin/env node

const cheerio = require('cheerio');
const _ = require('lodash');
const csvStringify = require('csv-stringify/lib/sync');
const request = require('./request');
const houseUrl = 'https://www.vpap.org/elections/house/candidates/general/';
const senateUrl = 'https://www.vpap.org/elections/senate/candidates/general/';
const data = [];

request(houseUrl).then(processHtml)
    .then(() => request(senateUrl))
    .then(processHtml)
    .then(() => console.log(csvStringify(data, {header: true})));

function processHtml(html) {
    const $ = cheerio.load(html);
    const headers = $('table.table thead tr:first-child th')
        .map((i, th) => $(th).text().trim()).get();
    $('table.table tbody tr').each(function (i, tr) {
        const values = $(tr).find('td')
            .map(function (i, td) {
                const value = $(td).html().trim().replace(/\s+/g, ' ');
                return i > 0 ? value.replace(/\s*<br>\s*/g, '; ').replace(/;\s*$/, '') : value;
            })
            .get();
        let m;
        if ((m = values[0].match(/href="([^"]+)"\s*>\s*([HS]D\s*\d+)\s*</))) {
            const detailUrl = m[1];
            values[0] = m[2].replace(/\s+/, '');
        }
        const record = _.zipObject(headers, values);
        data.push(record);
    });
}
