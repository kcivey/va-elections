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
        .concat('D Votes', 'R Votes', 'Incumbent', 'Party');
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
            let detailUrl = url.resolve(houseUrl, m[1]);
            const isHouse = /house/.test(detailUrl);
            detailUrl = detailUrl.replace('2019', isHouse ? '2017' : '2015');
            let html = await request(detailUrl);
            let $ = cheerio.load(html);
            rows = $('table.table tbody tr').get();
            const votes = {};
            for (const row of rows) {
                if ($(row).hasClass('ghost')) {
                    continue;
                }
                const cells = $(row).find('td');
                const candidate = cells.eq(0).text();
                let m;
                if ((m = candidate.match(/\((\w)\)/))) {
                    const party = m[1];
                    votes[party] = cells.eq(2).text().replace(/^\s*([\d,]+)\s.+$/sm, '$1')
                        .replace(',', '');
                }
            }
            values.push(votes['D'], votes['R']);
            detailUrl = detailUrl.replace(/\/elections\/.*/, '/district/');
            html = await request(detailUrl);
            $ = cheerio.load(html);
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
