#!/usr/bin/env node

const url = require('url');
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

async function processHtml(html) {
    const $ = cheerio.load(html);
    const headers = $('table.table thead tr:first-child th')
        .map((i, th) => $(th).text().trim()).get();
    const rows = $('table.table tbody tr').get();
    for (const row of rows) {
        const values = $(row).find('td')
            .map(function (i, td) {
                const value = $(td).html().trim().replace(/\s+/g, ' ');
                return i > 0 ? value.replace(/\s*<br>\s*/g, '; ').replace(/;\s*$/, '') : value;
            })
            .get();
        let m;
        if ((m = values[0].match(/href="([^"]+)"\s*>\s*([HS]D\s*\d+)\s*</))) {
            values[0] = m[2].replace(/\s+/, '');
            const detailUrl = url.resolve(houseUrl, m[1]);
            const html = await request(detailUrl);
            console.log(values[0]);
        }
        const record = _.zipObject(headers, values);
        data.push(record);
    }
}
