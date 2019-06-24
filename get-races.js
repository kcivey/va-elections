#!/usr/bin/env node

require('dotenv').config();
const url = require('url');
const fs = require('fs');
const cheerio = require('cheerio');
const _ = require('lodash');
const yaml = require('js-yaml');
const csvStringify = require('csv-stringify/lib/sync');
const {decodeHTML} = require('entities');
const {google} = require('googleapis');
const argv = require('yargs')
    .options({
        csv: {
            type: 'boolean',
            describe: 'output to stdout as CSV rather than writing HTML file',
        },
        full: {
            type: 'boolean',
            describe: 'refresh all info, including historical vote counts (takes a while)',
        },
        vpap: {
            type: 'boolean',
            describe: 'get earlier election votes from VPAP rather than Daily Kos',
        },
    })
    .strict(true)
    .argv;
const request = require('./request');
const googleApiKey = process.env.GOOGLE_API_KEY;
const dailyKosSpreadsheetId = '1YZRfFiCDBEYB7M18fDGLH8IrmyMQGdQKqpOu9lLvmdo';
const houseUrl = 'https://www.vpap.org/elections/house/candidates/general/';
const senateUrl = 'https://www.vpap.org/elections/senate/candidates/general/';
const dataFile = __dirname + '/races.yaml';
const currentElectionYear = 2019;
let recordsByDistrict = {};

readExistingData()
    .then(() => processChamber(houseUrl))
    .then(() => processChamber(senateUrl))
    .then(writeData)
    .then(argv.csv ? outputCsv : outputHtml)
    .catch(err => console.error(err));

function readExistingData() {
    return new Promise(function (resolve, reject) {
        if (argv.full) {
            resolve();
            return;
        }
        fs.readFile(dataFile, 'utf8', function (err, yamlString) {
            if (!err) {
                recordsByDistrict = yaml.safeLoad(yamlString);
            }
            else if (err.code !== 'ENOENT') {
                reject(err);
            }
            resolve();
        });
    });
}

async function processChamber(chamberUrl) {
    const isHouse = /\/house/.test(chamberUrl);
    const $ = await getCheerio(chamberUrl);
    const headers = $('table.table thead tr:first-child th')
        .map((i, th) => $(th).text().trim())
        .get();
    headers.shift(); // remove "District" column head
    headers.push('Incumbent', 'Party'); // to set order of keys
    const rows = $('table.table tbody tr').get();
    for (const row of rows) {
        let values = $(row).find('td')
            .map((i, td) => $(td).html().trim().replace(/\s+/g, ' '))
            .get();
        const districtLinkHtml = values.shift();
        values = values.map(function (value) {
            return value.split(/\s*<br>\s*/g)
                .filter(v => (v !== ''))
                .map(decodeHTML);
        });
        const m = districtLinkHtml.match(/href="([^"]+)"\s*>\s*([HS]D\s*\d+)\s*</);
        if (!m) {
            throw new Error(`Unexpected format "${districtLinkHtml}"`);
        }
        const election2019Url = url.resolve(chamberUrl, m[1]);
        const district= m[2].replace(/\s+/, '');
        const record = _.zipObject(headers, values);
        if (argv.full || !recordsByDistrict[district]) {
            Object.assign(
                record,
                await getPreviousElectionData(election2019Url),
                await getIncumbentAndParty(election2019Url),
                argv.vpap ? await getEarlierElectionsDataFromVpap(election2019Url) : {},
            );
        }
        for (const [key, value] of Object.entries(record)) {
            if (!recordsByDistrict[district]) {
                recordsByDistrict[district] = {};
            }
            if (value !== undefined) {
                recordsByDistrict[district][key] = value;
            }
        }
    }
    if (!argv.vpap) {
        recordsByDistrict = await addDailyKosData(isHouse, recordsByDistrict);
    }
    return recordsByDistrict;
}

async function getPreviousElectionData(election2019Url) {
    const isHouse = /\/house/.test(election2019Url);
    const detailUrl = election2019Url.replace('2019', isHouse ? '2017' : '2015');
    const $ = await getCheerio(detailUrl);
    const rows = $('table.table tbody tr').get();
    const votes = {};
    for (const row of rows) {
        if ($(row).hasClass('ghost')) {
            continue;
        }
        const cells = $(row).find('td');
        const candidate = cells.eq(0).text();
        const m = candidate.match(/\((\w)\)/);
        if (m) {
            votes[m[1]] = +cells.eq(2).text().replace(/^\s*([\d,]+)\s.+$/sm, '$1')
                .replace(/,/g, '');
        }
    }
    const record = {};
    for (const abbr of ['D', 'R']) {
        record[`Previous ${abbr} Votes`] = votes[abbr] || 0;
    }
    record['Previous Margin'] = getDemMargin(votes['D'], votes['R']);
    return record;
}

async function getIncumbentAndParty(election2019Url) {
    const districtUrl = election2019Url.replace(/\/elections\/.*/, '/district/');
    const $ = await getCheerio(districtUrl);
    let incumbent = $('div.col-xs-12.col-md-3').find('div').eq(1).text().trim();
    let party = '';
    const m = incumbent.match(/^([^,+]+),\s+(.+?)\s+(\w+)$/);
    if (m) {
        incumbent = m[2] + ' ' + m[1];
        party = m[3].substr(0, 1);
    }
    return {
        Incumbent: incumbent,
        Party: party,
    };
}

async function getEarlierElectionsDataFromVpap(election2019Url) {
    const districtUrl = election2019Url.replace(/\/elections\/.*/, '/district/');
    let $ = await getCheerio(districtUrl);
    let prevYear = currentElectionYear;
    const record = {};
    const links = $('table.table-condensed a').get();
    for (const link of links) {
        const $link = $(link);
        const election = $link.text().trim();
        const m = election.match(/\b(20\d\d)\b/);
        if (m) {
            const electionYear = +m[1];
            if (electionYear < currentElectionYear - 5) {
                break;
            }
            else if (electionYear < prevYear) {
                const electionUrl = url.resolve(election2019Url, $link.attr('href'));
                $ = await getCheerio(electionUrl);
                const votes = {};
                const rows = $('table.top-buffer tbody tr').get();
                for (const row of rows) {
                    const cells = $(row).find('td');
                    const m = cells.eq(0).text().match(/\(([^)]+)\)/);
                    if (!m) {
                        throw new Error(`Unexpected format "${cells.eq(0).text()}"`);
                    }
                    votes[m[1]] = +cells.eq(1).text().trim()
                        .replace(/,/g, '');
                }
                for (const abbr of ['D', 'R']) {
                    record[`${election} ${abbr}`] = votes[abbr] || 0;
                }
                record[`${election} Margin`] = getDemMargin(votes['D'], votes['R']);
            }
            prevYear = electionYear;
        }
    }
    return record;
}

function addDailyKosData(isHouse, records) {
    const sheetName = isHouse ? 'VA_Lower' : 'VA_Upper';
    const sheets = google.sheets({version: 'v4', auth: googleApiKey});
    return sheets.spreadsheets.values
        .get({
            spreadsheetId: dailyKosSpreadsheetId,
            range: sheetName,
        })
        .then(function (res) {
            const headers = [];
            const rows = res.data.values;
            let endReached = false;
            rows.forEach(function (row, rowIndex) {
                if (rowIndex < 2) {
                    let currentTopHeader = '';
                    for (let i = 0; i < row.length; i++) {
                        const value = row[i];
                        currentTopHeader = headers[i] || (value && currentTopHeader);
                        if (currentTopHeader && !/^[HS]D$/.test(value)) {
                            headers[i] = currentTopHeader + ' ' + value;
                        }
                        else {
                            headers[i] = value;
                        }
                    }
                    return;
                }
                if (endReached || row[0] === 'Total') {
                    endReached = true;
                    return;
                }
                const district = headers[0] + row[0];
                row = row.map(function (v) {
                    // Convert numbers to numbers
                    return /^[\d,]+$/.test(v) ? +v.replace(/,/g, '') : v;
                });
                const rowData = _.zipObject(headers, row);
                Object.assign(
                    records[district],
                    {
                        '2017 Governor D': rowData['2017 Governor Northam'],
                        '2017 Governor R': rowData['2017 Governor Gillespie'],
                        '2017 Governor Margin': getDemMargin(
                            rowData['2017 Governor Northam'],
                            rowData['2017 Governor Gillespie']
                        ),
                        '2016 President D': rowData['2016 President Clinton'],
                        '2016 President R': rowData['2016 President Trump'],
                        '2016 President Margin': getDemMargin(
                            rowData['2016 President Clinton'],
                            rowData['2016 President Trump']
                        ),
                    }
                );
            });
            return records;
        });
}

function getCheerio(requestOptions) {
    return request(requestOptions)
        .then(html => cheerio.load(html))
        .catch(err => console.error(err) && process.exit());
}

function getDemMargin(dVotes, rVotes) {
    dVotes = dVotes ? +dVotes : 0;
    rVotes = rVotes ? +rVotes : 0;
    const margin = 100 * (dVotes - rVotes) / (dVotes + rVotes);
    return Math.sign(margin) * Math.round(Math.abs(margin)); // to avoid rounding .5 differently for + and -
}

function writeData() {
    return new Promise(function (resolve, reject) {
        fs.writeFile(dataFile, yaml.safeDump(recordsByDistrict), function (err) {
            if (err) {
                reject(err);
            }
            else {
                resolve(recordsByDistrict);
            }
        });
    });
}

function outputCsv(data) {
    const transformedData = [];
    for (const [district, r] of Object.entries(data)) {
        const record = {
            Chamber: district.substr(0, 1),
            District: +district.substr(2),
        };
        for (const [key, value] of Object.entries(r)) {
            record[key] = Array.isArray(value) ? value.join('; ') : value;
        }
        transformedData.push(record);
    }
    process.stdout.write(csvStringify(transformedData, {header: true}));
}

function outputHtml(data) {
    fs.readFile(__dirname + '/va-elections.tpl', 'utf8', function (err, templateString) {
        if (err) {
            throw err;
        }
        const compiled = _.template(templateString);
        const headers = Object.keys(data[Object.keys(data)[0]]);
        headers.unshift('District');
        const html = compiled({headers, data, marginStyle});
        fs.writeFile(__dirname + '/va-elections.html', html, function (err) {
            if (err) {
                throw err;
            }
        });
    });
}

function marginStyle(margin) {
    let background;
    if (margin == null) {
        return 'class="empty"';
    }
    margin = +margin;
    if (margin === 0) {
        background = 'white';
    }
    else if (margin < 0) {
        background = `rgb(100%, ${100 + margin}%, ${100 + margin}%)`;
    }
    else {
        background = `rgb(${100 - margin}%, ${100 - margin}%, 100%)`;
    }
    const color = Math.abs(margin) > 50 ? 'white' : 'black';
    return `style="background-color: ${background}; color: ${color};" class="number"`;
}
