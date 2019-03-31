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
const currentElectionYear = 2019;

request(houseUrl).then(processHtml)
    .then(() => request(senateUrl))
    .then(processHtml)
    .then(() => console.log(csvStringify(data, {header: true})));

async function processHtml(html) {
    let $ = cheerio.load(html);
    const headers = $('table.table thead tr:first-child th')
        .map((i, th) => $(th).text().trim())
        .get();
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
        let m = values[0].match(/href="([^"]+)"\s*>\s*([HS]D\s*\d+)\s*</);
        if (!m) {
            throw new Error(`Unexpected format "${values[0]}"`);
        }
        let detailUrl = url.resolve(houseUrl, m[1]);
        values[0] = m[2].replace(/\s+/, '');
        const record = _.zipObject(headers, values);
        const isHouse = /house/.test(detailUrl);
        detailUrl = detailUrl.replace('2019', isHouse ? '2017' : '2015');
        $ = await getCheerio(detailUrl);
        rows = $('table.table tbody tr').get();
        const votes = {};
        for (const row of rows) {
            if ($(row).hasClass('ghost')) {
                continue;
            }
            const cells = $(row).find('td');
            const candidate = cells.eq(0).text();
            if ((m = candidate.match(/\((\w)\)/))) {
                votes[m[1]] = cells.eq(2).text().replace(/^\s*([\d,]+)\s.+$/sm, '$1')
                    .replace(/,/g, '');
            }
        }
        for (const abbr of ['D', 'R']) {
            record[`Previous ${abbr} Votes`] = votes[abbr] || 0;
        }
        detailUrl = detailUrl.replace(/\/elections\/.*/, '/district/');
        $ = await getCheerio(detailUrl);
        let incumbent = $('div.col-xs-12.col-md-3').find('div').eq(1).text().trim();
        let party = '';
        m = incumbent.match(/^([^,+]+),\s+(.+?)\s+(\w+)$/);
        if (m) {
            incumbent = m[2] + ' ' + m[1];
            party = m[3].substr(0, 1);
        }
        record['Incumbent'] = incumbent;
        record['Party'] = party;
        const links = $('table.table-condensed a').get();
        let prevYear = currentElectionYear;
        for (const link of links) {
            const $link = $(link);
            const election = $link.text().trim();
            m = election.match(/\b(20\d\d)\b/);
            if (m) {
                const electionYear = +m[1];
                if (electionYear < currentElectionYear - 5) {
                    break;
                }
                else if (electionYear < prevYear) {
                    const electionUrl = url.resolve(detailUrl, $link.attr('href'));
                    $ = await getCheerio(electionUrl);
                    const votes = {};
                    const rows = $('table.top-buffer tbody tr').get();
                    for (const row of rows) {
                        const cells = $(row).find('td');
                        m = cells.eq(0).text().match(/\(([^)]+)\)/);
                        if (!m) {
                            throw new Error(`Unexpected format "${cells.eq(0).text()}"`);
                        }
                        votes[m[1]] = cells.eq(1).text().trim()
                            .replace(/,/g, '');
                    }
                    for (const abbr of ['D', 'R']) {
                        record[`${election} ${abbr}`] = votes[abbr] || 0;
                    }
                }
                prevYear = electionYear;
            }
        }
        data.push(record);
    }
}

function getCheerio(requestOptions) {
    return request(requestOptions)
        .then(html => cheerio.load(html));
}
