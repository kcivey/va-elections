#!/usr/bin/env node

const url = require('url');
const cheerio = require('cheerio');
const _ = require('lodash');
const csvStringify = require('csv-stringify/lib/sync');
const {decodeHTML} = require('entities');
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
        .map((i, th) => $(th).text().trim()).get()
        .concat('Incumbent', 'Party');
    let rows = $('table.table tbody tr').get();
    rows = rows.slice(0, 4); // @@@
    for (const row of rows) {
        const values = $(row).find('td')
            .map(function (i, td) {
                const value = $(td).html().trim().replace(/\s+/g, ' ');
                return i === 0 ? value :
                    decodeHTML(
                        value.replace(/\s*<br>\s*/g, '; ')
                            .replace(/;\s*$/, '')
                    );
            })
            .get();
        let m;
        if ((m = values[0].match(/href="([^"]+)"\s*>\s*([HS]D\s*\d+)\s*</))) {
            values[0] = m[2].replace(/\s+/, '');
            const detailUrl = url.resolve(houseUrl, m[1])
                .replace(/\/elections\/.*/, '/district/');
            const html = await request(detailUrl);
            const $ = cheerio.load(html);
            let incumbent = $('div.col-xs-12.col-md-3').find('div').eq(1).text().trim();
            let party = '';
            if ((m = incumbent.match(/^([^,+]+),\s+(.+?)\s+(\w+)$/))) {
                incumbent = m[2] + ' ' + m[1];
                party = m[3].substr(0, 1);
            }
            values.push(incumbent, party);
        }
        const record = _.zipObject(headers, values);
        data.push(record);
    }
}
