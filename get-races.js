#!/usr/bin/env node

require('dotenv').config();
const url = require('url');
const fs = require('fs');
const assert = require('assert');
const cheerio = require('cheerio');
const _ = require('lodash');
const yaml = require('js-yaml');
const csvStringify = require('csv-stringify/lib/sync');
const {decodeHTML} = require('entities');
const {google} = require('googleapis');
const argv = require('yargs')
    .options({
        'csv': {
            type: 'boolean',
            describe: 'output to stdout as CSV rather than writing HTML file',
        },
        'full': {
            type: 'boolean',
            describe: 'refresh all info, including historical vote counts (takes a while)',
        },
        'limit': {
            type: 'number',
            describe: 'maximum number of districts to retrieve',
            default: Infinity,
        },
        'output-only': {
            type: 'boolean',
            describe: 'don\'t refresh data, just print',
        },
        'verbose': {
            type: 'boolean',
            describe: 'print districts as processed',
        },
        'vpap': {
            type: 'boolean',
            describe: 'get earlier election votes from VPAP rather than Daily Kos',
        },
    })
    .strict(true)
    .argv;
const request = require('./lib/request');
const googleApiKey = process.env.GOOGLE_API_KEY;
const dailyKosSpreadsheetId = '1YZRfFiCDBEYB7M18fDGLH8IrmyMQGdQKqpOu9lLvmdo';
const houseUrl = 'https://www.vpap.org/elections/house/candidates/general/';
const senateUrl = 'https://www.vpap.org/elections/senate/candidates/general/';
const dataFile = __dirname + '/races.yaml';
const currentElectionYear = 2019;
const noVaCounties = [ // ordered by increasing distance from DC
    'Arlington County',
    'Alexandria City',
    'Fairfax County',
    'Falls Church City',
    'Fairfax City',
    'Loudoun County',
    'Prince William County',
    'Manassas Park City',
    'Manassas City',
    'Stafford County',
    'Fauquier County',
];
let recordsByDistrict = {};
let districtCount = 0;

let promise = readExistingData();
if (!argv['output-only']) {
    promise = promise.then(() => processChamber(houseUrl))
        .then(() => processChamber(senateUrl))
        .then(function () {
            const districtsFound = Object.keys(recordsByDistrict).length;
            assert.strictEqual(districtsFound, 140,
                `Expected 140 districts, found ${districtsFound}`);
        })
        .then(addFixes)
        .then(addRatings)
        .then(writeData);
}
else {
    promise = promise.then(() => recordsByDistrict);
}
promise.then(argv.csv ? outputCsv : outputHtml)
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
    if (districtCount >= argv.limit) {
        return {};
    }
    const isHouse = /\/house/.test(chamberUrl);
    const $ = await getCheerio(chamberUrl);
    const headers = $('table.table thead tr:first-child th')
        .map((i, th) => $(th).text().trim())
        .get();
    headers.shift(); // remove "District" column head
    headers.push('Open', 'Retiring Incumbent', 'Party', 'Closest NoVa County'); // to set order of keys
    const rows = $('table.table tbody tr').get();
    for (const row of rows) {
        if (districtCount > argv.limit) {
            return {};
        }
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
        assert(m, `Unexpected format "${districtLinkHtml}"`);
        const election2019Url = url.resolve(chamberUrl, m[1]);
        const district= m[2].replace(/\s+/, '');
        if (argv.verbose) {
            console.log(district);
        }
        const record = _.zipObject(headers, values);
        if (argv.full || !recordsByDistrict[district]) {
            Object.assign(
                record,
                await getPreviousElectionData(election2019Url),
                await getIncumbentAndParty(election2019Url),
                argv.vpap ? await getEarlierElectionsDataFromVpap(election2019Url) : {},
                await getCampaignContributions(election2019Url),
            );
        }
        const open = !values.some(function (value) {
            return Array.isArray(value) && value.some(v => v.substr(-1) === '*');
        });
        record['Open'] = open;
        record['Retiring Incumbent'] = open ? record['Incumbent'] : '';
        delete record['Incumbent'];
        for (const [key, value] of Object.entries(record)) {
            if (!recordsByDistrict[district]) {
                recordsByDistrict[district] = {};
            }
            if (value !== undefined) {
                recordsByDistrict[district][key] = value;
            }
        }
        districtCount++;
        if (districtCount >= argv.limit) {
            break;
        }
    }
    if (!argv.vpap && argv.full) {
        if (argv.verbose) {
            console.log('getting Daily Kos data');
        }
        recordsByDistrict = // eslint-disable-line require-atomic-updates
            await addDailyKosData(isHouse, recordsByDistrict);
    }
    return recordsByDistrict;
}

async function getPreviousElectionData(election2019Url) {
    const isHouse = /\/house/.test(election2019Url);
    const detailUrl = election2019Url.replace('2019', isHouse ? '2017' : '2015');
    const $ = await getCheerio(detailUrl);
    const rows = $('table.table tbody tr').not('.ghost').get();
    assert(rows.length > 0, `Can't find vote table in ${detailUrl}`);
    const votes = {};
    for (const row of rows) {
        const cells = $(row).find('td');
        const candidate = cells.eq(0).text();
        const m = candidate.match(/\(([^)]+)\)/);
        assert(m, `Unexpected candidate format "${candidate}" in ${detailUrl}`);
        votes[m[1]] = +cells.eq(2).text()
            .replace(/^\s*([\d,]+)\s.+$/sm, '$1')
            .replace(/,/g, '');
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
    const incumbentDiv = $('div.col-12.col-lg-3');
    assert.strictEqual(incumbentDiv.length, 1, `Can't find incumbent section in ${districtUrl}`);
    const head = incumbentDiv.find('h4').text().trim();
    let incumbent = '';
    let party = '';
    if (head === 'Current Representative:') {
        incumbent = incumbentDiv.find('div').eq(1).text().trim();
        assert(incumbent, `Can't find incumbent in ${districtUrl}`);
        const m = incumbent.match(/^([^,+]+),\s+(.+?)\s+(\w+)$/);
        assert(m, `Unexpected incumbent format "${incumbent}" in ${districtUrl}`);
        incumbent = m[2] + ' ' + m[1];
        party = m[3].substr(0, 1);
    }
    else {
        assert.strictEqual(head, 'Seat is currently open',
            `Unexpected incumbent head format "${head}" in ${districtUrl}`);
    }
    const rows = $('div.col-12.col-lg-4 table tbody tr').get();
    assert(rows.length > 0, `Can't find county table in ${districtUrl}`);
    let closestCounty = '';
    const counties = [];
    for (const row of rows) {
        counties.push($('td', row).eq(0).text());
    }
    for (const county of noVaCounties) {
        if (counties.includes(county)) {
            closestCounty = county;
            break;
        }
    }
    return {
        'Incumbent': incumbent,
        'Party': party,
        'Closest NoVa County': closestCounty,
    };
}

async function getCampaignContributions(election2019Url) {
    const $ = await getCheerio(election2019Url);
    const rows = $('table.table > tbody > tr').get();
    const record = {};
    const parties = ['D', 'R'];
    for (const party of parties) {
        record[`$ Raised (${party})`] = null;
    }
    for (const row of rows) {
        if ($(row).hasClass('ghost')) {
            continue;
        }
        const text = $('td', row).eq(0).text();
        if (text.includes('Freitas')) { // write-in note
            continue;
        }
        const m = text.match(/\(([A-Z])\)/);
        assert(m, `No party found in "${text}"`);
        const party = m[1];
        if (!parties.includes(party)) {
            continue;
        }
        const amount = $('td', row).eq(1).text().replace(/\D+/g, ''); // delete all nondigits
        const key = `$ Raised (${party})`;
        assert.strictEqual(record[key], null, `Duplicate ${party} row found for ${election2019Url}`);
        record[key] = +amount;
    }
    record['D $ Advantage'] = (record['$ Raised (D)'] || 0) - (record['$ Raised (R)'] || 0);
    return record;
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
                    assert(m, `Unexpected format "${cells.eq(0).text()}"`);
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
                if (!records[district]) {
                    return;
                }
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

function addRatings() {
    for (const name of ['nuttycombe', 'tribbett']) {
        const file = `${__dirname}/${name}.csv`;
        const content = fs.readFileSync(file, 'utf-8');
        const ratings = {};
        for (const line of content.split('\n')) {
            const [district, rating] = line.split('\t');
            if (district) {
                ratings[district] = rating;
            }
        }
        const columnHead = name.substr(0, 1).toUpperCase() + name.substr(1) +
            ' Rating';
        for (const [district, record] of Object.entries(recordsByDistrict)) {
            record[columnHead] = getNumberRating(ratings[district] || ('Safe ' + record['Party']));
        }
    }

    function getNumberRating(string) {
        const [level, party] = string.split(' ');
        if (level === 'Tossup') {
            return 0;
        }
        assert(['D', 'R'].includes(party), `Unexpected party in rating "${string}"`);
        return {Safe: 4, Likely: 3, Lean: 2, Tilt: 1}[level] * (party === 'R' ? -1 : 1);
    }
}

function addFixes() {
    recordsByDistrict['HD30']['Republican'] = ['(probable write-in)'];
    if (!recordsByDistrict['HD80']['Party']) {
        recordsByDistrict['HD80']['Party'] = 'D';
    }
    if (!recordsByDistrict['SD7']['Party']) {
        recordsByDistrict['SD7']['Party'] = 'R';
    }
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
    const templateString = fs.readFileSync(__dirname + '/va-elections.html.tpl', 'utf8');
    const compiled = _.template(templateString);
    let headers = Object.keys(data[Object.keys(data)[0]]);
    headers.unshift('District');
    headers = headers.filter(r => !r.includes('$'))
        .concat(headers.filter(r => r.includes('$'))); // move campaign finance to end
    const dollarMax = Object.values(data).reduce(function (max, record) {
        return Math.max(
            Math.abs(record['$ Raised (D)']),
            Math.abs(record['$ Raised (R)']),
            max
        );
    }, 0);
    const html = compiled({headers, data, marginStyle, dollarMax});
    fs.writeFileSync(__dirname + '/va-elections.html', html);
}

function marginStyle(margin, max) {
    if (margin == null) {
        return 'class="empty"';
    }
    margin = +margin;
    let darkness = Math.abs(margin);
    if (max && darkness) {
        darkness = 100 * Math.sqrt(darkness / max);
    }
    let background;
    const level = (100 - darkness).toFixed(1);
    if (margin === 0) {
        background = 'white';
    }
    else if (margin < 0) {
        background = `rgb(100%, ${level}%, ${level}%)`;
    }
    else {
        background = `rgb(${level}%, ${level}%, 100%)`;
    }
    const color = darkness > 50 ? 'white' : 'black';
    return `style="background-color: ${background}; color: ${color};" class="number"`;
}
